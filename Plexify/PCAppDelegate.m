//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import "PCAppDelegate.h"
#import "PCMenulet.h"
#import "PCController.h"
#import "NSHost+IPv4.h"
#import <ObjectiveGit/ObjectiveGit.h>
#import "NSAlert+Blocks.h"

#define kPlexDirectory @"plexDirectory"

@implementation PCAppDelegate

@synthesize window = _window;
@synthesize menulet;
@synthesize item;
@synthesize controller;

BOOL outputEmpty;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
    self.menulet = [[PCMenulet alloc] initWithFrame:(NSRect){.size={thickness, thickness}}];
    self.controller = [[PCController alloc] init];
    self.menulet.delegate = self.controller;
    [self.item setView:self.menulet];        
    [self.item setHighlightMode:YES];
	
	// Let's init popover controller
	[[PCController sharedInstance] initPopover];
	
	// Check if we have leftovers from earlier version
	NSString *oldInstallPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/PlexConnect-master"];
	BOOL installExist = [[NSFileManager defaultManager] fileExistsAtPath:oldInstallPath];
	
	if (installExist) {
		NSFileManager* fm = [[NSFileManager alloc] init];
		NSString *oldCertPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/PlexConnect-master/assets/certificates/trailers.pem"];
		BOOL certExist = [[NSFileManager defaultManager] fileExistsAtPath:oldCertPath];
		if (certExist) {
			// Save Certificates?
			[NSAlert showSheetModalForWindow:self.window
									 message:@"Certificates Found, do you want to use them?"
							 informativeText:@"We found certificate files from previous installation. Do you want to preserve them and use with the new version?\nClick YES to save them and NO to delete"
								  alertStyle:NSWarningAlertStyle
						   cancelButtonTitle:@"No"
						   otherButtonTitles:@[@"Yes, keep certificates"]
								   onDismiss:^(int buttonIndex)  {
									   NSString *newCertsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/"];
									   NSString *certsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/PlexConnect-master/assets/certificates/"];
									   NSFileManager *fm = [NSFileManager defaultManager];
									   [fm createDirectoryAtPath:newCertsDir withIntermediateDirectories:YES attributes:nil error:nil];
									   if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.cer"]])
										   [fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.cer"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.cer"] error:nil];
									   
									   if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.pem"]])
										   [fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.pem"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.pem"] error:nil];
									   
									   if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.key"]])
										   [fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.key"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.key"] error:nil];
									   
									   NSDirectoryEnumerator* en = [fm enumeratorAtPath:oldInstallPath];
									   NSError* err = nil;
									   BOOL res;
									   
									   NSString* file;
									   while (file = [en nextObject]) {
										   res = [fm removeItemAtPath:[oldInstallPath stringByAppendingPathComponent:file] error:&err];
										   if (!res && err) {
											   NSLog(@"oops: %@", err);
										   }
									   }
									   
									   res = [fm removeItemAtPath:oldInstallPath error:&err];
									   if (!res && err) {
										   NSLog(@"oops: %@", err);
									   }
								   }
									onCancel:^ {
										NSDirectoryEnumerator* en = [fm enumeratorAtPath:oldInstallPath];
										NSError* err = nil;
										BOOL res;
										
										NSString* file;
										while (file = [en nextObject]) {
											res = [fm removeItemAtPath:[oldInstallPath stringByAppendingPathComponent:file] error:&err];
											if (!res && err) {
												NSLog(@"oops: %@", err);
											}
										}
										res = [fm removeItemAtPath:oldInstallPath error:&err];
										if (!res && err) {
											NSLog(@"oops: %@", err);
										}
									}];
		}
	}
	
	NSString *plexifyBash = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/Plexify.bash"];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:plexifyBash];
	
	if (!fileExists) {
		// Show welcome window
		welcomeWindow = [[WelcomeWindow alloc] initWithWindowNibName:@"WelcomeWindow"];
		
		[welcomeWindow showWindow:nil];
		[[NSApp mainWindow] makeKeyWindow];
		[[welcomeWindow window] orderFront:nil];
	} else {
		// hack :(
		NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
		path = [NSString stringWithFormat:@"--git-dir=%@/.git",path];
		NSTask *t = [[NSTask alloc] init];
		[t setLaunchPath:@"/usr/bin/git"];
		[t setArguments:[NSArray arrayWithObjects:path, @"pull", nil]];
		[t launch];
	}
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL *shouldStartPlexConnect = [ud boolForKey:@"shouldStartPlexConnect"];
	BOOL *shouldStartPlexConnectOnlyAtStartUp = [ud boolForKey:@"shouldStartPlexConnectOnlyAtStartUp"];
	
	// app was launched as a login item
	NSAppleEventDescriptor* event = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
	if ([event eventID] == kAEOpenApplication &&
		[[event paramDescriptorForKeyword:keyAEPropData] enumCodeValue] == keyAELaunchedAsLogInItem)
	{
		if (shouldStartPlexConnect) {
			//NSLog(@"Start PlexConnect");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"StartServer" object:self];
		}
	}
	
	if (shouldStartPlexConnect && !shouldStartPlexConnectOnlyAtStartUp) {
		//NSLog(@"Start PlexConnect");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartServer" object:self];
	}
}

@end
