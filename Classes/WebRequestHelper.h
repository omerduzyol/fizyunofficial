//
//  WebRequestHelper.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebRequestHelper : NSObject {
	NSTimeInterval timeout;

	id infoObject;
	id callbackContext;
	SEL responseCallbackHandler;
	SEL errorCallbackHandler;
	
	NSMutableData *responseData;
	NSDictionary *httpHeaders;
	NSURL *domain;
}

@property (nonatomic, retain) id infoObject;
@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, retain) id callbackContext;
@property (nonatomic, assign) SEL responseCallbackHandler;
@property (nonatomic, assign) SEL errorCallbackHandler;
@property (nonatomic, retain) NSDictionary *httpHeaders;

- (id)request:(NSURL*)url method:(NSString *)requestMethod bodyData:(NSString *)data;
- (id)request:(NSURL*)url method:(NSString *)requestMethod bodyData:(NSString *)data withCachePolicy:(NSURLRequestCachePolicy)cachePolicy;
- (id) processResponse:(NSData *)response;
- (void) processError:(NSString *)errorMessage;
- (void) storeCookiesForResponse:(NSHTTPURLResponse *) response;

@end
