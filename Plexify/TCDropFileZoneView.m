//
//  TCDropFileZoneView.m
//  TCDropZone
//
//  Created by Konstantin Stoldt on 24.05.13.
//
//  Is licensed under the MIT license
//	Copyright (c) 2013, TheCodeEngine, Konstantin Stoldt
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//

#import "TCDropFileZoneView.h"

@implementation TCDropFileZoneView

- (id)initWithFrame:(NSRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventHandler:) name:@"TCDropbFileZoneGetFiles" object:nil];
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
        fileisEntered = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	//// Color Declarations
	NSColor* color = [NSColor colorWithCalibratedRed: 0.568 green: 0.577 blue: 0.585 alpha: 1];
	//// Color Declarations
	NSColor* color3 = [NSColor colorWithCalibratedRed: 0.114 green: 0.705 blue: 1 alpha: 1];
	
	//// Abstracted Attributes
	NSString* text2Content = @"trailers.cer, trailers.pem, trailers.key";
	NSString* textContent = @"Drop certificate files here";
	
	if ( fileisEntered == NO )
    {
        //// DropbZone
		{
			//// Text Drawing
			NSRect textRect = NSMakeRect(17, 37, 197, 24);
			NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
			[textStyle setAlignment: NSCenterTextAlignment];
			
			NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSFont fontWithName: @"Helvetica-Bold" size: 15], NSFontAttributeName,
												color, NSForegroundColorAttributeName,
												textStyle, NSParagraphStyleAttributeName, nil];
			
			[textContent drawInRect: NSOffsetRect(textRect, 0, 0) withAttributes: textFontAttributes];
			
			
			//// Pfeil Drawing
			NSBezierPath* pfeilPath = [NSBezierPath bezierPath];
			[pfeilPath moveToPoint: NSMakePoint(87.11, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(98.89, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(98.89, 167.3)];
			[pfeilPath lineToPoint: NSMakePoint(123.29, 167.3)];
			[pfeilPath lineToPoint: NSMakePoint(123.29, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(135.91, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(111.51, 98.69)];
			[pfeilPath lineToPoint: NSMakePoint(87.11, 125.8)];
			[pfeilPath closePath];
			[color setFill];
			[pfeilPath fill];
			
			
			//// Rounded Rectangle Drawing
			NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(4, 5, 221, 221) xRadius: 10 yRadius: 10];
			[color setStroke];
			[roundedRectanglePath setLineWidth: 4];
			CGFloat roundedRectanglePattern[] = {4, 4, 4, 4};
			[roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 8];
			[roundedRectanglePath stroke];
		}
		
		
		//// Text 2 Drawing
		NSRect text2Rect = NSMakeRect(4, 16, 221, 17);
		NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
		[text2Style setAlignment: NSCenterTextAlignment];
		
		NSDictionary* text2FontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSFont fontWithName: @"Helvetica-Oblique" size: [NSFont smallSystemFontSize]], NSFontAttributeName,
											 color, NSForegroundColorAttributeName,
											 text2Style, NSParagraphStyleAttributeName, nil];
		
		[text2Content drawInRect: NSOffsetRect(text2Rect, 0, 1) withAttributes: text2FontAttributes];
    }
    else
    {
		//// DropbZone
		{
			//// Text Drawing
			NSRect textRect = NSMakeRect(17, 37, 197, 24);
			NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
			[textStyle setAlignment: NSCenterTextAlignment];
			
			NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSFont fontWithName: @"Helvetica-Bold" size: 15], NSFontAttributeName,
												color3, NSForegroundColorAttributeName,
												textStyle, NSParagraphStyleAttributeName, nil];
			
			[textContent drawInRect: NSOffsetRect(textRect, 0, 0) withAttributes: textFontAttributes];
			
			
			//// Pfeil Drawing
			NSBezierPath* pfeilPath = [NSBezierPath bezierPath];
			[pfeilPath moveToPoint: NSMakePoint(87.11, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(98.89, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(98.89, 167.3)];
			[pfeilPath lineToPoint: NSMakePoint(123.29, 167.3)];
			[pfeilPath lineToPoint: NSMakePoint(123.29, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(135.91, 125.8)];
			[pfeilPath lineToPoint: NSMakePoint(111.51, 98.69)];
			[pfeilPath lineToPoint: NSMakePoint(87.11, 125.8)];
			[pfeilPath closePath];
			[color3 setFill];
			[pfeilPath fill];
			
			
			//// Rounded Rectangle Drawing
			NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(4, 5, 221, 221) xRadius: 10 yRadius: 10];
			[color3 setStroke];
			[roundedRectanglePath setLineWidth: 4];
			CGFloat roundedRectanglePattern[] = {4, 4, 4, 4};
			[roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 8];
			[roundedRectanglePath stroke];
		}
		
		
		//// Text 2 Drawing
		NSRect text2Rect = NSMakeRect(4, 16, 221, 17);
		NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
		[text2Style setAlignment: NSCenterTextAlignment];
		
		NSDictionary* text2FontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSFont fontWithName: @"Helvetica-Oblique" size: [NSFont smallSystemFontSize]], NSFontAttributeName,
											 color3, NSForegroundColorAttributeName,
											 text2Style, NSParagraphStyleAttributeName, nil];
		
		[text2Content drawInRect: NSOffsetRect(text2Rect, 0, 1) withAttributes: text2FontAttributes];
    }
}

#pragma mark - Drop Delegate

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    fileisEntered = YES;
    [self setNeedsDisplay:YES];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    fileisEntered = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id)sender
{
    fileisEntered = NO;
    [self setNeedsDisplay:YES];
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        // Count testen ? int numberOfFiles = [files count];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TCDropbFileZoneGetFiles" object:files];
        return YES;
    }
    return NO;
}

#pragma mark - Notification

- (void)eventHandler: (NSNotification *) notification
{
    if ( self.delegate && [self.delegate respondsToSelector:@selector(dropZoneGetFiles:)] )
    {
        [self.delegate dropZoneGetFiles:[notification object]];
    }
}


@end
