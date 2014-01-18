//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import "PCPopoverController.h"
#import "Settings.h"
#import "BETaskHelper.h"
#include <signal.h>
#include <unistd.h>
#include "SSKeychain.h"
#include "NSFileManager+DirectoryLocations.h"
#include "PCController.h"
#include "PCMenulet.h"
#include "STPrivilegedTask.h"
#include "NSAlert+Blocks.h"

#define kPlexDirectory @"plexDirectory"

static PCPopoverController *sharedInstance;

@implementation PCPopoverController

BOOL outputEmpty;
NSFileHandle* readHandle;
BOOL stopping;
BOOL starting;
BOOL restarting;

BOOL checkWorking;

int retry_cnt = 0;

-(id)init
{
    if(sharedInstance)
        NSLog(@"Error: You are creating a second AppDelegate");
    sharedInstance = [self initWithNibName:@"PCPopoverController" bundle:nil];
    return self;
}

+ (PCPopoverController*)sharedInstance
{
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PCPopoverController" bundle:nibBundleOrNil];
    if (self) {
		[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(checkStatus) userInfo:nil repeats:NO];
		checkWorking = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(startServer:)
													 name:@"StartServer"
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stopServer:)
													 name:@"StopServer"
												   object:nil];
    }
    
    return self;
}

- (void)startServer:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"StartServer"])
		[self startStopServer:nil];
}


- (void)stopServer:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"StopServer"] && isTaskRunning)
		[self startStopServer:nil];
}

- (IBAction)startStopServer:(id)sender {
	if (([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) != 0) {
		[self doRestartServer:sender];
	} else if (([[NSApp currentEvent] modifierFlags] & NSControlKeyMask) != 0) {
		NSLog(@"FORCE KILL!!!");
		[STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/usr/bin/sudo" arguments:[NSArray arrayWithObjects:@"killall",@"-9", @"python", nil]];
	} else {
		if (!isTaskRunning) {
			startTime = [NSDate date];
			
			NSString *plexConnectPy = [[NSFileManager defaultManager] applicationSupportDirectory];
			plexConnectPy = [NSString stringWithFormat:@"%@/%@",plexConnectPy,@"Plexify.bash"];
			
			// Setup task
			NSTask *task = [[NSTask alloc] init];

			[task setLaunchPath:@"/usr/bin/sudo"];
			[task setArguments:[NSArray arrayWithObjects:@"-S",plexConnectPy,@"start", nil]];
			
			taskHelper = [[BETaskHelper alloc] initWithDelegate:self forTask:task];
			[taskHelper launchTask];
			
			starting = YES;
			[self.startServer setEnabled:NO];
			[self.playButton setEnabled:NO];
		} else {
			[self killProcessesNamed:@""];
			stopping = YES;
			[self.playButton setEnabled:NO];
		}
	}
}

-(void)checkStatus
{
	if (checkWorking) {
		NSString *plexConnectPy = [[NSFileManager defaultManager] applicationSupportDirectory];
		plexConnectPy = [NSString stringWithFormat:@"%@/%@",plexConnectPy,@"Plexify.bash"];
		
		// Setup task
		NSTask *task = [[NSTask alloc] init];
		
		[task setLaunchPath:@"/usr/bin/sudo"];
		[task setArguments:[NSArray arrayWithObjects:@"-S",plexConnectPy,@"status", nil]];
		
		taskHelper = [[BETaskHelper alloc] initWithDelegate:self forTask:task];
		[taskHelper launchTask];
		
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkStatus) userInfo:nil repeats:NO];
	}
}

-(void)killProcessesNamed:(NSString*)appName
{
	NSString *plexConnectPy = [[NSFileManager defaultManager] applicationSupportDirectory];
	plexConnectPy = [NSString stringWithFormat:@"%@/%@",plexConnectPy,@"Plexify.bash"];
	
	// Setup task
	NSTask *task = [[NSTask alloc] init];
	
	[task setLaunchPath:@"/usr/bin/sudo"];
	[task setArguments:[NSArray arrayWithObjects:@"-S",plexConnectPy,@"stop", nil]];
	
	taskHelper = [[BETaskHelper alloc] initWithDelegate:self forTask:task];
	[taskHelper launchTask];
}

- (IBAction)doRestartServer:(id)sender {
	if (isTaskRunning) {
		[self killProcessesNamed:@"Python"];
		restarting = YES;
	}
}

- (IBAction)openSettings:(id)sender {
	if (!settingsWindow)
		settingsWindow = [[Settings alloc] initWithWindowNibName:@"Settings"];
	
    [settingsWindow showWindow:nil];
    [[settingsWindow window] makeMainWindow];
}

- (IBAction)quitApp:(id)sender {
	if (isTaskRunning)
		[self killProcessesNamed:@"Python"];
	
	[NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2]; // Let's give some time to terminate plex server
}

#pragma mark BETaskHelper delegate methods

-(void) task:(NSTask *)task hasOutputAvailable:(NSString *)outputLine {
    // Log all output
    //NSLog(@"%@", outputLine);
	
	if ([[task arguments] containsObject:@"status"]) {
		if ([outputLine isEqualToString:@"1"])
			[self taskIsRunning:YES];
		else if ([outputLine isEqualToString:@"0"])
			[self taskIsRunning:NO];
	}
	
    if ([outputLine rangeOfString:@"Password:"].location != NSNotFound) {
		NSString *pass = [NSString stringWithFormat:@"%@\n",[SSKeychain passwordForService:@"Plexify" account:@"Plexify"]];
		[taskHelper sendInput:pass];
    }
	
    if ([outputLine rangeOfString:@"incorrect password"].location != NSNotFound) {
        checkWorking = NO;
		NSLog(@"Wrong Admin Password!");
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Wrong Password!"];
		[alert setInformativeText:@"Please change password from settings and restart Plexify!"];
		[alert runModal];
    }
}

-(void) task:(NSTask *)task hasCompletedWithStatus:(int) status {
	
	if ([[task arguments] containsObject:@"start"]) {
		[self.startServer setEnabled:YES];
	}
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration
{
	long seconds = lroundf(duration); // Modulo (%) operator below needs int or long
	
	long hour = seconds / 3600;
	long mins = (seconds % 3600) / 60;
	long secs = seconds % 60;

    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, mins, secs];
}

//
- (void)taskIsRunning:(BOOL)running
{
	[self getStartTime];
	isTaskRunning = running;
	if (running) {
		[self.runningImage setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
		[self.runningText setStringValue:NSLocalizedString(@"PlexConnect is running", nil)];
		
		// Buttons
		[self.playButton setImage:[NSImage imageNamed:@"pauseButton@2x"]];
		[self.startServer setTitle:NSLocalizedString(@"Stop", nil)];
		[self.restartServer setEnabled:YES];
	} else {
		[self.playButton setImage:[NSImage imageNamed:@"playButton@2x"]];
		[self.runningImage setImage:[NSImage imageNamed:@"NSStatusNone"]];
		[self.runningText setStringValue:NSLocalizedString(@"PlexConnect is not running", nil)];
		
		// Buttons
		[self.startServer setTitle:NSLocalizedString(@"Start", nil)];
		[self.restartServer setEnabled:NO];
	}
	
	if (restarting && isTaskRunning) {
		[self.startServer setEnabled:NO];
		[self.restartServer setEnabled:NO];
		[self.playButton setEnabled:NO];
	}
	
	if (restarting && !isTaskRunning) {
		restarting = NO;
		[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(startStopServer:) userInfo:nil repeats:NO];
	}
	
	if ((starting && isTaskRunning) || (starting && retry_cnt > 4)) {
		[self.startServer setEnabled:YES];
		[self.playButton setEnabled:YES];
		starting = NO;
		retry_cnt = 0;
	}
	
	if ((stopping && !isTaskRunning) || (stopping && retry_cnt > 4)) {
		[self.startServer setEnabled:YES];
		[self.playButton setEnabled:YES];
		starting = NO;
		retry_cnt = 0;
	}
	
	if (starting || stopping) {
		retry_cnt++;
	}
	
}

- (NSString*)getStartTime {
	NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:startTime];
	
    return [self formattedStringForDuration:interval];
}
- (BOOL)isTaskRunning {
	return isTaskRunning;
}

- (IBAction)openAboutWindow:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Plexify 1.1 RC"];
	[alert setInformativeText:@"Plexify is developed by Vahagn Mkrtchyan (Cyberon).\nIt is free and always will be.\nEmail: vahagn.mkrtchyan@mit.edu"];
	[alert runModal];
}
@end