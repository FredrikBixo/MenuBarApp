#import "BackgroundView.h"
#import "StatusItemView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource,NSTextFieldDelegate, NSGestureRecognizerDelegate>
{
    
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    NSDictionary *prices;
    
    NSMutableArray *currenciesNames;
    NSMutableArray *currencies;
    NSMutableArray *filteredArray;
    NSMutableArray *accountsArray;
    NSMutableArray *transactionArray;
    
    BOOL sell;
    BOOL repeat;
    
    NSString *selectedCurrency;
    
    NSTimer *updateTimer;
    NSInteger clickedRow;
    
    int hideBalances;
    
    NSString *currenctAccount;
    
    NSMutableDictionary *allcoins;
    
}

// Create Alert

@property (weak) IBOutlet NSTextField *alertTextField;
@property (weak) IBOutlet NSTextField *currentBtcPrice;
- (IBAction)saveAlert:(id)sender;
@property (weak) IBOutlet NSButton *Once;
@property (weak) IBOutlet NSButton *repeat;
- (IBAction)once:(id)sender;
- (IBAction)repeat:(id)sender;


// Transaction
@property (strong) IBOutlet NSView *addTransactionView;
@property (weak) IBOutlet NSTextField *Quantity;
@property (weak) IBOutlet NSTextField *notes;
- (IBAction)saveTransaction:(id)sender;
@property (weak) IBOutlet NSTextField *currencyName;
- (IBAction)transactionBack:(id)sender;
@property (weak) IBOutlet NSButton *buyButton;
@property (weak) IBOutlet NSButton *sellButton;


@property (weak) IBOutlet NSTextField *sell;

- (IBAction)buy:(id)sender;
- (IBAction)sell:(id)sender;

- (IBAction) deleteCurrency:(id)sender;

// Create Alert



@property (weak) IBOutlet NSButton *accountsB;
@property (weak) IBOutlet NSButton *shareB;
@property (weak) IBOutlet NSButton *settingsB;

// ADD ACC
- (IBAction)save:(id)sender;
@property (weak) IBOutlet NSTextField *addAccTextField;
- (IBAction)addTransaction:(id)sender;

// INFO
@property (weak) IBOutlet NSImageView *imageInfo;
@property (weak) IBOutlet NSTableColumn *column;
@property (weak) IBOutlet NSTableView *infoTableview;
@property (weak) IBOutlet NSTextField *profitOrLoss;
@property (weak) IBOutlet NSTextField *holdings;
@property (weak) IBOutlet NSTextField *netLoss;

// MORE MENU
@property (weak) IBOutlet NSView *moreMenu;

@property (weak) IBOutlet NSButton *settings;
@property (weak) IBOutlet NSButton *share;

- (IBAction)accounts:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)settings:(id)sender;

@property (strong) IBOutlet NSView *donareView;
@property (strong) IBOutlet NSView *searchView;
@property (strong) IBOutlet NSView *infoView;
@property (strong) IBOutlet NSView *mainView;
@property (strong) IBOutlet NSView *alertView;
@property (weak) IBOutlet NSTableView *accountsTableView;
@property (strong) IBOutlet NSView *addAccountView;
- (IBAction)addAccountButton:(id)sender;


- (IBAction)reload:(id)sender;
- (IBAction)chart:(id)sender;

@property (strong) IBOutlet NSView *settingsView;
@property (strong) IBOutlet NSView *accountsView;
@property (strong) IBOutlet NSView *createAlert;

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *balance;
@property (weak) IBOutlet NSTextField *plusToday;
@property (weak) IBOutlet NSTextField *account;

- (IBAction)plusButton:(id)sender;
- (IBAction)moreButton:(id)sender;

// DONATE

- (IBAction)donate:(id)sender;


- (IBAction)backDonate:(id)sender;



@property (weak) IBOutlet NSButton *backSearch;
@property (weak) IBOutlet NSButton *backDonate;



- (IBAction)hideSettings:(id)sender;

- (IBAction)addB:(id)sender;

// INFOVIEW
@property (weak) IBOutlet NSTextField *name;
- (IBAction)backInfoView:(id)sender;

@property (weak) IBOutlet NSSearchField *searchTextField;
// SEARCH

- (IBAction)backSearch:(id)sender;
@property (weak) IBOutlet NSTableView *searchTableView;
@property (weak) IBOutlet NSTextField *searchTextField2;

- (IBAction)alertBack:(id)sender;
@property (weak) IBOutlet NSButton *alertB;
- (IBAction)alertB:(id)sender;
- (IBAction)accountBack:(id)sender;
- (IBAction)addAccBack:(id)sender;



@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end
