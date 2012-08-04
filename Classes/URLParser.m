//
//  URLParser.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/16/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "URLParser.h"


@implementation URLParser

@synthesize parameters;

- (id) initWithURLString:(NSString *)url{
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
		
		NSMutableDictionary *vars = [NSMutableDictionary new];
        [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
			NSArray *keyValue = [tempString componentsSeparatedByString:@"="];
			if ([keyValue count] == 2) {
				NSString *val = [[keyValue objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
				
				[vars setObject:[[val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy] forKey:[keyValue objectAtIndex:0]];
			} else {
				[vars setObject:nil forKey:[keyValue objectAtIndex:0]];
			}
        }
        self.parameters = [NSDictionary dictionaryWithDictionary:vars];
        [vars release];
    }
    return self;
}

- (NSString *)valueForParameter:(NSString *)varName {
	/*
    for (NSString *var in self.variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }*/
	
    return [self.parameters objectForKey:varName];
}

- (void) dealloc{
    self.parameters = nil;
    [super dealloc];
}

@end
