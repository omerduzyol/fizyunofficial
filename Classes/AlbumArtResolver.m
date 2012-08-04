//
//  AlbumArtResolver.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 9/30/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "AlbumArtResolver.h"
#import "WebRequestHelper.h"
#import "XPathQuery.h"
#import "JSON.h"

@implementation AlbumArtResolver

@synthesize callbackContext, resolveCallbackHandler, errorCallbackHandler;

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
		isBusy = NO;
		apiKeyLastFM = @"4fae1d165f922e3ad906dd09db97ef17";
		tryGoogleAPI = YES;
	}
	
	return self;
}

- (BOOL) resolveAlbumArt:(NSString *)keyword{
	if (isBusy) 
		return NO;
	lastKeyword = [keyword copy];

	NSLog(@"AlbumArtResolver: Resolving %@", keyword);
	
	[self resolveByLastFM:keyword];
	
	return YES;
}

#pragma mark -
#pragma mark LastFM API Resolver

- (void) resolveByLastFM:(NSString *)keyword{
	
	NSString *urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.search&track=%@&api_key=%@", [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], apiKeyLastFM];
	NSURL *url = [NSURL URLWithString:urlString];

	WebRequestHelper *webReq = [[WebRequestHelper alloc] init];
	
	webReq.callbackContext = self;
	//webReq.infoObject = infoSel;
	webReq.responseCallbackHandler = @selector(resolveByLastFMCallback:withResponse:);
	webReq.errorCallbackHandler = @selector(errorOnLastFMCallback:withMessage:);
	
	NSLog(@"AlbumArtResolver: Using lastfm api.");
	
	[webReq request:url method:@"GET" bodyData:nil withCachePolicy:NSURLRequestReturnCacheDataElseLoad];
	
	isBusy = YES;
	
}

- (void) resolveByLastFMCallback:(WebRequestHelper *)req withResponse:(NSData *)response {	
	NSString *albumArtPath = nil;
	NSLog(@"AlbumArtResolver: Response recieved.");

	NSArray *xObjects = PerformHTMLXPathQuery(response,@"//trackmatches/track//image");
	if([xObjects count] > 0){
/*
		//NSArray *resultset = [(NSDictionary *)[xObjects objectAtIndex:0] objectForKey:@"nodeChildArray"];
		for (NSDictionary *track in xObjects) {
			NSLog(@"track:%@", [track objectForKey:@"nodeContent"] );
		}*/
		albumArtPath = [[xObjects objectAtIndex:[xObjects count]-1] objectForKey:@"nodeContent"];
		
		NSLog(@"AlbumArtResolver: Found! - %@", albumArtPath);

	} else {
		NSLog(@"AlbumArtResolver: Not found.");
		
		if (tryGoogleAPI) {
			NSLog(@"AlbumArtResolver: Trying google api...");
			
			[self resolveByGoogle:lastKeyword];

			return;
		}
	}
	
	isBusy = NO;
	
	if (callbackContext != nil && resolveCallbackHandler != nil && [callbackContext respondsToSelector:resolveCallbackHandler]) {
		[callbackContext performSelector:resolveCallbackHandler withObject:albumArtPath];
	}		
	
	
	[req release];
}

- (void) errorOnLastFMCallback:(WebRequestHelper*)req withMessage:(NSString *)message {
	
	NSLog(@"AlbumArtResolver: Error requesting lastfm api response.");

	if (tryGoogleAPI) {
		NSLog(@"AlbumArtResolver: Trying google api...");
		
		[self resolveByGoogle:lastKeyword];			
	}
	
	isBusy = NO;
	
	[req release];
}

#pragma mark -
#pragma mark Google Image Search API Resolver

- (void) resolveByGoogle:(NSString *)keyword{

	NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [[NSString stringWithFormat:@"album art kapak %@", keyword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL *url = [NSURL URLWithString:urlString];
	
	WebRequestHelper *webReq = [[WebRequestHelper alloc] init];
	
	webReq.callbackContext = self;
	//webReq.infoObject = infoSel;
	webReq.responseCallbackHandler = @selector(resolveByGoogleCallback:withResponse:);
	webReq.errorCallbackHandler = @selector(errorOnGoogleCallback:withMessage:);
	
	NSLog(@"AlbumArtResolver: Using google api.");
	
	[webReq request:url method:@"GET" bodyData:nil withCachePolicy:NSURLRequestReturnCacheDataElseLoad];
	
	isBusy = YES;
}

- (void) resolveByGoogleCallback:(WebRequestHelper *)req withResponse:(NSData *)response {	
	NSString *albumArtPath = nil;
	NSLog(@"AlbumArtResolver: Response recieved.");
	
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSDictionary *jsonResponse = [jsonString JSONValue];		
	
	NSArray *results = [[jsonResponse objectForKey:@"responseData"] objectForKey:@"results"];
	
	if (results != nil && [results count] > 0) {
		NSDictionary *item = [results objectAtIndex:0];
		albumArtPath = [NSString stringWithString:[item objectForKey:@"url"]];
		
		NSLog(@"AlbumArtResolver: Found! - %@", albumArtPath);

	} else {
		NSLog(@"AlbumArtResolver: Not found.");
	}
	
	isBusy = NO;
	
	if (callbackContext != nil && resolveCallbackHandler != nil && [callbackContext respondsToSelector:resolveCallbackHandler]) {
		[callbackContext performSelector:resolveCallbackHandler withObject:albumArtPath];
	}
	
	[req release];
}

- (void) errorOnGoogleCallback:(WebRequestHelper*)req withMessage:(NSString *)message {
	
	NSLog(@"AlbumArtResolver: Error requesting Google api response.");

	isBusy = NO;
	
	[req release];
}

- (void)dealloc{
	[lastKeyword release];
	
	[super dealloc];
}

@end
