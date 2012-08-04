//
//  MobileVideoProvider.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/14/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "MobileVideoProvider.h"
#import "SynthesizeSingleton.h"
#import "WebRequestHelper.h"
#import "SELInfoObject.h"
#import "JSON.h"

@implementation MobileVideoProvider

SYNTHESIZE_SINGLETON_FOR_CLASS(MobileVideoProvider);


//
// init
//
// Init method for the object.
//
- (id)init
{
	self = [super init];
	if (self != nil)
	{
	
	}	

	return self;
}

-(WebRequestHelper *) search:(NSString*)query forProvider:(int)provider withCallback:(SEL)sel ofContext:(id)context {

	// http://m.youtube.com/results?ajax=1&layout=mobile&q=video:HUfiUU33oK8&search_type=&tsp=1&uploaded=
	// http://www.dailymotion.com/embed/video/xago3g
	
	WebRequestHelper *webReq = [[WebRequestHelper alloc] init];
	NSURL *reqUrl = nil;
	
	SELInfoObject *infoSel = [[SELInfoObject alloc] init];
	infoSel.callback = sel;
	infoSel.context = context;
	infoSel.reference = provider;
	
	if (provider == 1) {
		reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/results?ajax=1&layout=mobile&q=%@&search_type=&tsp=1&uploaded=", query]];
		
		webReq.httpHeaders = [NSDictionary dictionaryWithObject:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7" 
														 forKey:@"User-Agent"];
	} else if (provider == 2) {
		reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.dailymotion.com/embed/video/%@", query]];
		
		webReq.httpHeaders = [NSDictionary dictionaryWithObject:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7" 
														 forKey:@"User-Agent"];
	}

	webReq.callbackContext = self;
	webReq.infoObject = infoSel;
	webReq.responseCallbackHandler = @selector(searchCallback:withResponse:);
	webReq.errorCallbackHandler = @selector(errorCallback:withMessage:);
	
	[webReq request:reqUrl method:@"GET" bodyData:nil];
	
	return webReq;
}
	
- (void) searchCallback:(WebRequestHelper *)req withResponse:(NSData *)response {
	
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	SELInfoObject *info = (SELInfoObject *)req.infoObject;

	NSDictionary *jsonResponse = nil;
	
	if (info.reference == 1) {
		jsonResponse = [[jsonString substringFromIndex:4] JSONValue];		
	} else if (info.reference == 2) {
		
		NSRange scriptStart =  [jsonString rangeOfString:@"var info = {"];
		NSRange scriptEnd =  [jsonString rangeOfString:@"};"];
		
		NSRange parseRange;
		
		parseRange.location = scriptStart.location + scriptStart.length-1;
		parseRange.length =  (scriptEnd.location + scriptEnd.length) - parseRange.location;
		
		NSString *inlineJs = [jsonString substringWithRange: parseRange];
		
		jsonResponse = [inlineJs JSONValue];
	}
	
	[jsonString release];

	
	if ([info.context respondsToSelector:info.callback]) {
		[info.context performSelector:info.callback withObject:jsonResponse];
	}
	
	[req release];
}

- (void) errorCallback:(WebRequestHelper*)req withMessage:(NSString *)message {
	
	
	[req release];
}

@end
