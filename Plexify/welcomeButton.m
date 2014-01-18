//
//  welcomeButton.m
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/5/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import "welcomeButton.h"

@implementation welcomeButton

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	
	CGFloat roundedRadius = 4.0f;
	
	if ([self isEnabled]) {
		// Dark stroke
		[ctx saveGraphicsState];
		[[NSColor colorWithCalibratedRed:0.8f green:0.8f blue:0.8f alpha:1.00f] setStroke];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.f, 2.f)
										 xRadius:roundedRadius
										 yRadius:roundedRadius] stroke];
		[ctx restoreGraphicsState];
	} else {
		[ctx saveGraphicsState];
		[[NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.00f] setStroke];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.f, 2.f)
										 xRadius:roundedRadius
										 yRadius:roundedRadius] stroke];
		[ctx restoreGraphicsState];
	}
	
	// Draw darker overlay if button is pressed
	if([self isHighlighted]) {
		[ctx saveGraphicsState];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
										 xRadius:roundedRadius
										 yRadius:roundedRadius] setClip];
		[[NSColor colorWithCalibratedWhite:0.2f alpha:0.02] setFill];
		NSRectFillUsingOperation(frame, NSCompositeSourceOver);
		[ctx restoreGraphicsState];
	}
}


@end
