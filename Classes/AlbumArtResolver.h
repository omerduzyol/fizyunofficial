//
//  AlbumArtResolver.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 9/30/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WebRequestHelper;

@interface AlbumArtResolver : NSObject {
	BOOL isBusy;
	BOOL tryGoogleAPI;
	
	NSString *apiKeyLastFM;
	id callbackContext;
	SEL resolveCallbackHandler;
	SEL errorCallbackHandler;
	NSString *lastKeyword;
}

@property (nonatomic, retain) id callbackContext;
@property (nonatomic, assign) SEL resolveCallbackHandler;
@property (nonatomic, assign) SEL errorCallbackHandler;

- (BOOL) resolveAlbumArt:(NSString *)keyword;
- (void) resolveByLastFM:(NSString *)keyword;
- (void) resolveByLastFMCallback:(WebRequestHelper *)req withResponse:(NSData *)response;
- (void) errorOnLastFMCallback:(WebRequestHelper*)req withMessage:(NSString *)message;

- (void) resolveByGoogle:(NSString *)keyword;
- (void) resolveByGoogleCallback:(WebRequestHelper *)req withResponse:(NSData *)response;
- (void) errorOnGoogleCallback:(WebRequestHelper*)req withMessage:(NSString *)message;

@end
