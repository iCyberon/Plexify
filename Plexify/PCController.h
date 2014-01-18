//
//  Created by Vahagn Mkrtchyan (Cyberon)
//  Copyright (c) 2013 Vahagn Mkrtchyan, for InMac.org All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INPopoverController.h"

@protocol PCMenuletDelegate <NSObject>

- (BOOL)isActive;
- (void)menuletClicked;

@end

@interface PCController : NSObject <PCMenuletDelegate>

+ (PCController*)sharedInstance;

@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, strong) INPopoverController *popover;

- (void)changeIconToPassive;
- (void)changeIconToActive;

- (void)initPopover;

@end
