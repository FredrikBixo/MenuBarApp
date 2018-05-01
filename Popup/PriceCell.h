//
//  PriceCell.h
//  Popup
//
//  Created by Fredrik Bixo on 2018-01-24.
//

#import <Cocoa/Cocoa.h>

@interface PriceCell : NSTableCellView

@property (assign) IBOutlet NSTextField *secondTextField;
@property (assign) IBOutlet NSTextField *secondTextField2;
@property (assign) int taggy;

- (IBAction)alertBellPressed:(id)sender;

@end
