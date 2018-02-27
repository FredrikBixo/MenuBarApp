//
//  MyHeaderCell.h
//  
//
//  Created by Fredrik Bixo on 2018-01-22.
//

#import <Foundation/Foundation.h>


@interface MyHeaderCell : NSTableHeaderCell
{
}

- (void)drawWithFrame:(CGRect)cellFrame
          highlighted:(BOOL)isHighlighted
               inView:(NSView *)view;

@end
