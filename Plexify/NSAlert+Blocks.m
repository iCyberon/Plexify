#import "NSAlert+Blocks.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static BOOL _hasCancelButton;

@implementation NSAlert (Blocks)

+ (NSAlert*) showSheetModalForWindow:(NSWindow*) window
							 message:(NSString*) message
					 informativeText:(NSString*) text
						  alertStyle:(NSAlertStyle) style
				   cancelButtonTitle:(NSString*) cancelButtonTitle
				   otherButtonTitles:(NSArray*) otherButtons
						   onDismiss:(DismissBlock) dismissed
							onCancel:(CancelBlock) cancelled {
	
	_cancelBlock  = [cancelled copy];
	_dismissBlock  = [dismissed copy];
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:message];
	[alert setInformativeText:text];
	[alert setAlertStyle:style];
	
	for(NSString *buttonTitle in otherButtons)
		[alert addButtonWithTitle:buttonTitle];
	
	if (cancelButtonTitle) {
		_hasCancelButton = YES;
		[alert addButtonWithTitle:cancelButtonTitle];
	}
	else
		_hasCancelButton = NO;
	
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	return alert;
}

+ (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	int count = [[alert buttons] count];
	int buttonIndex = returnCode-1000;
	
	// cancel button is last button added
	if(_hasCancelButton && buttonIndex == count-1)
	{
		_cancelBlock();
	}
	else
	{
		_dismissBlock(buttonIndex);
	}
}


@end