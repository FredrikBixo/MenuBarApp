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
    
    
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",self.searchTextField2.stringValue];
    filteredArray = [currenciesNames filteredArrayUsingPredicate:bPredicate];
    NSLog(@"HERE %@",filteredArray);
    
    
    [self.searchTableView reloadData];
    
}

#pragma mark -

-(void)calculateHoldings{

    double portfolioValue = 0;
    
    for (NSString *currency in currencies) {
        
          double price = [prices[currency][@"USD"] doubleValue];
          portfolioValue += price*[[NSUserDefaults standardUserDefaults] doubleForKey:currency];
        
    }
    
    self.balance.stringValue = [NSString stringWithFormat:@"%.02f $", portfolioValue];
    
}

-(void)getAllCoins{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.cryptocompare.com/api/data/coinlist/"]]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        allcoins = resp[@"Data"];
        currenciesNames = [[NSMutableArray alloc]initWithArray:[allcoins allKeys]];
        dispatch_async(dispatch_get_main_queue(), ^{
            // do work hereg
            
         
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
            
            [self.tableView reloadData];
        });
        
        NSLog(@"Request reply: %@", prices);
        
    }] resume];

}

-(void)setup {
    
    [self.window.contentView addSubview:self.mainView];
    [self.window.contentView addSubview:self.donareView];
    [self.window.contentView addSubview:self.infoView];
    [self.window.contentView addSubview:self.searchView];
    [self.window.contentView addSubview:self.alertView];
    [self.window.contentView addSubview:self.accountsView];
    [self.window.contentView addSubview:self.settingsView];
    [self.window.contentView addSubview:self.addAccountView];
    self.donareView.alphaValue = 0;
    self.searchView.alphaValue = 0;
    self.accountsView.alphaValue = 0;
    self.settingsView.alphaValue = 0;
    self.addAccountView.alphaValue = 0;
    self.infoView.alphaValue = 0;
    self.alertView.alphaValue = 0;
    self.donareView.hidden = true;
    self.searchView.hidden = true;
    self.infoView.hidden = true;
    self.alertView.hidden = true;
    self.accountsView.hidden = true;
    self.settingsView.hidden = true;
    self.addAccountView.hidden = true;
    
  //  [self.tableView removeTableColumn:self.column];
    self.searchTextField2.delegate = self;

    [[NSUserDefaults standardUserDefaults] setDouble:0.3 forKey:@"BTC"];
    [[NSUserDefaults standardUserDefaults] setDouble:100 forKey:@"ADA"];
    [[NSUserDefaults standardUserDefaults] setDouble:160 forKey:@"OMG"];
    [[NSUserDefaults standardUserDefaults] setDouble:30 forKey:@"NEO"];
    
    [[NSUserDefaults standardUserDefaults] setDouble:0.3 forKey:@"BTC_BuyPrice"];
    [[NSUserDefaults standardUserDefaults] setDouble:100 forKey:@"ADA_BuyPrice"];
    [[NSUserDefaults standardUserDefaults] setDouble:160 forKey:@"OMG_BuyPrice"];
    [[NSUserDefaults standardUserDefaults] setDouble:30 forKey:@"NEO_BuyPrice"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"holdings"] == nil) {
       [[NSUserDefaults standardUserDefaults] setObject:[[NSArray alloc]initWithObjects:@"BTC",@"OMG",@"ADA",@"NEO", nil] forKey:@"holdings"];
    }
    
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
    currencies = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"holdings"]];
    self.account.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentAcc"];
    
    filteredArray = [[NSMutableArray alloc] init];
    
    accountsArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"]];
    
    if ([accountsArray count] == 0) {
        
        accountsArray = [[NSMutableArray alloc] init];
        
    }
    
    [self downloadPrices];

    [self.searchTableView setCornerView:nil];
    [self.searchTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [tableView setCornerView:nil];
    
    [self.accountsTableView setCornerView:nil];
    [self.accountsTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.accountsTableView setCornerView:nil];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:true block:^(NSTimer *timer) {
        
        [self downloadPrices];
        
    }];
    
    [self.tableView reloadData];
    
    self.accountsTableView.dataSource = self;
    self.accountsTableView.delegate = self;
    
    [self.tableView setAction:@selector(clickedRow)];
    [self.tableView setTarget:self];
    
    [self.searchTableView setAction:@selector(clickedRowS)];
    [self.searchTableView setTarget:self];
    
    [self.accountsTableView setAction:@selector(clickedRowA)];
    [self.accountsTableView setTarget:self];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    
    NSClickGestureRecognizer *rec = [[NSClickGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    
    [self.moreMenu addGestureRecognizer:rec];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];

    
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
        NSLog (@"Successfully received the test notification! %d", self.tableView.selectedRow);
    
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
        self.donareView.animator.alphaValue = 1;
    }
                        completionHandler:^{
                            self.mainView.hidden = true;
                            self.donareView.hidden = false;
                        }];
    

    
}



- (IBAction)alertBack:(id)sender {
    
    
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

#pragma mark - TableView Data Source and Delegate

-(NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

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
        view.secondTextField.stringValue = [NSString stringWithFormat:@"%.2f $",[[NSUserDefaults standardUserDefaults] doubleForKey:currency]*price];
        view.secondTextField2.stringValue = [NSString stringWithFormat:@"%.02f",[[NSUserDefaults standardUserDefaults] doubleForKey:currency]];
        return view;
    }
    
    if ([tableColumn.identifier isEqualToString:@"Price"]) {
        PriceCell *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        
        if (prices[currency] != nil) {
        view.secondTextField.stringValue = prices[currency][@"USD"];
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
      [[NSUserDefaults standardUserDefaults] setObject:currencies forKey:@"holdings"];
}

- (void)clickedRowS {
    
    NSLog(@"%@",[filteredArray objectAtIndex:self.searchTableView.clickedRow]);
   
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
    
   self.account.stringValue = [accountsArray objectAtIndex:self.accountsTableView.clickedRow];
    [[NSUserDefaults standardUserDefaults] setValue:[accountsArray objectAtIndex:self.accountsTableView.clickedRow] forKey:@"currentAcc"];
    
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
        self.donareView.animator.alphaValue = 0;
    }
                        completionHandler:^{
                             self.donareView.hidden = true;
                            self.mainView.hidden = false;
                        }];
    
}

- (IBAction)backInfoView:(id)sender {
    
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


@end
