//
//  NSMutableArray-MoveExtentions.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/30/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "NSMutableArray-MoveExtentions.h"


@implementation NSMutableArray (MoveArray)

- (void) moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}

@end
