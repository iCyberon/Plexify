//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Settings.h"
#import "BETaskHelper.h"

@interface PCPopoverController : NSViewController <BETaskHelperDelegate> {
	BETaskHelper *taskHelper;
	Settings *settingsWindow;
	BOOL isTaskRunning;
	NSDate *startTime;
}

+ (PCPopoverController*)sharedInstance;

@property (strong) IBOutlet NSButton *playButton;
@property (strong) IBOutlet NSSegmentedControl *segmentedPlay;

@property (assign) IBOutlet NSButton *startServer;
@property (assign) IBOutlet NSButton *restartServer;
- (IBAction)startStopServer:(id)sender;
- (IBAction)doRestartServer:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)quitApp:(id)sender;

// UI
@property (assign) IBOutlet NSImageView *runningImage;
@property (assign) IBOutlet NSTextField *runningText;

- (IBAction)openAboutWindow:(id)sender;

- (NSString*)getStartTime;
- (BOOL)isTaskRunning;

@end
