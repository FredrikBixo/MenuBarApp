#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "MyHeaderCell.h"
#import "CurrencyCell.h"
#import "HoldingCell.h"
#import "PriceCell.h"
#import "CustomVC3.h"
#import "SearchCell.h"
#import "SCell.h"
#import "AccountsCell.h"
#import "TransactionCell.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 637
#define PANEL_WIDTH 412
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize searchField = _searchField;
@synthesize textField = _textField;
@synthesize tableView;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    
    [self setup];
    
    return self;
}

- (void)dealloc
{
    

        [[NSNotificationCenter defaultCenter] removeObserver:self];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark - textFieldDelegate


-(void)controlTextDidChange:(NSNotification *)obj {
    
    if (self.searchTextField2.stringValue.length >= 2) {
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@",self.searchTextField2.stringValue];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    filteredArray =  [[NSMutableArray alloc]initWithArray:[[currenciesNames filteredArrayUsingPredicate:bPredicate] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSLog(@"HERE %@",filteredArray);
    
    
    [self.searchTableView reloadData];
        
    }
    
}

#pragma mark - API calls

-(void)calculateHoldings{

    double portfolioValue = 0;
    
    for (NSString *currency in currencies) {
        
          double price = [prices[currency][@"USD"] doubleValue];
          portfolioValue += price*[[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",currency,currentAcc]];
        
    }
    
    self.balance.stringValue = [NSString stringWithFormat:@"$%.02f", portfolioValue];
    
}

-(void) getAllCoins{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.cryptocompare.com/api/data/coinlist/"]]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        allcoins = resp[@"Data"];
        currenciesNames = [[NSMutableArray alloc]initWithArray:[allcoins allKeys]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // do work here
            
            // set balance
            // Store response
                [self.tableView reloadData];
            
           // allcoins =
            
        });
        
    
        NSLog(@"Request reply: %@", allcoins);
    }] resume];
    
}

-(void)downloadPrices{
    
    NSString *joined = [currencies componentsJoinedByString: @","];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=BTC,USD,EUR",joined]]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        prices = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            // do work here
            // set balance
            [self calculateHoldings];
            
            // Calculate growth
            
            // calculate if
            
            double avg = 0;
            
            for (NSString *currency in currencies) {
                
                NSString *avragePrice = [NSString stringWithFormat:@"%@_avgPrice",currency];
                
                avg += [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]];
                
                double price = [prices[currency][@"USD"] doubleValue];
                
                NSString *string = [NSString stringWithFormat:@"%@_alerts",currency];
                
                
                NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
                
                NSMutableArray *alerts = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
                
                for (NSDictionary *alertPrice in alerts) {
                    if (price > [alertPrice[@"price"] doubleValue] && [alertPrice[@"type"] isEqualToString:@"Over"]) {
                        
                        // Show alert
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"OK"];
                        // [alert addButtonWithTitle:@"Cancel"];
                        [alert setMessageText:@"Price alert"];
                        [alert setInformativeText:[NSString stringWithFormat:@"%@ price over %@",currency, alertPrice[@"price"]]];
                        [alert setAlertStyle:NSAlertStyleInformational];
                        [alert runModal];
                        
                        if ([alertPrice[@"repeat"] isEqualToString:@"NO"]) {
                            
                            // save alerts
                            [alerts removeObject:alertPrice];
                            [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:alerts] forKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
                        }
                        break;
                    }
                    
                    if (price < [alertPrice[@"price"] doubleValue] && [alertPrice[@"type"] isEqualToString:@"Under"]) {
                        
                        // Show alert
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"OK"];
                        // [alert addButtonWithTitle:@"Cancel"];
                        [alert setMessageText:@"Price alert"];
                        [alert setInformativeText:[NSString stringWithFormat:@"%@ price over %@",currency, alertPrice[@"price"]]];
                        [alert setAlertStyle:NSAlertStyleInformational];
                        [alert runModal];
                        
                        if ([alertPrice[@"repeat"] isEqualToString:@"NO"]) {
                            // save alerts
                            [alerts removeObject:alertPrice];
                            [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:alerts] forKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
                        }
                       break;
                    }
                    
                    
                    
                }
            }
            
           
            avg = avg/currencies.count;
            
            if ([[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue] - avg > 0) {
            
            self.plusToday.stringValue = [NSString stringWithFormat:@"+$%.2f",[[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]-avg];
                
            } else if (avg < 0) {
                
                if ([[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]) {
                
                self.plusToday.stringValue = [NSString stringWithFormat:@"-$%.2f",fabs([[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]-avg)];
                    
                }
            
            } else {
                
                if ([[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]) {
                    
                    self.plusToday.stringValue = [NSString stringWithFormat:@"$%.2f",fabs([[self.balance.stringValue stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]-avg)];
                    
                }
                
            }
            
            [self.tableView reloadData];
        });
        
        NSLog(@"Request reply: %@", prices);
        
    }] resume];

}

#pragma mark - init

-(void)setup {
    
     NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
   [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
//    [myShareOnTwitterButton setTitle:service.title];
//    [myShareOnTwitterButton setEnabled:[service canPerformWithItems:nil]];
    
    [self.window.contentView addSubview:self.mainView];
    [self.window.contentView addSubview:self.donateView];
    [self.window.contentView addSubview:self.infoView];
    [self.window.contentView addSubview:self.searchView];
    [self.window.contentView addSubview:self.alertView];
    [self.window.contentView addSubview:self.accountsView];
    [self.window.contentView addSubview:self.settingsView];
    [self.window.contentView addSubview:self.addAccountView];
    [self.window.contentView addSubview:self.addTransactionView];
    self.donateView.alphaValue = 0;
    self.searchView.alphaValue = 0;
    self.accountsView.alphaValue = 0;
    self.settingsView.alphaValue = 0;
    self.addAccountView.alphaValue = 0;
    self.infoView.alphaValue = 0;
    self.alertView.alphaValue = 0;
    self.addTransactionView.alphaValue = 0;
    self.donateView.hidden = true;
    self.searchView.hidden = true;
    self.infoView.hidden = true;
    self.alertView.hidden = true;
    self.accountsView.hidden = true;
    self.settingsView.hidden = true;
    self.addAccountView.hidden = true;
    self.addTransactionView.hidden = true;
    
    
  //  [self.tableView removeTableColumn:self.column];
    self.searchTextField2.delegate = self;


    
    
    allcoins = [[NSMutableDictionary alloc]init];
    
    [self getAllCoins];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    prices = [[NSDictionary alloc]init];
    
    
    // loadSavedData
  
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"currentAcc"] != nil) {
        self.account.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentAcc"];
        currentAcc = self.account.stringValue;
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"Account1" forKey:@"currentAcc"];
        self.account.stringValue = @"Account1";
        currentAcc = @"Account1";
    }
    
      currencies = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"%@_%@",@"holdings",currentAcc]]];
    
    for (NSString *currency in currencies) {
        [self calculateHoldingsFor:currency];
    }
    
    transactionArray = [[NSMutableArray alloc]init];
    
    
    filteredArray = [[NSMutableArray alloc] init];
    
    accountsArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"]];
    
    if ([accountsArray count] == 0) {
        
        accountsArray = [[NSMutableArray alloc] initWithObjects:@"Account1", nil];
        
    }
    
    [self downloadPrices];

    [self.searchTableView setCornerView:nil];
    [self.searchTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    [self.tableView setCornerView:nil];
    
    [self.infoTableview setCornerView:nil];
    [self.infoTableview setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    
    [self.accountsTableView setCornerView:nil];
    [self.accountsTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.accountsTableView setCornerView:nil];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:true block:^(NSTimer *timer) {
        
        [self downloadPrices];
        
    }];
    
    // UI customization
    
    NSColor *color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.accountsB attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self.accountsB setAttributedTitle:colorTitle];
    
    NSMutableAttributedString *colorTitle2 = [[NSMutableAttributedString alloc] initWithAttributedString:[self.settingsB attributedTitle]];
    NSRange titleRange2 = NSMakeRange(0, [colorTitle2 length]);
    [colorTitle2 addAttribute:NSForegroundColorAttributeName value:color range:titleRange2];
    [self.settingsB setAttributedTitle:colorTitle2];
    
    NSMutableAttributedString *colorTitle3 = [[NSMutableAttributedString alloc] initWithAttributedString:[self.shareB attributedTitle]];
    NSRange titleRange3 = NSMakeRange(0, [colorTitle3 length]);
    [colorTitle3 addAttribute:NSForegroundColorAttributeName value:color range:titleRange3];
    [self.shareB setAttributedTitle:colorTitle3];
    
    // placeholder color setup

    NSMutableAttributedString *str = [[self.coin attributedStringValue] mutableCopy];
    
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
    
    [self.coin setAttributedStringValue:str];
    
    NSMutableAttributedString *str2 = [[self.holdingsText attributedStringValue] mutableCopy];
    
    [str2 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str2.length)];
    
    [self.holdingsText setAttributedStringValue:str2];
    
    NSMutableAttributedString *str3 = [[self.price attributedStringValue] mutableCopy];
    
    [str3 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str3.length)];
    
    [self.price setAttributedStringValue:str3];
    
    [self.tableView reloadData];
    
    self.accountsTableView.dataSource = self;
    self.accountsTableView.delegate = self;
    
    [self.tableView setAction:@selector(clickedRow)];
    [self.tableView setTarget:self];
    
    [self.searchTableView setAction:@selector(clickedRowS)];
    [self.searchTableView setTarget:self];
    
    [self.accountsTableView setAction:@selector(clickedRowA)];
    [self.accountsTableView setTarget:self];
    
    [self.infoTableview setAction:@selector(clickInfoTableView)];
    [self.infoTableview setTarget:self];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    
    self.infoTableview.dataSource = self;
    self.infoTableview.delegate = self;
    
    NSClickGestureRecognizer *rec = [[NSClickGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    
    [self.moreMenu addGestureRecognizer:rec];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    
    
    
    
    NSDictionary *blueDict = [NSDictionary dictionaryWithObject: [NSColor darkGrayColor]
                                                         forKey: NSForegroundColorAttributeName];
    NSAttributedString *blueString = [[NSAttributedString alloc] initWithString: @"Quantity"
                                                                     attributes: blueDict];
    
    [self.Quantity setPlaceholderAttributedString:blueString];
    
    NSDictionary *blueDict2 = [NSDictionary dictionaryWithObject: [NSColor darkGrayColor]
                                                         forKey: NSForegroundColorAttributeName];
    NSAttributedString *blueString2 = [[NSAttributedString alloc] initWithString: @"Notes"
                                                                     attributes: blueDict2];
    
    [self.notes setPlaceholderAttributedString:blueString2];
    
    NSDictionary *blueDict3 = [NSDictionary dictionaryWithObject: [NSColor darkGrayColor]
                                                          forKey: NSForegroundColorAttributeName];
    NSAttributedString *blueString3 = [[NSAttributedString alloc] initWithString: @"Price"
                                                                      attributes: blueDict3];
    
    [self.sell setPlaceholderAttributedString:blueString2];
    
    NSDictionary *blueDict4 = [NSDictionary dictionaryWithObject: [NSColor darkGrayColor]
                                                          forKey: NSForegroundColorAttributeName];
    NSAttributedString *blueString4 = [[NSAttributedString alloc] initWithString: @"Search coins"
                                                                      attributes: blueDict4];
    
    [self.searchTextField2 setPlaceholderAttributedString:blueString4];

    
}

- (void) clickInfoTableView {
    
   
    
    NSDictionary *transaction = transactionArray[self.infoTableview.clickedRow];
    
    self.currencyName.stringValue = self.name.stringValue;
    self.sell.stringValue = transaction[@"price"];
    self.Quantity.stringValue = transaction[@"quantity"];
    self.notes.stringValue = transaction[@"notes"];
    
    clickedRow2 = self.infoTableview.clickedRow;
    remove = true;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.addTransactionView.animator.alphaValue = 1;
        self.infoView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self.addTransactionView.hidden = NO;
                            self.infoView.hidden = TRUE;
                        }];
    
}


-(void)click:(NSClickGestureRecognizer *) g {
   
    NSLog(@"%f",[g locationInView:self.moreMenu].x);
    
    if (CGRectContainsPoint(self.accountsB.frame, [g locationInView:self.moreMenu])) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            context.duration = 0.4;
            self.mainView.animator.alphaValue = 0;
            self.accountsView.animator.alphaValue = 1;
            
    }
                            completionHandler:^{
                                
                                self.mainView.hidden = YES;
                                self.accountsView.hidden =  NO;
                                
                                [self.accountsTableView reloadData];
                                
                            }];
        
    }
    
    if (CGRectContainsPoint(self.shareB.frame, [g locationInView:self.moreMenu])) {

    }
    
    if (CGRectContainsPoint(self.settingsB.frame, [g locationInView:self.moreMenu])) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.4;
            self.mainView.animator.alphaValue = 0;
            self.settingsView.animator.alphaValue = 1;
    }
         completionHandler:^{
                                
                                self.mainView.hidden = YES;
                                self.settingsView.hidden =  NO;
                                
                                
                                
            }];
        
    }
    
    if (!CGRectContainsPoint(CGRectMake(210, 361, 210, 232), [g locationInView:self.moreMenu])) {
       self.moreMenu.hidden = true;
    }
    
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    
    if ([[notification name] isEqualToString:@"TestNotification"])
        NSLog (@"Successfully received the test notification! %d", [[notification object] taggy]);
    
    
    NSString *currency = [currencies objectAtIndex:[[notification object] taggy]];
    
    selectedCurrency = currency;
    
    self.currentBtcPrice.stringValue =  [NSString stringWithFormat:@"current %@ price: $%.2f", currency,[prices[currency][@"USD"] doubleValue]];
    
    self.alertTextField.stringValue = [NSString stringWithFormat:@"%.2f", [prices[currency][@"USD"] doubleValue]];

    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.alertView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = YES;
                            self.alertView.hidden =  NO;
                            
                        }];
    
    
}

-(void) loadAccounts {
    
    accountsArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"accounts"];
    
}

-(void)saveAccounts{
    
   [[NSUserDefaults standardUserDefaults] setObject:accountsArray forKey:@"accounts" ];
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}


#pragma mark - Public accessors

- (IBAction)plusButton:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.searchView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = YES;
                            self.searchView.hidden =  NO;
                            
                            [self.searchTableView reloadData];
                            
                        }];
    
    
}

- (IBAction)moreButton:(id)sender {
    
    self.moreMenu.hidden = false;
    
}

#pragma mark - DonateView

- (IBAction)donate:(id)sender {
    
  // self.window.contentViewController = [[CustomVC3 alloc]init];
    

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.donateView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.mainView.hidden = true;
                            self.donateView.hidden = false;
                        }];
    

    
}



- (IBAction)alertBack:(id)sender {
    
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.alertView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = NO;
                            self.alertView.hidden =  YES;
                            
                            
                            
                        }];
    
}

- (IBAction)alertB:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.alertView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = NO;
                            self.alertView.hidden =  YES;
                            
                            
                            
                        }];
    
}

- (IBAction)accountBack:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.accountsView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = NO;
                            self.accountsView.hidden =  YES;
                            
                            
                            
                        }];
    
}

- (IBAction)addAccBack:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.accountsView.animator.alphaValue = 1;
        self.addAccountView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            
                            self.accountsView.hidden = NO;
                            self.addAccountView.hidden =  YES;
                            
                            
                            
                        }];
    
}

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    

    
    NSRect searchRect = [self.searchField frame];
    searchRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    searchRect.origin.x = SEARCH_INSET;
    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET - NSHeight(searchRect);
    
    if (NSIsEmptyRect(searchRect))
    {
        [self.searchField setHidden:YES];
    }
    else
    {
        [self.searchField setFrame:searchRect];
      //  [self.searchField setHidden:NO];
    }
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    textRect.origin.x = SEARCH_INSET;
    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
    textRect.origin.y = SEARCH_INSET;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
      //  [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

- (void)runSearch
{
    NSString *searchFormat = @"";
    NSString *searchString = [self.searchField stringValue];
    if ([searchString length] > 0)
    {
        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
    }
    NSString *searchRequest = [NSString stringWithFormat:searchFormat, searchString];
    [self.textField setStringValue:searchRequest];
}

- (NSString *) getRealPrice:(NSString *) price {
    NSArray* words = [price componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    return [nospacestring stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

#pragma mark - TableView Data Source and Delegate

-(NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (tableView == self.infoTableview) {
        
        if ([tableColumn.identifier isEqualToString:@"Transaction"]) {
            
            
            TransactionCell *view = [self.infoTableview makeViewWithIdentifier:tableColumn.identifier owner:self];
            
            if ([[transactionArray objectAtIndex:row][@"quantity"] doubleValue] > 0) {
                view.sellorBuy.image = [NSImage imageNamed:@"Buy"];
                view.descriptor.stringValue = [NSString stringWithFormat:@"Bought %@ %@", [transactionArray objectAtIndex:row][@"quantity"], self.name.stringValue];
                
                view.bought.stringValue = [NSString stringWithFormat:@"+$%.2f",[[self getRealPrice:[transactionArray objectAtIndex:row][@"price"] ] doubleValue] * [[transactionArray objectAtIndex:row][@"quantity"] doubleValue]];
            } else {
                view.sellorBuy.image = [NSImage imageNamed:@"Sell"];
                view.descriptor.stringValue = [NSString stringWithFormat:@"Sold %.0f %@", fabs([[transactionArray objectAtIndex:row][@"quantity"] doubleValue]), self.name.stringValue];
                
                
                view.bought.stringValue = [NSString stringWithFormat:@"-$%.2f",fabs([[self getRealPrice:[transactionArray objectAtIndex:row][@"price"] ] doubleValue] * [[transactionArray objectAtIndex:row][@"quantity"] doubleValue])];
                
            }
            
            
     
            
            view.price.stringValue = [NSString stringWithFormat:@"$%@",[self getRealPrice:[transactionArray objectAtIndex:row][@"price"]]];
            view.quantity.stringValue = [transactionArray objectAtIndex:row][@"quantity"];
            if ([transactionArray objectAtIndex:row][@"notes"] != nil) {
                view.notes.stringValue = [transactionArray objectAtIndex:row][@"notes"];
            } else {
                view.notes.stringValue = @"";
            }
            
            // view.secondTextField.stringValue = [filteredArray objectAtIndex:row];
            // view.wantsLayer = true;
            // view.layer.backgroundColor = [[NSColor colorWithRed:35/255.f green:42/255.f blue:52/255.f alpha:1] CGColor];
            //  dispatch_async(dispatch_get_main_queue(), ^{
            //  view.btc.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.cryptocompare.com%@",allcoins[[filteredArray objectAtIndex:row]][@"ImageUrl"]]]];
            //   });
            //  view.btc.layer.cornerRadius = view.btc.layer.frame.size.height/2;
            
            return view;
        }
        
        return [[NSView alloc] init];
    }

    if (tableView == self.accountsTableView) {
        
        NSLog(@"accc");
        
        if ([tableColumn.identifier isEqualToString:@"Account"]) {
            
            AccountsCell *view = [self.accountsTableView makeViewWithIdentifier:tableColumn.identifier owner:self];
            
            view.secondTextField5.stringValue = [accountsArray objectAtIndex:row];
            view.wantsLayer = true;
            view.layer.backgroundColor = [[NSColor colorWithRed:35/255.f green:42/255.f blue:52/255.f alpha:1] CGColor];

            return view;
        }
        
        return [[NSView alloc] init];
        
  }
    
   if (tableView == self.searchTableView) {
        if ([tableColumn.identifier isEqualToString:@"Search"]) {
            

            CurrencyCell *view = [self.searchTableView makeViewWithIdentifier:tableColumn.identifier owner:self];
            
            view.secondTextField.stringValue = [filteredArray objectAtIndex:row];
            view.wantsLayer = true;
            view.layer.backgroundColor = [[NSColor colorWithRed:35/255.f green:42/255.f blue:52/255.f alpha:1] CGColor];
          //  dispatch_async(dispatch_get_main_queue(), ^{
                view.btc.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.cryptocompare.com%@",allcoins[[filteredArray objectAtIndex:row]][@"ImageUrl"]]]];
         //   });
              view.btc.layer.cornerRadius = view.btc.layer.frame.size.height/2;
            
            return view;
        }
       
        return [[NSView alloc] init];
    }
   
    // let cell = tableView.makeViewWithIdentifier((tableColumn!.identifier), owner: self) as? NSTableCellView
    
    NSString *currency = [currencies objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"Coin"]) {
    CurrencyCell *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        view.secondTextField.stringValue = currency;
   //      dispatch_async(dispatch_get_main_queue(), ^{
        view.btc.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.cryptocompare.com%@",allcoins[currency][@"ImageUrl"]]]];
    //     });
        view.btc.layer.cornerRadius = view.btc.layer.frame.size.height/2;
        NSLog(@"https://www.cryptocompare.com%@",allcoins[currency][@"ImageUrl"]);
        return view;
    }
    
    
    if ([tableColumn.identifier isEqualToString:@"Holdings"] & hideBalances == 0) {
        HoldingCell *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        double price = [prices[currency][@"USD"] doubleValue];
        view.secondTextField.stringValue = [NSString stringWithFormat:@"$%.2f",[[NSUserDefaults standardUserDefaults] doubleForKey:  [NSString stringWithFormat:@"%@_%@",currency,currentAcc]]*price];
        view.secondTextField2.stringValue = [NSString stringWithFormat:@"%.02f",[[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",currency,currentAcc]]];
        return view;
    }
    
    if ([tableColumn.identifier isEqualToString:@"Price"]) {
        PriceCell *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        
        if (prices[currency] != nil) {
            view.secondTextField.stringValue =  [NSString stringWithFormat:@"$%.2f", [prices[currency][@"USD"] doubleValue]];
        }
        
        view.taggy = row;
        
        NSString *avragePrice = [NSString stringWithFormat:@"%@_avgPrice",currency];
        
        double avg =  [prices[currency][@"USD"] doubleValue] - [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]];
        
        if ([[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]] != 0) {
        if (avg > 0) {
            view.secondTextField2.stringValue = [NSString stringWithFormat:@"+$%.2f",avg];
            view.secondTextField2.textColor = [NSColor greenColor];
        } else {
          view.secondTextField2.stringValue =  [NSString stringWithFormat:@"$%.2f",avg];
            view.secondTextField2.textColor = [NSColor redColor];
        }
        } else {
            view.secondTextField2.stringValue =  @"";
        }
        
        return view;
    }
    
 

    /*
    
    NSTableHeaderCell *headercell = [[NSTableHeaderCell alloc]init];
    headercell.title = @"New Title";
    headercell.backgroundColor = [NSColor orangeColor];
    headercell.drawsBackground = true;
    headercell.bordered = false;
   // headercell.font = NSFont(name: "Helvetica", size: 16)
    tableColumn.headerCell = headercell;
     
     */
    
    return [[NSView alloc] init];
    
}

-(void)saveCurrencies {
      [[NSUserDefaults standardUserDefaults] setObject:currencies forKey: [NSString stringWithFormat:@"%@_%@",@"holdings",currentAcc] ];
}

- (void)clickedRowS {
    
    NSLog(@"%@",[filteredArray objectAtIndex:self.searchTableView.clickedRow]);
   
    if ([currencies containsObject:[filteredArray objectAtIndex:self.searchTableView.clickedRow]]) {
        return;
    }
    
    [currencies addObject:[filteredArray objectAtIndex:self.searchTableView.clickedRow]];
    
    [self saveCurrencies];
    
    [self downloadPrices];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.searchView.animator.alphaValue = 0;
    } completionHandler:^{
                            
          self.mainView.hidden = NO;
          self.searchView.hidden =  YES;
        
    }];
     
    
    
   }

- (void)clickedRowA {
    
    [[NSUserDefaults standardUserDefaults] setValue:[accountsArray objectAtIndex:self.accountsTableView.clickedRow] forKey:@"currentAcc"];
    
    
    self.account.stringValue = [accountsArray objectAtIndex:self.accountsTableView.clickedRow];
    
    currentAcc = [accountsArray objectAtIndex:self.accountsTableView.clickedRow];
    
    currencies = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"%@_%@",@"holdings",currentAcc]]];
    
    [self.tableView reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.accountsView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = NO;
                            self.accountsView.hidden =  YES;
                            
                            
                        }];

}

-(void)clickedRow {
    
    NSLog(@"%d",self.tableView.clickedRow);
    
    clickedRow = self.tableView.clickedRow;
    
    [self getTrasactionHistory:[currencies objectAtIndex:self.tableView.clickedRow]];
    [self.infoTableview reloadData];
    
    // Update data
    
    NSString *currency = [currencies objectAtIndex:self.tableView.clickedRow];
    
    double price = [prices[currency][@"USD"] doubleValue];
    self.holdings.stringValue = [NSString stringWithFormat:@"$%.2f",[[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",currency,currentAcc]]*price];
    
    NSString *avragePrice = [NSString stringWithFormat:@"%@_avgPrice",currency];
    
    double avg = [prices[currency][@"USD"] doubleValue] - [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]];
    
    if ([[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]] != 0) {
        if (avg > 0) {
            self.profitOrLoss.stringValue = [NSString stringWithFormat:@"+$%.2f",avg];
            self.profitOrLoss.textColor = [NSColor greenColor];
        } else {
            self.profitOrLoss.stringValue =  [NSString stringWithFormat:@"-$%.2f",fabs(avg)];
            self.profitOrLoss.textColor = [NSColor redColor];
        }
    } else {
        self.profitOrLoss.stringValue =  @"";
    }
    
   
    
    self.netLoss.stringValue = [NSString stringWithFormat:@"$%.2f", [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]]];

    
    
    

    self.name.stringValue = [currencies objectAtIndex:self.tableView.clickedRow];
    self.imageInfo.image = [NSImage imageNamed:[currencies objectAtIndex:self.tableView.clickedRow]];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.infoView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                             self.mainView.hidden = YES;
                             self.infoView.hidden = NO;
        }];
    
    
    
}



-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    
    if (tableView == self.accountsTableView) {
        
        return [accountsArray count];
        
    }
    
    if (tableView == self.searchTableView) {
        return [filteredArray count];
    }
    
    if (tableView == self.infoTableview) {
        return [transactionArray count];
    }
    
    return [currencies count];
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

- (IBAction)backDonate:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.donateView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                             self.donateView.hidden = true;
                            self.mainView.hidden = false;
                        }];
    
}

- (IBAction)backInfoView:(id)sender {
    
    [self downloadPrices];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.infoView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self.mainView.hidden = NO;
                            self.infoView.hidden = TRUE;
                        }];
    
}

- (IBAction)backSearch:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.searchView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self.mainView.hidden = NO;
                            self.searchView.hidden = TRUE;
                        }];
    
}

- (IBAction)accounts:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.accountsView.animator.alphaValue = 1;
        
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = YES;
                            self.accountsView.hidden =  NO;
                            
                            [self.accountsTableView reloadData];
                            
                        }];
    
}

- (IBAction)hideBalances:(id)sender {
    
    
    
}

- (IBAction)share:(id)sender {
    
    NSAttributedString *text = [self.balance stringValue];
   // NSImage *image = [self.imageView image];
    NSArray * shareItems = [NSArray arrayWithObjects:text, nil];
    
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    service.delegate = self;
    [service performWithItems:shareItems];
    
}

-(void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items {
    
}

-(void)sharingService:(NSSharingService *)sharingService willShareItems:(NSArray *)items {
    
}

-(void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error {
    
}

- (IBAction)settings:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 0;
        self.settingsView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            
                            self.mainView.hidden = YES;
                            self.settingsView.hidden =  NO;

                        }];
    
}
- (IBAction)addAccountButton:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.accountsView.animator.alphaValue = 0;
        self.addAccountView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            
                            self.accountsView.hidden = YES;
                            self.addAccountView.hidden =  NO;

                        }];
    
}

- (IBAction)reload:(id)sender {
    
    [self downloadPrices];
    
}

- (IBAction)chart:(id)sender {
    
}

- (IBAction)hideSettings:(id)sender {
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.settingsView.animator.alphaValue = 0;
    } completionHandler:^{
                            
            self.mainView.hidden = NO;
            self.settingsView.hidden =  YES;
        
     }];
    
}



- (IBAction)addB:(id)sender {
}

- (IBAction)save:(id)sender {
    
    [accountsArray addObject:self.addAccTextField.stringValue];
    
    [self saveAccounts];
    
    self.account.stringValue = self.addAccTextField.stringValue;
    
    self.addAccTextField.stringValue = @"";
    
    [self.accountsTableView reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.accountsView.animator.alphaValue = 1;
        self.addAccountView.animator.alphaValue = 0;
    }
        completionHandler:^{
                            
        self.accountsView.hidden = NO;
        self.addAccountView.hidden =  YES;
            
    }];
    
    
}

- (float)calculateHoldingsFor:(NSString *) name {
    
    NSString *string = [NSString stringWithFormat:@"%@_history",name];
    
    NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    NSMutableArray *transactionHistory = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    
    double sum = 0;
    double avgPrice = 0;
    
    for (NSDictionary *d in transactionHistory) {
        
        sum += [d[@"quantity"] doubleValue];
        avgPrice += [[self getRealPrice: d[@"price"]] doubleValue];
        
    }
    
    avgPrice = avgPrice/transactionHistory.count;
    
    NSString *avragePrice = [NSString stringWithFormat:@"%@_avgPrice",name];
    
    if (transactionHistory.count != 0) {
         [[NSUserDefaults standardUserDefaults] setDouble:avgPrice forKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]];
    }
    
    [[NSUserDefaults standardUserDefaults] setDouble:sum forKey: [NSString stringWithFormat:@"%@_%@",name,currentAcc]];
    
    return sum;
    
}

-(NSMutableArray *)getTrasactionHistory:(NSString *) name {
    
    NSString *string = [NSString stringWithFormat:@"%@_history",name];
    
    NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    transactionArray = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    return transactionArray;
    
}

- (IBAction)saveTransaction:(id)sender {
    
    NSString *string = [NSString stringWithFormat:@"%@_history",self.currencyName.stringValue];
    
    NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    NSMutableArray *transactionHistory = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    if (transactionHistory == nil) {
        transactionHistory = [[NSMutableArray alloc] init];
    }
    
    NSString *quantity = self.Quantity.stringValue;
    
    if (sell == true) {
        quantity = [NSString stringWithFormat:@"-%@",self.Quantity.stringValue];
    }

    if (remove == true) {
        [transactionHistory removeObjectAtIndex:clickedRow2];
        remove = false;
    }
    
    [transactionHistory addObject:@{@"quantity":quantity, @"price":self.sell.stringValue,  @"notes":self.notes.stringValue}];
    
    NSString *hist = [NSString stringWithFormat:@"%@_history",self.currencyName.stringValue];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:transactionHistory] forKey: [NSString stringWithFormat:@"%@_%@",hist,currentAcc]];
    
    // calculate holdings and avrage price and save to disk
    [self calculateHoldingsFor:self.currencyName.stringValue];
    
    transactionArray = transactionHistory;
    
    
    // update transactions
    NSString *currency = self.currencyName.stringValue;
    
    double price = [prices[currency][@"USD"] doubleValue];
    self.holdings.stringValue = [NSString stringWithFormat:@"$%.2f",[[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",currency,currentAcc]]*price];
    
    NSString *avragePrice = [NSString stringWithFormat:@"%@_avgPrice",currency];
    
    double avg = [prices[currency][@"USD"] doubleValue] - [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]];
    
    if ([[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]] != 0) {
        if (avg > 0) {
            self.profitOrLoss.stringValue = [NSString stringWithFormat:@"+$%.2f",avg];
            self.profitOrLoss.textColor = [NSColor greenColor];
        } else if (avg < 0) {
            self.profitOrLoss.stringValue =  [NSString stringWithFormat:@"-$%.2f",fabs(avg)];
            self.profitOrLoss.textColor = [NSColor redColor];
        } else {
            self.profitOrLoss.stringValue =  [NSString stringWithFormat:@"$%.2f",fabs(avg)];
            self.profitOrLoss.textColor = [NSColor redColor];
        }
    } else {
        self.profitOrLoss.stringValue =  @"";
    }
    
    self.netLoss.stringValue = [NSString stringWithFormat:@"$%.2f", [[NSUserDefaults standardUserDefaults] doubleForKey: [NSString stringWithFormat:@"%@_%@",avragePrice,currentAcc]]];
    
    
    // hide view
    
    [self.infoTableview reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.addTransactionView.animator.alphaValue = 0;
        self.infoView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.addTransactionView.hidden = YES;
                            self.infoView.hidden = NO;
                        }];
    
    
}

- (IBAction)transactionBack:(id)sender {
    
    [self.infoTableview reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.addTransactionView.animator.alphaValue = 0;
        self.infoView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.addTransactionView.hidden = YES;
                            self.infoView.hidden = NO;
                        }];
    
}

- (IBAction)buy:(id)sender {
    
     sell = false;
    
    self.buyButton.image = [NSImage imageNamed:@"buy_selected"];
    self.sellButton.image = [NSImage imageNamed:@"sell_unselected"];

    
}

- (IBAction)sell:(id)sender {
    
    
    sell = true;
    
    self.sellButton.image = [NSImage imageNamed:@"sell_selected"];
    self.buyButton.image = [NSImage imageNamed:@"buy_unselected"];
    
    
    
}

- (IBAction)deleteCurrency:(id)sender {
    
    [currencies removeObjectAtIndex:clickedRow];
    
    [self saveCurrencies];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.mainView.animator.alphaValue = 1;
        self.infoView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self.mainView.hidden = NO;
                            self.infoView.hidden = TRUE;
                        }];

    
    [self.tableView reloadData];
    
    
}


- (IBAction)addTransaction:(id)sender {
    
   
    
    self.currencyName.stringValue = self.name.stringValue;
    self.sell.stringValue = prices[self.name.stringValue][@"USD"];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.addTransactionView.animator.alphaValue = 1;
        self.infoView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                            self.addTransactionView.hidden = NO;
                            self.infoView.hidden = TRUE;
                        }];
    
}


- (IBAction)saveAlert:(id)sender {
    
     NSString *string = [NSString stringWithFormat:@"%@_alerts",selectedCurrency];

    
    NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    NSMutableArray *alerts = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    if (alerts == nil) {
        alerts = [[NSMutableArray alloc] init];
    }
    
    NSString *repeat2 = @"NO";
    
    if (repeat == true) {
        repeat2 = @"YES";
    }
    
    NSString *type;
    
    if ([prices[selectedCurrency][@"USD"] doubleValue] > [self.alertTextField.stringValue doubleValue]) {
        type = @"Under";
    } else {
        type = @"Over";
    }
    
    [alerts addObject:@{@"repeat":repeat2, @"price":self.alertTextField.stringValue,  @"type":type}];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:alerts] forKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.alertView.animator.alphaValue = 0;
        self.mainView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.alertView.hidden = YES;
                            self.mainView.hidden = NO;
                        }];

}




- (IBAction)once:(id)sender {
    
    repeat = false;
    
    self.Once.image = [NSImage imageNamed:@"once"];
    self.repeat.image = [NSImage imageNamed:@"repeat_unselected"];
    
}

- (IBAction)repeat:(id)sender {
    
    repeat = true;
    
    self.Once.image = [NSImage imageNamed:@"once_unselected"];
    self.repeat.image = [NSImage imageNamed:@"repeat"];
    
}



- (IBAction)deleteTransaction:(id)sender {
    
    NSString *hist = [NSString stringWithFormat:@"%@_history",self.currencyName.stringValue];
    
    NSString *string = [NSString stringWithFormat:@"%@_history",self.currencyName.stringValue];
    
    NSData *archive = [[NSUserDefaults standardUserDefaults] valueForKey: [NSString stringWithFormat:@"%@_%@",string,currentAcc]];
    
    NSMutableArray *transactionHistory = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    [transactionHistory removeObjectAtIndex:clickedRow2];
    
    transactionArray = transactionHistory;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:transactionHistory] forKey: [NSString stringWithFormat:@"%@_%@",hist,currentAcc]];
    
    [self.infoTableview reloadData];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        self.addTransactionView.animator.alphaValue = 0;
        self.infoView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.addTransactionView.hidden = YES;
                            self.infoView.hidden = NO;
                        }];
    
}

@end
