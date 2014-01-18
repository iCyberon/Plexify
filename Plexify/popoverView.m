//
//  popoverView.m
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/7/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import "popoverView.h"

@implementation popoverView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect
{
    NSRect rect = NSMakeRect([self bounds].origin.x, [self bounds].origin.y + 32, [self bounds].size.width, [self bounds].size.height - 32);
	
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:4.0 yRadius:4.0];
    [path addClip];
    [[NSColor controlColor] set];
    NSRectFill(rect);
	
	NSGradient* aGradient = [[NSGradient alloc]
							 initWithStartingColor:[NSColor colorWithCalibratedRed:0.94f green:0.94f blue:0.94f alpha:1.00f]
							 endingColor:[NSColor colorWithCalibratedRed:0.76f green:0.76f blue:0.76f alpha:1.00f]];
    [aGradient drawInRect:rect angle:270];
	
	NSRect rect_2 = NSMakeRect([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, 36);
	
	[[NSImage imageNamed:@"bottom"] drawInRect:rect_2 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	
    [super drawRect:dirtyRect];
}

@end
