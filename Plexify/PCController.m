//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import "PCController.h"
#import "PCAppDelegate.h"
#import "PCMenulet.h"
#import "PCPopoverController.h"
#import "NSPopover+Message.h"

static PCController *sharedInstance;

@implementation PCController

@synthesize active;
@synthesize popover;



-(id)init
{
    if(sharedInstance)
        NSLog(@"Error: You are creating a second AppDelegate");
    sharedInstance = self;
    return self;
}

+ (PCController*)sharedInstance
{
    return sharedInstance;
}

- (void)_setupPopover
{
    if (!self.popover) {
		//NSLog(@"Setup Popover!");
        self.popover = [[INPopoverController alloc] init];
        self.popover.contentViewController = [[PCPopoverController alloc] init];
        self.popover.contentSize = (CGSize){200, 125};
		self.popover.borderColor = [NSColor clearColor];
		self.popover.borderWidth = 0.1;
		self.popover.color = [NSColor colorWithCalibratedRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    }
}

- (void)changeIconToActive
{
	self.active = YES;
}

- (void)changeIconToPassive
{
	self.active = NO;
}

- (void)initPopover {
	[self _setupPopover];
}

- (void)menuletClicked
{
    PCAppDelegate *appDelegate = [NSApp delegate];
    if (!self.popover.popoverIsVisible) {
        [self _setupPopover];
        [self.popover presentPopoverFromRect:[appDelegate.menulet frame]
                                  inView:appDelegate.menulet
                           preferredArrowDirection:INPopoverArrowDirectionUp
												anchorsToPositionView:YES];
    } else {
        [self.popover closePopover:self];
    }
}

@end
