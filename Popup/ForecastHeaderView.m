//
//  ForecastHeaderView.m
//  
//
//  Created by Fredrik Bixo on 2018-01-22.
//

#import "ForecastHeaderView.h"

@implementation ForecastHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
    NSColor *clearColor = [NSColor clearColor];
    [clearColor setFill];
    [path fill];


    // Drawing code here.
}



@end
