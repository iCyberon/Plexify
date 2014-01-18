//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "STPrivilegedTask.h"
#import "WelcomeWindow.h"
#import "NSFileManager+DirectoryLocations.h"

@class PCMenulet;
@class PCController;

@interface PCAppDelegate : NSObject <NSApplicationDelegate> {
	WelcomeWindow *welcomeWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) PCMenulet *menulet;
@property (nonatomic, strong) NSStatusItem *item;
@property (nonatomic, strong) PCController *controller;

@end
