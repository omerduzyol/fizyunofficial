//
//  Utility.m
//  DominosAciktik
//
//  Created by Ömer Düzyol on 1/20/11.
//  Copyright 2011 MagiClick Digital Solutions. All rights reserved.
//

#import "UICustomAlertView.h"
#import "Utility.h"
#import "FizyUnofficialAppDelegate.h"

@implementation Utility

+ (id) findObjectInArray:(NSArray*)arrObjects byTag:(NSInteger)tag
{
	for (id object in arrObjects) {
		if ([object isKindOfClass:[UIView class]]) 
        {
			if (((UIView *)object).tag == tag)
				return object;
        }

	}
	
	return nil;
} 

+ (id) deepCopyViaArchiving:(id<NSCoding>)anObject
{
    NSData* archivedData = [NSKeyedArchiver archivedDataWithRootObject:anObject];
    return [[NSKeyedUnarchiver unarchiveObjectWithData:archivedData] retain];
}

+ (MBProgressHUD *) sharedHUD
{
	FizyUnofficialAppDelegate * appDelegate =  [UIApplication sharedApplication].delegate;
	return [appDelegate getHUD];
}

+ (id) performSelectorOnAppDelegate:(NSString *)selector
{
	SEL aSelector = NSSelectorFromString(selector);
	
	FizyUnofficialAppDelegate * appDelegate =  [UIApplication sharedApplication].delegate;
	return [appDelegate performSelector:aSelector];
}

+ (NSString *) determineImageSize{
	UIDevicePlatform currentPlatform = [[UIDevice currentDevice] platformType];
	/*
	 
	 iPhone1,1 ->	iPhone 1G
	 iPhone1,2 ->	iPhone 3G
	 iPhone2,1 ->	iPhone 3GS
	 iPhone3,1 ->	iPhone 4/AT&T
	 iPhone3,2 ->	iPhone 4/Other Carrier?
	 iPhone3,3 ->	iPhone 4/Other Carrier?
	 iPhone4,1 ->	??iPhone 5
	 
	 iPod1,1   -> iPod touch 1G 
	 iPod2,1   -> iPod touch 2G 
	 iPod2,2   -> ??iPod touch 2.5G
	 iPod3,1   -> iPod touch 3G
	 iPod4,1   -> iPod touch 4G
	 iPod5,1   -> ??iPod touch 5G
	 
	 iPad1,1   -> iPad 1G, WiFi
	 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
	 iPad2,1   -> iPad 2G (iProd 2,1)*/
	
	NSString *sizeString;
	
	switch (currentPlatform) {
		case UIDevice1GiPhone:
		case UIDevice3GiPhone:
		case UIDevice3GSiPhone:
		case UIDevice1GiPod:
		case UIDevice2GiPod:
		case UIDeviceiPhoneSimulatoriPhone:
		case UIDevice3GiPod:
			sizeString = @"2";
			break;
		default:
			sizeString = @"1";
			break;
	}
	
	return sizeString;
}

+ (NSString *) determineImageMultiplier{
	UIDevicePlatform currentPlatform = [[UIDevice currentDevice] platformType];
	/*
	 
	 iPhone1,1 ->	iPhone 1G
	 iPhone1,2 ->	iPhone 3G
	 iPhone2,1 ->	iPhone 3GS
	 iPhone3,1 ->	iPhone 4/AT&T
	 iPhone3,2 ->	iPhone 4/Other Carrier?
	 iPhone3,3 ->	iPhone 4/Other Carrier?
	 iPhone4,1 ->	??iPhone 5
	 
	 iPod1,1   -> iPod touch 1G 
	 iPod2,1   -> iPod touch 2G 
	 iPod2,2   -> ??iPod touch 2.5G
	 iPod3,1   -> iPod touch 3G
	 iPod4,1   -> iPod touch 4G
	 iPod5,1   -> ??iPod touch 5G
	 
	 iPad1,1   -> iPad 1G, WiFi
	 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
	 iPad2,1   -> iPad 2G (iProd 2,1)*/
	
	NSString *sizeString;
	
	switch (currentPlatform) {
		case UIDevice1GiPhone:
		case UIDevice3GiPhone:
		case UIDevice3GSiPhone:
		case UIDevice1GiPod:
		case UIDevice2GiPod:
		case UIDeviceiPhoneSimulatoriPhone:
		case UIDevice3GiPod:
			sizeString = @"";
			break;
		default:
			sizeString = @"@2x";
			break;
	}
	
	return sizeString;
}

#pragma mark -
#pragma mark validation methods

+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL) validatePassword: (NSString *) candidate {
    NSString *strRegex = @"^[a-zA-Z0-9ığüşöçIĞÜŞİÖÇ]{4,12}$"; //@"^(([a-zA-Z]+[0-9]{1}[a-zA-Z]*[0-9]+([a-zA-Z]*[0-9]*)*)|([a-zA-Z]+[0-9]{2,}([a-zA-Z]*[0-9]*)*)|([0-9]{1}[a-zA-Z]+[0-9]+)([a-zA-Z]*[0-9]*)*|([0-9]{2,}[a-zA-Z]+)([a-zA-Z]*[0-9]*)*)$"; 
    NSPredicate *valueTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex]; 
	
    return [valueTest evaluateWithObject:candidate];
}

+ (BOOL) validatePhoneFormat: (NSString *) candidate {
    NSString *strRegex = @"^[2-9][0-9]{2}-[0-9]{7}(-[0-9]{0,5}){0,1}$"; 
    NSPredicate *valueTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex]; 
	
    return [valueTest evaluateWithObject:candidate];
}

#pragma mark -
#pragma mark alertMessage

+ (void) alertMessage:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = 
	[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Okay" 
						   otherButtonTitles:nil];
	[alert show];
	
	[alert release];
     /*
    UICustomAlertView *alert = 
	[[UICustomAlertView alloc] initWithTitle:title message:message 
							 backgroundColor:HEXCOLOR(0xe48005ff) strokeColor:HEXCOLOR(0xf1f3de7f) delegate:nil cancelButtonTitle:@"Okay" 
						   otherButtonTitles:nil];
	[alert show];
	
	[alert release];*/
}

@end
