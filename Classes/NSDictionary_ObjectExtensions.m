//
//  NSDictionary_ObjectExtensions.m
//	ObjectExtensions
//  
//  Copyright (C) 2011 by Omer Duzyol
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "NSDictionary_ObjectExtensions.h"
#include <objc/runtime.h>

@implementation NSDictionary (NSDictionary_ObjectExtensions)

- (id) convertToType:(Class)type
{
	// construct new object with given type
	id newInstance = [[type alloc] init];
	
	// get instanced object's properties
	unsigned int propCount;
	objc_property_t *properties = class_copyPropertyList(type, &propCount);
	
	// create storage to map native types and props
	NSMutableDictionary *propTypes = [[NSMutableDictionary alloc] initWithCapacity:propCount];
	
	// loop for each prop
	for (unsigned int i = 0; i < propCount; i++) {
		objc_property_t property = properties[i];
		
		// dump all attributes to determine property type
		const char *attributes = property_getAttributes(property);
		
		char buffer[strlen(attributes) + 1];
		strcpy(buffer, attributes);
		
		char *attribute = strtok(buffer, ",");
		if (*attribute == 'T') attribute++; else attribute = NULL;

		// setup prop name and type in string
		NSString *propName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
		NSString *propType = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
		
		// check if its objc class?
		if([propType hasPrefix:@"@"]){
			propType = [propType stringByReplacingOccurrencesOfString:@"@" withString:@""];
			propType = [propType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		} // else type is atomic
		
		// store prop with type and class identifier
		[propTypes setObject:propType forKey:propName];
	}
	
	SEL converterSel = @selector(convertToType:);
	
	// loop all tree in dictionary
	for (NSString *key in [self allKeys]) {
		SEL propSetterSel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] capitalizedString]]]);
												  
		id pairVal = [self valueForKey:key];
		
		// property type definition of newInstance
		NSString *targetType = [propTypes valueForKey:key];
		
		// check nested item is convertable dict and target type is not a native objc class?
		if (![targetType hasPrefix:@"NS"] && [pairVal respondsToSelector:converterSel]) {
			Class pairType = NSClassFromString(targetType);
			id convertedVal = [pairVal performSelector:converterSel withObject:pairType];

			// release old value
			[pairVal release];
			pairVal = convertedVal;
		} // else dont touch the value and set as is

		// check if the current property has setter?
		if ([newInstance respondsToSelector:propSetterSel] && pairVal != nil){
			// assing the value via setter method
			[newInstance performSelector:propSetterSel withObject:pairVal];
		}
	}
	
	[propTypes release];
	
	return newInstance;
}

- (NSDictionary *)deepCopy
{
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	
	for (id key in [self allKeys])
    {
		id oneValue = [self valueForKey:key];
        id oneCopy = nil;
		
		if ([oneValue respondsToSelector: @selector(deepCopy)])
        {
            oneCopy = [oneValue deepCopy];
        }
		
        if (oneCopy == nil)
        {       
			oneCopy = [oneValue copy];
        }
		
        [ret setValue:oneCopy forKey:key];
		
        //[oneCopy release];
	}
	
	return [[NSDictionary alloc] initWithDictionary:ret];
}

- (void)deepRelease
{
	
	for (id key in [self allKeys])
    {
		id object = [self valueForKey:key];
        
		if ([object respondsToSelector: @selector(deepRelease)])
        {
            [object deepRelease];
        }
		
        [object release];
	}
	
	return [self release];
}


@end
