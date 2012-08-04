//
//  FizyPlaylistItem.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FizyPlaylistItem.h"

@implementation FizyPlaylistItem

@synthesize ID, title, is_shuffle_on;


- (NSDictionary *) asDictionary{
    NSMutableDictionary *dictJson = [[NSMutableDictionary alloc] init];
	
	[dictJson setObject:ID forKey:@"ID"];
	[dictJson setObject:title forKey:@"title"];
	[dictJson setObject:is_shuffle_on ? @"1" : @"0" forKey:@"is_shuffle_on"];
	
	NSDictionary *result = [NSDictionary dictionaryWithDictionary:dictJson];
	
	[dictJson release];
	
	return [result autorelease];

}

@end
