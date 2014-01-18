//
//  Settings.h
//  PlexConnect
//
//  Created by Vahagn Mkrtchyan on 11/3/13.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
#import <WebKit/WebKit.h>

@interface Settings : NSWindowController
@property (assign) IBOutlet NSButton *choosePlex;

- (IBAction)plexDirChoose:(id)sender;
- (IBAction)plexOpenLog:(id)sender;
- (IBAction)autostartPlex:(id)sender;
- (IBAction)onlyStart:(id)sender;
@property (strong) IBOutlet NSTextField *uptime;
@property (strong) IBOutlet WebView *donateView;

@property (strong) IBOutlet NSView *titleView;
@property (strong) IBOutlet NSButton *autostartPlexConnect;
@property (strong) IBOutlet NSButton *onlyAtStartup;
@property (strong) IBOutlet NSTextField *IPAddress;
@property (strong) IBOutlet NSSecureTextField *password;
@property (strong) IBOutlet WebView *helpView;

@property (strong) NSWindow *webWindow;
@property (strong) WebView* nwWebView;

- (IBAction)savePassword:(id)sender;
- (IBAction)deleteCert:(id)sender;
- (IBAction)createCert:(id)sender;
- (IBAction)deleteCerts:(id)sender;
- (IBAction)deletePassword:(id)sender;
- (IBAction)removeSettings:(id)sender;
- (IBAction)deletePlexconnect:(id)sender;

@end
