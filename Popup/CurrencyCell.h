//
//  CurrencyCell.h
//  
//
//  Created by Fredrik Bixo on 2018-01-24.
//

#import <Cocoa/Cocoa.h>

@interface CurrencyCell : NSTableCellView

@property (assign) IBOutlet NSTextField *secondTextField;
@property (weak) IBOutlet NSImageView *btc;


@end
