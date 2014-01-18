//
//  WelcomeWindow.m
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/5/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import "WelcomeWindow.h"
#import "SSKeychain.h"
#import "AFNetworking.h"
#import "NSFileManager+DirectoryLocations.h"
#import "NSHost+IPv4.h"
#import <ObjectiveGit/ObjectiveGit.h>
#include "NSAlert+Blocks.h"

@interface WelcomeWindow ()

@end

@implementation WelcomeWindow

- (id)initWithWindow:(INAppStoreWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		install_step = 0;
		advancedMode = NO;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
	aWindow.titleBarStartColor = [NSColor whiteColor];
	aWindow.titleBarEndColor = [NSColor whiteColor];
	aWindow.baselineSeparatorColor = [NSColor whiteColor];
	[[aWindow standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
	[[aWindow standardWindowButton:NSWindowZoomButton] setHidden:YES];
	
	[self setButtonStyle];
	
	[self.indicator startAnimation:nil];
	[self.indicator setDoubleValue:0];
	
	[self.pagerView setHidden:YES];
	[self.passwordView setHidden:YES];
	[self.chooseVersionView setHidden:YES];
	
	// Page control
	NSRect aframe = self.window.frame;
	[self.pageControl setDelegate: self];
    [self.pageControl setNumberOfPages: 8];
    [self.pageControl setIndicatorDiameterSize: 15];
    [self.pageControl setIndicatorMargin: 5];
    [self.pageControl setCurrentPage: 0];
    [self.pageControl setDrawingBlock: ^(NSRect aframe, NSView *aView, BOOL isSelected, BOOL isHighlighted){
        
        aframe = CGRectInset(aframe, 2.0, 2.0);
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect: CGRectMake(aframe.origin.x, aframe.origin.y + 1.5, aframe.size.width, aframe.size.height)];
        [[NSColor whiteColor] set];
        [path fill];
        
        path = [NSBezierPath bezierPathWithOvalInRect: aframe];
        NSColor *color = isSelected ? [NSColor colorWithCalibratedRed: (115.0 / 255.0) green: (115.0 / 255.0) blue: (115.0 / 255.0) alpha: 1.0] :
        [NSColor colorWithCalibratedRed: (217.0 / 255.0) green: (217.0 / 255.0) blue: (217.0 / 255.0) alpha: 1.0];
        
        if(isHighlighted)
            color = [NSColor colorWithCalibratedRed: (150.0 / 255.0) green: (150.0 / 255.0) blue: (150.0 / 255.0) alpha: 1.0];
        
        [color set];
        [path fill];
        
        aframe = CGRectInset(aframe, 0.5, 0.5);
        [[NSColor colorWithCalibratedRed: (25.0 / 255.0) green: (25.0 / 255.0) blue: (25.0 / 255.0) alpha: 0.15] set];
        [NSBezierPath setDefaultLineWidth: 1.0];
        [[NSBezierPath bezierPathWithOvalInRect: aframe] stroke];
    }];
    [self.pageControl setFrame: CGRectMake(20,46,421,30)];
	self.dropDownZone.delegate = self;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSString *ipString = [NSHost getIPWithNSHost];
		selfIP = [ipString copy];
	});
}

- (void)setButtonStyle
{
	// Button
	NSColor *color = [NSColor colorWithCalibratedRed:0.60f green:0.60f blue:0.61f alpha:1.00f];
	
	if (![self.continueButton isEnabled]) {
		color = [NSColor colorWithCalibratedRed:0.90f green:0.90f blue:0.91f alpha:.04f];
	}
	
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.continueButton attributedTitle]];
	
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
	
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
	
	
	NSMutableAttributedString *acolorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.advancedInstallButton attributedTitle]];
	
    NSRange atitleRange = NSMakeRange(0, [acolorTitle length]);
	
    [acolorTitle addAttribute:NSForegroundColorAttributeName value:color range:atitleRange];
	
    [self.continueButton setAttributedTitle:colorTitle];
	[self.advancedInstallButton setAttributedTitle:acolorTitle];
}

- (void)showView:(NSView*)view withDuration:(CGFloat)duration {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.0];
	[[view animator] setAlphaValue:0.0f];
	[NSAnimationContext endGrouping];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:duration];
	[[view animator] setAlphaValue:1.0f];
	[NSAnimationContext endGrouping];
}

- (void)hideView:(NSView*)view withDuration:(CGFloat)duration {
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.0];
	[[view animator] setAlphaValue:1.0f];
	[NSAnimationContext endGrouping];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:duration];
	[[view animator] setAlphaValue:0.0f];
	[NSAnimationContext endGrouping];
}

- (IBAction)continueButtonClicked:(id)sender {
	advancedMode = NO;
	if (install_step == 0) {
		// Hide Button
		[self hideView:self.advancedInstallButton withDuration:0.2];
		
		[self.continueButton.animator setFrame:NSMakeRect(183, 13, 95, 32)];
		
		[self.passwordView setHidden:NO];
		
		[self showView:self.passwordView withDuration:0.7];
		
		install_step++;
		[self.continueButton setTitle:@"Continue"];
		[self setButtonStyle];
	} else if (install_step == 1) {
		// Check if password is correct!
		// Don't do anything if it's wrong
		NSTask *task = [[NSTask alloc] init];
		
		[task setLaunchPath:@"/usr/bin/sudo"];
		[task setArguments:[NSArray arrayWithObjects:@"-S", @"PlexifyOSX", nil]];
		
		InstallTaskHelper = [[BETaskHelper alloc] initWithDelegate:self forTask:task];
		[InstallTaskHelper launchTask];
		
		[self.passwordField setEnabled:NO];
	} else {
		[self close];
	}
}

- (IBAction)advancedInstallClicked:(id)sender {
	advancedMode = YES;
	if (install_step == 0) {
		// Hide Button
		[self hideView:self.continueButton withDuration:0.2];
		[self.continueButton setHidden:YES];
		[self.advancedInstallButton.animator setFrame:NSMakeRect(183, 13, 95, 32)];
		
		[self.passwordView setHidden:NO];
		
		[self showView:self.passwordView withDuration:0.7];
		
		install_step++;
		[self.advancedInstallButton setTitle:@"Continue"];
		[self setButtonStyle];
	} else if (install_step == 1) {
		// Check if password is correct!
		// Don't do anything if it's wrong
		NSTask *task = [[NSTask alloc] init];
		
		[task setLaunchPath:@"/usr/bin/sudo"];
		[task setArguments:[NSArray arrayWithObjects:@"-S", @"PlexifyOSX", nil]];
		
		InstallTaskHelper = [[BETaskHelper alloc] initWithDelegate:self forTask:task];
		[InstallTaskHelper launchTask];
		
		[self.passwordField setEnabled:NO];
	} else  if (install_step == 2)  {
		// Show branch chooser
		//NSLog(@"Choose version!");
		[self hideView:self.dropDownZone withDuration:0.2];
		[self.chooseVersionView setHidden:NO];
		[self showView:self.chooseVersionView withDuration:0.3];
		install_step++;
	} else  if (install_step == 3)  {
		// Download goes here
		[self startDownloadAndInstall:NO];
		install_step++;
	} else {
		[self close];
	}
}

- (void)generateCerts:(BOOL)run
{
	[self hideView:self.indicator withDuration:0.2];
	[self hideView:self.downloadingText withDuration:0.2];
	[self.downloadingText setHidden:YES];
	[self.indicator setHidden:YES];
	
	if (run) {
		[self.generatingCertificatesText setHidden:NO];
		[self showView:self.generatingCertificatesText withDuration:0.3];
	}
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *generateScript = [bundle pathForResource:@"generate" ofType:@"bash"];
	
	NSString *generatebash = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/assets/certificates/generate.bash"];
	
	[[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:generateScript] toURL:[NSURL fileURLWithPath:generatebash] error:nil];
	
	if (run) {
		NSString *oldCertPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/trailers.pem"];
		BOOL certExist = [[NSFileManager defaultManager] fileExistsAtPath:oldCertPath];
		if (certExist) {
			NSString *newCertsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/assets/certificates/"];
			NSString *certsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/"];
			
			NSFileManager *fm = [NSFileManager defaultManager];
			
			[fm createDirectoryAtPath:newCertsDir withIntermediateDirectories:YES attributes:nil error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.cer"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.cer"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.cer"] error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.pem"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.pem"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.pem"] error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.key"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.key"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.key"] error:nil];
			
			NSString *tempPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/"];
			NSDirectoryEnumerator* en = [fm enumeratorAtPath:tempPath];
			NSError* err = nil;
			BOOL res;
			
			NSString* file;
			while (file = [en nextObject]) {
				res = [fm removeItemAtPath:[tempPath stringByAppendingPathComponent:file] error:&err];
				if (!res && err) {
				}
			}
			
			res = [fm removeItemAtPath:tempPath error:&err];
			if (!res && err) {
			}
		} else {
			NSTask *task = [[NSTask alloc] init];
			[task setLaunchPath:@"/bin/bash"];
			[task setArguments:[NSArray arrayWithObjects:generatebash,nil]];
			[task launch];
			[task waitUntilExit];
		}
	} else {
		// Double check!
		if (advancedMode) {
			NSString *certsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/assets/certificates/"];
			NSFileManager *fm = [NSFileManager defaultManager];
			if (certFileCer)
				[fm copyItemAtPath:certFileCer toPath:[certsDir stringByAppendingPathComponent:[certFileCer lastPathComponent]] error:nil];
			
			if (certFileKey)
				[fm copyItemAtPath:certFileCer toPath:[certsDir stringByAppendingPathComponent:[certFileKey lastPathComponent]] error:nil];
			
			if (certFilePem)
				[fm copyItemAtPath:certFileCer toPath:[certsDir stringByAppendingPathComponent:[certFilePem lastPathComponent]] error:nil];
		}
		
		NSString *oldCertPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/trailers.pem"];
		BOOL certExist = [[NSFileManager defaultManager] fileExistsAtPath:oldCertPath];
		if (certExist) {
			NSString *newCertsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/assets/certificates/"];
			NSString *certsDir = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/"];
			
			NSFileManager *fm = [NSFileManager defaultManager];
			
			[fm createDirectoryAtPath:newCertsDir withIntermediateDirectories:YES attributes:nil error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.cer"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.cer"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.cer"] error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.pem"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.pem"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.pem"] error:nil];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:[certsDir stringByAppendingString:@"trailers.key"]])
				[fm copyItemAtPath:[certsDir stringByAppendingString:@"trailers.key"] toPath:[newCertsDir stringByAppendingPathComponent:@"trailers.key"] error:nil];
		}
		
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *tempPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"Temp/"];
		NSDirectoryEnumerator* en = [fm enumeratorAtPath:tempPath];
		NSError* err = nil;
		BOOL res;
		
		NSString* file;
		while (file = [en nextObject]) {
			res = [fm removeItemAtPath:[tempPath stringByAppendingPathComponent:file] error:&err];
			if (!res && err) {
			}
		}
		
		res = [fm removeItemAtPath:tempPath error:&err];
		if (!res && err) {
		}
	}
	
	// Copy Plexify.bash
	NSString *plexifyScript = [bundle pathForResource:@"Plexify" ofType:@"bash"];
	NSString *plexifyBash = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/Plexify.bash"];
	
	[[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:plexifyScript] toURL:[NSURL fileURLWithPath:plexifyBash] error:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showSuccess) userInfo:nil repeats:NO];
}

- (void)showSuccess
{
	[self.generatingCertificatesText setStringValue:@"Installation Complete. Congratulations!"];
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startGuide) userInfo:nil repeats:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StartServer" object:self];
}

- (void)startGuide
{
	if (!advancedMode) {
		[self.continueButton setTitle:@"Skip"];
		[self.continueButton setEnabled:YES];
	} else {
		[self.advancedInstallButton setTitle:@"Skip"];
		[self.advancedInstallButton setEnabled:YES];
	}
	[self setButtonStyle];
	
	[self.pagerView setHidden:NO];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.0];
	[[self.pagerView animator] setAlphaValue:0.0f];
	[NSAnimationContext endGrouping];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:1.4];
	[[self.mainView animator] setAlphaValue:0.0f];
	[[self.pagerView animator] setAlphaValue:1.0f];
	[NSAnimationContext endGrouping];
}

- (void)askForCerts
{
	[self hideView:self.passwordView withDuration:0.05];
	[self hideView:self.mainView withDuration:0.2];
	[self.dropDownZone setHidden:NO];
	[self showView:self.dropDownZone withDuration:0.4];
	[NSAlert showSheetModalForWindow:self.window
							 message:@""
					 informativeText:@"Certificates will be restored after installation"
						  alertStyle:NSWarningAlertStyle
				   cancelButtonTitle:@"Continue"
				   otherButtonTitles:@[]
						   onDismiss:^(int buttonIndex)  {
						   }
							onCancel:^ {
								[self advancedInstallClicked:nil];
							}];
}

- (void)startDownloadAndInstall:(BOOL)generateCertificates
{
	if (generateCertificates) {
		[self hideView:self.passwordView withDuration:0.05];
		[self.indicator setHidden:NO];
		[self showView:self.indicator withDuration:0.9];
		[self.indicator startAnimation:nil];
		[self.downloadingText setHidden:NO];
		[self.continueButton setTitle:@". . ."];
		[self.continueButton setEnabled:NO];
		[self setButtonStyle];
	} else {
		[self.passwordView setHidden:YES];
		[self hideView:self.chooseVersionView withDuration:0.05];
		[self.indicator setHidden:NO];
		[self showView:self.indicator withDuration:0.9];
		[self.mainView setHidden:NO];
		[self showView:self.mainView withDuration:0.9];
		[self.indicator startAnimation:nil];
		[self.downloadingText setHidden:NO];
		[self.advancedInstallButton setTitle:@". . ."];
		[self.advancedInstallButton setEnabled:NO];
		[self setButtonStyle];
	}

		// Let's download from GitHub
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			NSFileManager *fm = [NSFileManager defaultManager];
			NSString *oldInstallPath = [NSString stringWithFormat:@"%@%@",[[NSFileManager defaultManager] applicationSupportDirectory],@"/"];
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
			
			NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
			NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
			
			[GTRepository cloneFromURL:[NSURL URLWithString:@"https://github.com/iBaa/PlexConnect"] toWorkingDirectory:url options:nil error:&err transferProgressBlock:^(const git_transfer_progress* progress) {
				dispatch_async(dispatch_get_main_queue(), ^{
					//NSLog(@"Downloading: %u,%u",progress->received_objects,progress->total_objects);
					[self.indicator setDoubleValue:(100.0 * progress->received_objects)/progress->total_objects];
					if (progress->received_bytes > 1000000) {
						NSString *txt = [NSString stringWithFormat:@"Receiving objects: %d / %d | %.2f MB",progress->received_objects, progress->total_objects,progress->received_bytes/1000000.f ];
						[self.downloadingText setStringValue:txt];
					} else
					{
						NSString *txt = [NSString stringWithFormat:@"Receiving objects: %d / %d | %.f KB",progress->received_objects, progress->total_objects,progress->received_bytes/1000.f ];
						[self.downloadingText setStringValue:txt];
					}
					
				});
			}checkoutProgressBlock:^(NSString *pth, NSUInteger stps, NSUInteger ttlstps){
				//NSLog(@"checkoutProgressBlock!");
			}];
			
			if (err)
				NSLog(@"%@",err);
			
			if (!err)
				dispatch_async(dispatch_get_main_queue(), ^{
					if (generateCertificates)
						[self generateCerts:YES];
					else
						[self generateCerts:NO];
				});
		});
}

#pragma mark BFPageControl delegate methods
-(void)pageControl: (BFPageControl *)pageControl didSelectPageAtIndex: (NSInteger)index
{
	switch (index) {
		case 0:
			[self.guideTextView setStringValue:@"Now it's time to configure your Apple TV!"];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_0"]];
			break;
		case 1:
			[self.guideTextView setStringValue:@"Open Wi-Fi Settings"];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_1"]];
			break;
		case 2:
			[self.guideTextView setStringValue:@"Change the DNS setting from \"Automatic\" to \"Manual\""];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_2"]];
			break;
		case 3:
			[self.guideTextView setStringValue:[NSString stringWithFormat:@"Enter \"%@\" as the DNS",selfIP]];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_3"]];
			break;
		case 4:
			[self.guideTextView setStringValue:@"Go to the Settings ❯ General"];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_4"]];
			break;
		case 5:
			[self.guideTextView setStringValue:@"Set \"Send Data To Apple\" to \"NO\""];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_5"]];
			break;
		case 6:
			[self.guideTextView setStringValue:@"press \"Play\" and add a profile"];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_0"]];
			break;
		case 7:
			[self.guideTextView setStringValue:[NSString stringWithFormat:@"Enter \"http://%@/trailers.cer\"",[NSHost getIPWithNSHost]]];
			[self.guideImageView setImage:[NSImage imageNamed:@"ui_0"]];
			break;
		default:
			break;
	}
}

#pragma mark BETaskHelper delegate methods

-(void) task:(NSTask *)task hasOutputAvailable:(NSString *)outputLine {
    // Log all output
    //NSLog(@"%@", outputLine);

    if ([outputLine rangeOfString:@"incorrect password"].location != NSNotFound) {
		//NSLog(@"Wrong password!");
		[self.passwordField setEnabled:YES];
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Wrong Password, try again!"];
		[alert runModal];
    }
	
	if ([outputLine rangeOfString:@"PlexifyOSX"].location != NSNotFound) {
		//NSLog(@"Success!");
		// Time to save password into Keychain
		// And start downloading app ))
		install_step++;
		if (![SSKeychain passwordForService:@"Plexify" account:@"Plexify"]) {
			[SSKeychain setPassword:[NSString stringWithFormat:@"%@",[self.passwordField stringValue] ] forService:@"Plexify" account:@"Plexify"];
		}
		[self.passwordField setEnabled:YES];
		if (!advancedMode) {
			//NSLog(@"download...");
			[self startDownloadAndInstall:YES];
		} else {
			//NSLog(@"ask for certs");
			[self askForCerts];
		}
    }
	
	if ([outputLine rangeOfString:@"Password:"].location != NSNotFound) {
		NSString *pass;
		if ([SSKeychain passwordForService:@"Plexify" account:@"Plexify"]) {
			pass = [NSString stringWithFormat:@"%@\n",[SSKeychain passwordForService:@"Plexify" account:@"Plexify"]];
		} else {
			pass = [NSString stringWithFormat:@"%@\n",[self.passwordField stringValue]];
		}
        [InstallTaskHelper sendInput:pass];
    }
}


#pragma mark - TCDropFileZoneDelegate

- (void)dropZoneGetFiles:(NSArray *)filePathArray
{
    //NSLog(@"Files: %@", filePathArray);
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *infoText = [[NSString alloc] init];
	BOOL correctFile = NO;
	int cnt = 1;
	for (NSString *fileURL in filePathArray) {
		if ([[fileURL lastPathComponent] isEqualToString:@"trailers.cer"] || [[fileURL lastPathComponent]isEqualToString:@"trailers.pem"] || [[fileURL lastPathComponent] isEqualToString:@"trailers.key"]) {
			correctFile = YES;
			infoText = [infoText stringByAppendingString:[fileURL lastPathComponent]];
			
			if ([[fileURL lastPathComponent] isEqualToString:@"trailers.cer"])
				certFileCer = fileURL;
			
			if ([[fileURL lastPathComponent] isEqualToString:@"trailers.pem"])
				certFilePem = fileURL;
			
			if ([[fileURL lastPathComponent] isEqualToString:@"trailers.key"])
				certFileKey = fileURL;
				
			if (cnt < [filePathArray count])
				infoText = [infoText stringByAppendingString:@", "];
			cnt++;
		}
	}
	
	if (cnt == 1) {
		if ([filePathArray count] == 1)
			[alert setMessageText:@"Wrong file!"];
		else
			[alert setMessageText:@"Wrong files!"];
		
		if ([filePathArray count] == 1)
			[alert setInformativeText:@"Seems the file is not valid certificate file. Valid files are:\ntrailers.cer, trailers.pem and trailers.key\nPlease try again"];
		else
			[alert setInformativeText:@"Seems the files are not valid certificate files. Valid files are:\ntrailers.cer, trailers.pem and trailers.key\nPlease try again"];
		[alert runModal];
	}
	
	infoText = [infoText stringByAppendingString:@" will be copied to Plexify deirectory and used for PlexConnect."];
	if ([filePathArray count] > 1) {
		[alert setMessageText:@"Certificate Files Added"];
		[alert setInformativeText:infoText];
	} else {
		[alert setMessageText:@"Certificate File Added"];
		[alert setInformativeText:infoText];
	}
	if (correctFile)
		[alert runModal];
}

-(void) task:(NSTask *)task hasCompletedWithStatus:(int) status {
	
}

@end
