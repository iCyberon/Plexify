//
//  NSHost+IPv4.m
//  Plexify
//
//  Created by Vahagn Mkrtchyan on 11/11/13.
//  Copyright (c) 2013 Vahagn Mkrtchyan. All rights reserved.
//

#import "NSHost+IPv4.h"

@implementation NSHost (IPv4)

+(NSString*) getIPWithNSHost {
	NSString* stringAddress;
	
	NSArray *addresses = [[NSHost currentHost] addresses];
	
	for (NSString *anAddress in addresses) {
		if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
			stringAddress = anAddress;
			break;
		} else {
			stringAddress = @"IPv4 address not available" ;
		}
	}
	return stringAddress;
}

@end
