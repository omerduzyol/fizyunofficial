//
//  Utility.h
//  DominosAciktik
//
//  Created by Ömer Düzyol on 1/20/11.
//  Copyright 2011 MagiClick Digital Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBProgressHUD;

@interface Utility : NSObject {

}

+ (id) findObjectInArray:(NSArray*)arrObjects byTag:(NSInteger)tag;
+ (MBProgressHUD *) sharedHUD;
+ (id) performSelectorOnAppDelegate:(NSString *)selector;
+ (id) deepCopyViaArchiving:(id<NSCoding>)anObject;

+ (BOOL) validateEmail: (NSString *) candidate;
+ (BOOL) validatePassword: (NSString *) candidate;
+ (BOOL) validatePhoneFormat: (NSString *) candidate;

+ (void) alertMessage:(NSString *)title message:(NSString *)message;
+ (NSString *) determineImageSize;
+ (NSString *) determineImageMultiplier;

@end
