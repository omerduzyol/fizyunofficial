//
//  NSArray_FilterExtensions.m
//  DominosAciktik
//
//  Created by Ömer Düzyol on 2/24/11.
//  Copyright 2011 MagiClick Digital Solutions. All rights reserved.
//

#import "NSArray_FilterExtensions.h"

@implementation NSArray (NSArray_FilterExtensions)

- (NSUInteger) indexOfPredicate:(NSPredicate *)predicate {
	NSArray *filtered = [self filteredArrayUsingPredicate:predicate];
	
	if (filtered != nil && [filtered count] > 0) {
		return [self indexOfObject:[filtered objectAtIndex:0]];
	}
	
	return NSNotFound;
}

@end
