//
//  WebRequestHelper.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "WebRequestHelper.h"


@implementation WebRequestHelper

@synthesize httpHeaders, infoObject, timeout, callbackContext, responseCallbackHandler, errorCallbackHandler;

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
		self.timeout = 20;
		self.infoObject = nil;
		self.httpHeaders = nil;
	}
	
	return self;
}

- (id)request:(NSURL*)url method:(NSString *)requestMethod bodyData:(NSString *)data {
	return [self request:url method:requestMethod bodyData:data withCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
}

- (id)request:(NSURL*)url method:(NSString *)requestMethod bodyData:(NSString *)data withCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
	
	// TODO: throw exception if callback and context is nil
	
	domain = [[NSURL alloc] initWithString:[[url absoluteString] stringByReplacingOccurrencesOfString:[url relativePath] withString:@""]]; 
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:self.timeout];
	NSURLConnection *connection = nil;
	
	if (requestMethod == nil)
		[request setHTTPMethod:@"GET"];
	else
		[request setHTTPMethod:requestMethod];

	if (data != nil)
		[request setHTTPBody:[[data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSArray *availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:domain];
    NSDictionary *headerForCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
	
#ifdef DEBUG
	NSLog(@"%@: %@\r\nData:\r\n%@", requestMethod == nil ? @"GET":requestMethod, [url absoluteString], data);
#endif
	
	if (self.httpHeaders != nil) {
		NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] initWithDictionary:self.httpHeaders];
		[dictTemp addEntriesFromDictionary:headerForCookies];
		[request setAllHTTPHeaderFields: dictTemp];
		
#ifdef DEBUG
		NSLog(@"Request Headers:\r\n %@", [dictTemp description]);
#endif	
		[dictTemp release];
	} else {
		// setup cookies for new request
		[request setAllHTTPHeaderFields:headerForCookies];		
		
#ifdef DEBUG
		NSLog(@"Request Headers:\r\n %@", [headerForCookies description]);
#endif
	}

	
	
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	if (self.responseCallbackHandler != nil) {
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];		
		return nil;
	} else {
		NSURLResponse *syncResponse = nil;
		NSError *syncReqErr = nil;
		NSData *syncResponseData = nil;
		
		// cleanup old buffer if used before?
		if(responseData != nil)
		{	
			[responseData release];
			responseData = nil;
		}
		
		// setup sync request
		syncResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&syncResponse error:&syncReqErr];
		
		if (syncResponseData != nil){
			
			[self storeCookiesForResponse:(NSHTTPURLResponse *)syncResponse];
			
			return [self processResponse:syncResponseData];
		}
		
		if (syncReqErr != nil){ 
			[self processError:[syncReqErr description]];
		}
	}



	return nil;
}

- (id) processResponse:(NSData *)response 
{	
#ifdef DEBUG
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSLog(@"%@", jsonString);
	
	[jsonString release];
#endif
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// if success callback assigned?
	if (self.callbackContext != nil && self.responseCallbackHandler != nil && [self.callbackContext respondsToSelector:self.responseCallbackHandler])
	{
		// trigger success callback with result
		[self.callbackContext performSelector:self.responseCallbackHandler withObject:self withObject:response];
	} else {
		return response;
	}
	
	return nil;
}

- (void) processError:(NSString *)errorMessage {
	NSLog(@"Invoker: Response error: %@", errorMessage);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (self.errorCallbackHandler != nil && [self.callbackContext respondsToSelector:self.errorCallbackHandler]) {

		[self.callbackContext performSelector:self.errorCallbackHandler withObject:self withObject:errorMessage];
	}
}

- (void) storeCookiesForResponse:(NSHTTPURLResponse *) response
{
	NSDictionary *allHeaders = [response allHeaderFields];
	
	NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:allHeaders forURL:domain];
    
    // Store recieved cookies in NSHTTPCookieStorage
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:all forURL:domain mainDocumentURL:nil];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response{
	if ([response statusCode] >= 400 && [response statusCode] <= 503) {
		[self processError:[NSString stringWithFormat:@"Server response code %d",[response statusCode]]];
		responseData = nil;
		return;
	}
	
	if(responseData == nil){
		responseData = [[NSMutableData alloc] init];
		
	}
	
	NSLog(@"WebRequestHelper: Status %d", [response statusCode]);
	
	[self storeCookiesForResponse:response];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	// Store incoming data into the buffer
	if(responseData != nil)
		[responseData appendData:data];
	
	//NSLog(@"%d bytes data recvd.", [data length]);
	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if(responseData == nil)
		return;
	
	NSLog(@"WebRequestHelper: Response recieved.");
	
	[self processResponse:[NSData dataWithData:responseData]];
	
	[connection release];
	[responseData release];
	responseData = nil; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if (responseData != nil){
		[responseData release];
		responseData = nil; 
	}
	
	NSString *errDesc = [error description];
	NSLog(@"WebRequestHelper: Request error occurred. %@", errDesc);
	
	[self processError:errDesc];
	
	[connection release];
}

-(void) dealloc{
	if (infoObject != nil)
	{
		[infoObject release];
		infoObject = nil;
	}
	
	if (httpHeaders != nil) {
		[httpHeaders release];
	}
	
	[callbackContext release];
	
	[super dealloc];
}

@end
