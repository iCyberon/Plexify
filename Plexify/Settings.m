//
//  Settings.m
//  PlexConnect
//
//  Created by Vahagn Mkrtchyan on 11/3/13.
//

#import "Settings.h"
#import "NSHost+IPv4.h"
#include "NSFileManager+DirectoryLocations.h"
#include "SSKeychain.h"
#include "PCPopoverController.h"
#include "NSAlert+Blocks.h"

#define kPlexDirectory @"plexDirectory"

@interface Settings ()

@end

@implementation Settings

@synthesize nwWebView;
@synthesize webWindow;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	// Initialization code here.
	INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
	
	INWindowButton *closeButton = [INWindowButton windowButtonWithSize:NSMakeSize(14, 14) groupIdentifier:nil];
    closeButton.activeImage = [NSImage imageNamed:@"main"];
    closeButton.activeNotKeyWindowImage = [NSImage imageNamed:@"main"];
    closeButton.inactiveImage = [NSImage imageNamed:@"main"];
    closeButton.pressedImage = [NSImage imageNamed:@"main"];
    closeButton.rolloverImage = [NSImage imageNamed:@"main"];
    aWindow.closeButton = closeButton;
	
	aWindow.titleBarStartColor = [NSColor whiteColor];
	aWindow.titleBarEndColor = [NSColor whiteColor];
	aWindow.baselineSeparatorColor = [NSColor whiteColor];
	aWindow.inactiveBaselineSeparatorColor = [NSColor whiteColor];
	aWindow.inactiveTitleBarEndColor = [NSColor whiteColor];
	aWindow.inactiveTitleBarStartColor = [NSColor whiteColor];
	aWindow.titleBarHeight = 30.f;
	aWindow.centerTrafficLightButtons = NO;
	aWindow.trafficLightButtonsTopMargin = 12.f;
	aWindow.trafficLightButtonsLeftMargin = 11.f;
	
	[[aWindow standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
	[[aWindow standardWindowButton:NSWindowZoomButton] setHidden:YES];
	self.titleView.frame = aWindow.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[aWindow.titleBarView addSubview:self.titleView];
	
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL *shouldStartPlexConnect = [ud boolForKey:@"shouldStartPlexConnect"];
	BOOL *shouldStartPlexConnectOnlyAtStartUp = [ud boolForKey:@"shouldStartPlexConnectOnlyAtStartUp"];
	
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(getUptimeStatus) userInfo:nil repeats:NO];
	
	[self.autostartPlexConnect setState:(shouldStartPlexConnect) ? NSOnState : NSOffState];
	[self.onlyAtStartup setState:(shouldStartPlexConnectOnlyAtStartUp) ? NSOnState : NSOffState];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSString *ipString = [NSHost getIPWithNSHost];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.IPAddress setStringValue:ipString];
		});
	});
	
	[self.donateView setUIDelegate:self];
	[self.donateView setDrawsBackground:NO];
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"index_donate" withExtension:@"html" subdirectory:@"donate"];
	[[self.donateView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
	
	[self.helpView setUIDelegate:self];
	[self.helpView setDrawsBackground:NO];
	NSURL *help_url = [[NSBundle mainBundle] URLForResource:@"help_index" withExtension:@"html" subdirectory:@"help"];
	[[self.helpView mainFrame] loadRequest:[NSURLRequest requestWithURL:help_url]];
	
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id )listener
{
	[listener use];
}

- (void)webView:(WebView *)sender didStartProvisonalLoadForFrame:(WebFrame *)frame{

}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
	[webWindow setTitle:@""];
	[webWindow setRepresentedURL:[NSURL fileURLWithPath:@""]];
	NSImage *img = [NSImage imageNamed:NSImageNameStatusAvailable];
	[img setSize:NSMakeSize(16, 16)];
	[[webWindow standardWindowButton:NSWindowDocumentIconButton] setImage:img];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSUInteger windowStyleMask =    NSClosableWindowMask |
	NSMiniaturizableWindowMask |
	NSResizableWindowMask |
	NSTitledWindowMask;
	webWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 990, 600) styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:NO];
	[webWindow setReleasedWhenClosed:NO];
	nwWebView = [[WebView alloc] initWithFrame:[webWindow contentRectForFrameRect:webWindow.frame]];
	[nwWebView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	[webWindow setContentView:nwWebView];
	[webWindow setTitle:@"Loading..."];
	[webWindow center];
	[webWindow makeKeyAndOrderFront:self];
	[nwWebView setFrameLoadDelegate:self];
	[[nwWebView mainFrame] loadRequest:request];
    return nwWebView;
}

- (void)getUptimeStatus {
	if ([[PCPopoverController sharedInstance] isTaskRunning]) {
		[self.uptime setStringValue:[[PCPopoverController sharedInstance] getStartTime]];
	} else {
		[self.uptime setStringValue:@"Not Running"];
	}
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getUptimeStatus) userInfo:nil repeats:NO];
}

- (IBAction)plexDirChoose:(id)sender {
	NSString *plexConnectLog = [[NSFileManager defaultManager] applicationSupportDirectory];
	plexConnectLog = [NSString stringWithFormat:@"%@/%@",plexConnectLog,@"Plexify.bash"];
	
	NSURL *fileURL = [NSURL fileURLWithPath: plexConnectLog];
	NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];
	[[NSWorkspace sharedWorkspace] openURL: folderURL];
}

- (IBAction)plexOpenLog:(id)sender {
	NSString *plexConnectLog = [[NSFileManager defaultManager] applicationSupportDirectory];
	plexConnectLog = [NSString stringWithFormat:@"%@/%@",plexConnectLog,@"PlexConnect.log"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectLog]) {
		NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
		[workspace openFile:plexConnectLog];
	}
}

- (IBAction)autostartPlex:(id)sender {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:([self.autostartPlexConnect state] == NSOnState) ? YES : NO  forKey:@"shouldStartPlexConnect"];
	if ([self.autostartPlexConnect state] != NSOnState) {
		[self.onlyAtStartup setEnabled:NO];
	} else {
		[self.onlyAtStartup setEnabled:YES];
	}
}

- (IBAction)onlyStart:(id)sender {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setBool:([self.onlyAtStartup state] == NSOnState) ? YES : NO  forKey:@"shouldStartPlexConnectOnlyAtStartUp"];
}

- (IBAction)savePassword:(id)sender {
	NSString *pass = [self.password stringValue];
	[SSKeychain setPassword:pass forService:@"Plexify" account:@"Plexify"];
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Password saved"];
	[alert runModal];
	[self.password setStringValue:@""];
}

- (IBAction)deleteCert:(id)sender {
	[NSAlert showSheetModalForWindow:self.window
							 message:@"Are you sure?"
					 informativeText:@"Please Confirm you really want to delete certificates\nThis action cannot be undone."
						  alertStyle:NSCriticalAlertStyle
				   cancelButtonTitle:@"Cancel"
				   otherButtonTitles:@[@"Yes"]
						   onDismiss:^(int buttonIndex)  {
							   [[NSNotificationCenter defaultCenter] postNotificationName:@"StopServer" object:self];
							   NSString *plexConnectDir = [[NSFileManager defaultManager] applicationSupportDirectory];
							   NSString *plexConnectCertPem = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.pem"];
							   NSString *plexConnectCertCer = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.cer"];
							   NSString *plexConnectCertKey = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.key"];
							   NSError *error;
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertPem]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertPem error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
							   
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertCer]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertCer error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
							   
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertKey]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertKey error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
						   }
							onCancel:^ {
							}];
}

- (IBAction)createCert:(id)sender {
	[NSAlert showSheetModalForWindow:self.window
							 message:@"Generate new certificates?"
					 informativeText:@"Generating new certificates will override existed ones.\nYou will need to install new certificates on your Apple TV"
						  alertStyle:NSWarningAlertStyle
				   cancelButtonTitle:@"Cancel"
				   otherButtonTitles:@[@"Yes"]
						   onDismiss:^(int buttonIndex)  {
							   [[NSNotificationCenter defaultCenter] postNotificationName:@"StopServer" object:self];
							   NSString *plexConnectDir = [[NSFileManager defaultManager] applicationSupportDirectory];
							   NSString *plexConnectCertPem = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.pem"];
							   NSString *plexConnectCertCer = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.cer"];
							   NSString *plexConnectCertKey = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"assets/certificates/trailers.key"];
							   NSError *error;
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertPem]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertPem error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
							   
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertCer]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertCer error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
							   
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectCertKey]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectCertKey error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
							   
							   NSBundle *bundle = [NSBundle bundleForClass:[self class]];
							   NSString *generateScript = [bundle pathForResource:@"generate" ofType:@"bash"];
							   
							   NSString *generatebash = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/assets/certificates/generate.bash"];
							   
							   [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:generateScript] toURL:[NSURL fileURLWithPath:generatebash] error:nil];
							   
							   NSTask *task = [[NSTask alloc] init];
							   [task setLaunchPath:@"/bin/bash"];
							   [task setArguments:[NSArray arrayWithObjects:generatebash,nil]];
							   [task launch];
							   [task waitUntilExit];
						   }
							onCancel:^ {
							}];
}

// Actually logs
- (IBAction)deleteCerts:(id)sender {
	NSError *error;
	NSString *plexConnectDir = [[NSFileManager defaultManager] applicationSupportDirectory];
	NSString *plexConnectLog = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"PlexConnect.log"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectLog]) {
		[[NSFileManager defaultManager] removeItemAtPath:plexConnectLog error:&error];
		if (error)
			NSLog(@"ERR: %@",[error description]);
		error = nil;
	}
}

- (IBAction)deletePassword:(id)sender {
	[NSAlert showSheetModalForWindow:self.window
							 message:@"Are you sure?"
					 informativeText:@"You'll not be able to run PlexConnect using Plexify"
						  alertStyle:NSWarningAlertStyle
				   cancelButtonTitle:@"Cancel"
				   otherButtonTitles:@[@"Yes"]
						   onDismiss:^(int buttonIndex)  {
							   [[NSNotificationCenter defaultCenter] postNotificationName:@"StopServer" object:self];
							   [SSKeychain deletePasswordForService:@"Plexify" account:@"Plexify"];
							   NSAlert *alert = [[NSAlert alloc] init];
							   [alert setMessageText:@"Password Deleted!"];
							   [alert runModal];
						   }
							onCancel:^ {
							}];
}

- (IBAction)removeSettings:(id)sender {
	[NSAlert showSheetModalForWindow:self.window
							 message:@"Are you sure?"
					 informativeText:@"Settings.cfg will be deleted and a new default one will be automatically generated"
						  alertStyle:NSWarningAlertStyle
				   cancelButtonTitle:@"Cancel"
				   otherButtonTitles:@[@"Yes"]
						   onDismiss:^(int buttonIndex)  {
							   [[NSNotificationCenter defaultCenter] postNotificationName:@"StopServer" object:self];
							   NSError *error;
							   NSString *plexConnectDir = [[NSFileManager defaultManager] applicationSupportDirectory];
							   NSString *plexConnectSettings = [NSString stringWithFormat:@"%@/%@",plexConnectDir,@"Settings.cfg"];
							   if ([[NSFileManager defaultManager] fileExistsAtPath:plexConnectSettings]) {
								   [[NSFileManager defaultManager] removeItemAtPath:plexConnectSettings error:&error];
								   if (error)
									   NSLog(@"ERR: %@",[error description]);
								   error = nil;
							   }
						   }
							onCancel:^ {
							}];
}

- (IBAction)deletePlexconnect:(id)sender {
	[NSAlert showSheetModalForWindow:self.window
							 message:@"Are you sure?"
					 informativeText:@"Please Confrim you really want to delete?\nThink twice, we'll not ask you again.\n\nTHIS WILL ERASE EVERYTHING!"
						  alertStyle:NSCriticalAlertStyle
				   cancelButtonTitle:@"Cancel"
				   otherButtonTitles:@[@"YES, DELETE"]
						   onDismiss:^(int buttonIndex)  {
							   [[NSNotificationCenter defaultCenter] postNotificationName:@"StopServer" object:self];
							   NSFileManager* fm = [[NSFileManager alloc] init];
							   NSDirectoryEnumerator* en = [fm enumeratorAtPath:[[NSFileManager defaultManager] applicationSupportDirectory]];
							   NSError* err = nil;
							   BOOL res;
							   
							   NSString *installPath = [[NSFileManager defaultManager] applicationSupportDirectory];
							   
							   NSString* file;
							   while (file = [en nextObject]) {
								   res = [fm removeItemAtPath:[installPath stringByAppendingPathComponent:file] error:&err];
								   if (!res && err) {
									   NSLog(@"oops: %@", err);
								   }
							   }
						   }
							onCancel:^ {
							}];
}

@end
