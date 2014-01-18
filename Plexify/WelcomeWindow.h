//
//  WelcomeWindow.h
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/5/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
#import "BFPageControl.h"
#import "BETaskHelper.h"
#import "TCDropFileZoneView.h"

@interface WelcomeWindow : NSWindowController <BFPageControlDelegate, BETaskHelperDelegate, TCDropFileZoneDelegate> {
	int install_step;
	BOOL advancedMode;
	BETaskHelper* InstallTaskHelper;
	NSString* selfIP;
	
	NSString *certFileCer;
	NSString *certFilePem;
	NSString *certFileKey;
}
@property (strong) IBOutlet NSImageView *guideImageView;
@property (strong) IBOutlet NSTextField *guideTextView;

@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *advancedInstallButton;
@property (assign) IBOutlet NSButton *continueButton;
@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (assign) IBOutlet BFPageControl *pageControl;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSView *pagerView;
@property (strong) IBOutlet NSView *passwordView;
@property (strong) IBOutlet NSTextField *downloadingText;
@property (strong) IBOutlet NSView *chooseVersionView;
@property (strong) IBOutlet TCDropFileZoneView *dropDownZone;
@property (strong) IBOutlet NSTextField *generatingCertificatesText;

- (IBAction)continueButtonClicked:(id)sender;
- (IBAction)advancedInstallClicked:(id)sender;

@end