//
//  FizySongResolver.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/19/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "FizySongResolver.h"
#import "Fizy.h"
#import "JSON.h"

@implementation FizySongResolver

@synthesize item, indexPathInTableView, delegate, activeDownload, infoConnection;

#pragma mark

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
	
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://fizy.com/fizy::getSong"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
	NSString *data = [NSString stringWithFormat:@"SID=%@", item.ID];
	
	[req setHTTPMethod:@"POST"];
	[req setHTTPBody:[[data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	
    self.infoConnection = conn;
    [conn release];
	
	NSLog(@"song resolver: started %@", item.title);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancelDownload
{
    [self.infoConnection cancel];
    self.infoConnection = nil;
    self.activeDownload = nil;
	
	NSLog(@"song resolver: cancelled %@", item.title);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.infoConnection = nil;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonString = [[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding];
	
	NSDictionary *songResponse = [jsonString JSONValue];
	
	[jsonString release];
	
	FizySongInfo *songInfo = [songResponse convertToType:[FizySongInfo class]];
	songInfo.timestamp = [NSDate date];

	[songInfo initSong];
	[songInfo generateArtistAndSongname];

	self.item.songInfo = songInfo;
	
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.infoConnection = nil;
	
    // call our delegate and tell it that our icon is ready for display
    [delegate songResolved:self.indexPathInTableView];
	
	//NSLog(@"image download finished %@", [item.imageURL description]);
	
	NSLog(@"song resolver: finished %@", item.title);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
    [item release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [infoConnection cancel];
    [infoConnection release];
    
    [super dealloc];
}



@end
