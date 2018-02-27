//
//  PriceCell.m
//  Popup
//
//  Created by Fredrik Bixo on 2018-01-24.
//

#import "PriceCell.h"

@implementation PriceCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)alertBellPressed:(id)sender {
    
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
    NSLog(@"pressed");
}


@end
