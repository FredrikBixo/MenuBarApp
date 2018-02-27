//
//  MyHeaderCell.m
//  
//
//  Created by Fredrik Bixo on 2018-01-22.
//


#import "MyHeaderCell.h"


@implementation MyHeaderCell

- (void)drawWithFrame:(CGRect)cellFrame
          highlighted:(BOOL)isHighlighted
               inView:(NSView *)view
{
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:cellFrame];
    NSColor *clearColor = [NSColor clearColor];
    [clearColor setFill];
    [path fill];


    [self drawInteriorWithFrame:CGRectInset(cellFrame, 0.0, 1.0) inView:view];
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)view
{
    [self drawWithFrame:cellFrame highlighted:NO inView:view];
}

- (void)highlight:(BOOL)isHighlighted
        withFrame:(NSRect)cellFrame
           inView:(NSView *)view
{
    [self drawWithFrame:cellFrame highlighted:isHighlighted inView:view];
}

@end
