//
//  SELInfoObject.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/14/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "SELInfoObject.h"


@implementation SELInfoObject
@synthesize callback, context, reference;

-(void)dealloc{
	
	[context release];
	
	[super dealloc];
}

@end
