//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCController.h"

@interface PCMenulet : NSView

+ (PCMenulet*)sharedInstance;
- (void)needsRedraw;

@property (nonatomic, assign) id<PCMenuletDelegate> delegate;

@end
