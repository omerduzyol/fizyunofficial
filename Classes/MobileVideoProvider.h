//
//  MobileVideoProvider.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/14/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WebRequestHelper;

@interface MobileVideoProvider : NSObject {

}

+ (MobileVideoProvider *)sharedMobileVideoProvider;

-(WebRequestHelper *) search:(NSString*)query forProvider:(int)provider withCallback:(SEL)sel ofContext:(id)context;
- (void) searchCallback:(WebRequestHelper *)req withResponse:(NSData *)response;

@end
