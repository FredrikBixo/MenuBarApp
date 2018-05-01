//
//  TransactionCell.h
//  Popup
//
//  Created by Fredrik Bixo on 2018-04-30.
//

#import <Cocoa/Cocoa.h>

@interface TransactionCell : NSTableCellView

@property (assign) IBOutlet NSTextField *bought;
@property (assign) IBOutlet NSTextField *price;
@property (assign) IBOutlet NSTextField *quantity;
@property (assign) IBOutlet NSTextField *notes;
@property (assign) IBOutlet NSTextField *descriptor;
@property (weak) IBOutlet NSImageView *sellorBuy;

@end
