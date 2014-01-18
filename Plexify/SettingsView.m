//
//  SettingsView.m
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/8/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import "SettingsView.h"

@implementation SettingsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSGradient* aGradient = [[NSGradient alloc]
							 initWithStartingColor:[NSColor whiteColor]
							 endingColor:[NSColor colorWithCalibratedRed:0.96f green:0.96f blue:0.96f alpha:1.00f]];
    [aGradient drawInRect:[self bounds] angle:270];
}

- (BOOL)mouseDownCanMoveWindow {
	return NO;
}

-(void)mouseDown:(NSEvent *)theEvent {
    NSRect  windowFrame = [[self window] frame];
	
    initialLocation = [NSEvent mouseLocation];
	
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint currentLocation;
    NSPoint newOrigin;
	
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
	
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
	
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
	
    //go ahead and move the window to the new location
    [[self window] setFrameOrigin:newOrigin];
}

@end
