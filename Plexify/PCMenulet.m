//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import "PCMenulet.h"

static void *kActiveChangedKVO = &kActiveChangedKVO;

@implementation PCMenulet

@synthesize delegate;

+ (PCMenulet*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
	
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
	
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
	
    // returns the same object each time
    return _sharedObject;
}

- (void)setDelegate:(id<PCMenuletDelegate>)newDelegate
{
    [(NSObject *)newDelegate addObserver:self forKeyPath:@"active" options:NSKeyValueObservingOptionNew context:kActiveChangedKVO];
    delegate = newDelegate;
}

- (void)drawRect:(NSRect)rect 
{
#if WITHOUT_IMAGE
    rect = CGRectInset(rect, 2, 2);
    if ([self.delegate isActive]) {
        [[NSColor selectedMenuItemColor] set]; /* blueish */
    } else {
        [[NSColor textColor] set]; /* blackish */ 
    }
    NSRectFill(rect);
#else
    NSImage *menuletIcon;
    [[NSColor clearColor] set];
    if ([self.delegate isActive]) {
        menuletIcon = [NSImage imageNamed:@"_menuIconEnabled"];
    } else {
        menuletIcon = [NSImage imageNamed:@"_menuIconDisabled"];
    }
    [menuletIcon drawInRect:NSInsetRect(rect, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
#endif
}

- (void)mouseDown:(NSEvent *)event {
    [self.delegate menuletClicked];
}

- (void)needsRedraw
{
	[self setNeedsDisplay:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kActiveChangedKVO) {
        [self setNeedsDisplay:YES];
    }
}

@end
