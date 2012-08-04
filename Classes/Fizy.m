//
//  Fizy.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "Fizy.h"
#import "SynthesizeSingleton.h"
#import "WebRequestHelper.h"
#import "JSON.h"

@implementation Fizy

@synthesize searchCallbackContext, getSongCallbackContext, nowPlayingCallbackContext, completedCallbackContext, providerCallbackContext, searchCallback, getSongCallback, nowPlayingCallback, completedCallback, providerSetCallback, providerSetError, loginCallback, loginError, getPlaylistsCallback,getPlaylistsError, getSongsCallback, getSongsError, loginCallbackContext, getPlaylistsCallbackContext, getSongsCallbackContext, renamePlaylistCallbackContext, addSongCallbackContext, removeSongCallbackContext, renamePlaylistCallback, renamePlaylistError, addSongCallback,addSongError, removeSongCallback, removeSongError, orderSongCallback,orderSongError, orderSongCallbackContext;

@synthesize isLoggedIn, player;

SYNTHESIZE_SINGLETON_FOR_CLASS(Fizy);

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
		
        NSArray * arrCookieCheck = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] filteredArrayUsingPredicate:    [NSPredicate predicateWithFormat:@"name==\"fz[token]\""]];
        
        if(arrCookieCheck != nil && [arrCookieCheck count] > 0 && [arrCookieCheck objectAtIndex:0] != nil)
            self.isLoggedIn = YES;
        else
            self.isLoggedIn = NO;
        
		searchRequest = [[WebRequestHelper alloc] init];
		searchRequest.callbackContext = self;
		searchRequest.responseCallbackHandler = @selector(_searchCallback:response:);
		searchRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
		
		
		getSongRequest = [[WebRequestHelper alloc] init];
		getSongRequest.callbackContext = self;
		getSongRequest.responseCallbackHandler = @selector(_getSongCallback:response:);
		getSongRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
		
		providerRequest = [[WebRequestHelper alloc] init];
        //providerRequest.callbackContext = self;
        //providerRequest.responseCallbackHandler = @selector(_setProviderCallback:response:);
        //providerRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
		
        loginRequest = [[WebRequestHelper alloc] init];
        loginRequest.callbackContext = self;
        loginRequest.responseCallbackHandler = @selector(_loginCallback:response:);
        loginRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        getPlaylistsRequest = [[WebRequestHelper alloc] init];
        getPlaylistsRequest.callbackContext = self;
        getPlaylistsRequest.responseCallbackHandler = @selector(_getPlaylistsCallback:response:);
        getPlaylistsRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        getSongsRequest = [[WebRequestHelper alloc] init];
        getSongsRequest.callbackContext = self;
        getSongsRequest.responseCallbackHandler = @selector(_getSongsCallback:response:);
        getSongsRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        
        renamePlaylistRequest = [[WebRequestHelper alloc] init];
        renamePlaylistRequest.callbackContext = self;
        renamePlaylistRequest.responseCallbackHandler = @selector(_renamePlaylistCallback:response:);
        renamePlaylistRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        addSongRequest = [[WebRequestHelper alloc] init];
        addSongRequest.callbackContext = self;
        addSongRequest.responseCallbackHandler = @selector(_addSongCallback:response:);
        addSongRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        removeSongRequest = [[WebRequestHelper alloc] init];
        removeSongRequest.callbackContext = self;
        removeSongRequest.responseCallbackHandler = @selector(_removeSongCallback:response:);
        removeSongRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
        orderSongRequest = [[WebRequestHelper alloc] init];
        orderSongRequest.callbackContext = self;
        orderSongRequest.responseCallbackHandler = @selector(_orderSongCallback:response:);
        orderSongRequest.errorCallbackHandler = @selector(errorCallback:withMessage:);
        
		player = [[FizyPlayer alloc] init];
	}
	
	return self;
}

- (NSString *) getServerPath{
	return @"http://fizy.com";
}

- (void) search:(NSString*)query 
		   page:(NSInteger)p 
		   type:(NSString *)t 
		quality:(NSString *)q 
	   duration:(NSString *)d{
	
	// TODO: check query parameter is nil
	
	NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search", [self getServerPath]]];
						  
	
	srand ( time(NULL) );

	NSString *searchParams = [NSString stringWithFormat:@"query=%@&p=%d&t=%@&q=%@&d=%@&qix=%d",
							  query, p,
							  ((t == nil || [t isEqualToString:@""]) ? @"all" : t),
							  ((q == nil || [q isEqualToString:@""]) ? @"all" : q),
							  ((d == nil || [d isEqualToString:@""]) ? @"all" : d),
							  rand()];
	
	[searchRequest request:targetURL method:@"POST" bodyData:searchParams];
	
}

- (void) _searchCallback:(WebRequestHelper *)request response:(NSData *)response {
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSDictionary *searchResponse = [jsonString JSONValue];
	
	[jsonString release];
	
	NSDictionary *result = nil;
	if ([searchResponse count] > 0) {
		NSMutableArray *searchItems = [[NSMutableArray alloc] init];
		for (NSDictionary *item in [searchResponse objectForKey:@"results"]) {
			FizySearchItem *searchItem = [item convertToType:[FizySearchItem class]];
		
			[searchItem generateArtistAndSongname];
		
			[searchItems addObject:searchItem];
		}
		
		result = [[NSDictionary alloc] initWithObjectsAndKeys:searchItems, @"results",
				  [searchResponse objectForKey:@"currentpage"], @"currentpage",
				  [searchResponse objectForKey:@"total"], @"total",
				  [searchResponse objectForKey:@"totalpages"], @"totalpages", nil];
		
		if (self.searchCallbackContext != nil && [self.searchCallbackContext respondsToSelector:self.searchCallback]) {
			[self.searchCallbackContext performSelector:self.searchCallback withObject:[result retain]];
		}
		
	} else {
		if (self.searchCallbackContext != nil && [self.searchCallbackContext respondsToSelector:self.searchCallback]) {
			[self.searchCallbackContext performSelector:self.searchCallback withObject:nil];
		}
		
	}

	if (result != nil) {
		[result release];	
	}
}


- (void) _getSongCallback:(WebRequestHelper *)request response:(NSData *)response {
	NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSDictionary *songResponse = [jsonString JSONValue];
	
	[jsonString release];
	
	FizySongInfo *songInfo = [songResponse convertToType:[FizySongInfo class]];
	songInfo.timestamp = [NSDate date];
	
	[songInfo generateArtistAndSongname];
	[songInfo initSong];
	
	if (self.getSongCallbackContext != nil && [self.getSongCallbackContext respondsToSelector:self.getSongCallback]) {
		[self.getSongCallbackContext performSelector:self.getSongCallback withObject:[songInfo retain]];
	}
}

- (void) getSong:(NSString *)sid{
	NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::getSong", [self getServerPath]]];
	
	[getSongRequest request:targetURL method:@"POST" bodyData:[NSString stringWithFormat:@"SID=%@&isPlaylist=0", sid]];
}

- (void) nowPlaying:(NSString *)sid{
	NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::nowPlaying", [self getServerPath]]];
	
	[nowPlayingRequest request:targetURL method:@"POST" bodyData:[NSString stringWithFormat:@"SID=%@", sid]];
}

- (void) setProvider:(BOOL)isActive forProvider:(NSString *)provider{
	//http://fizy.com/fizy::metacafe::true
	
	NSString *actValue = isActive ? @"true" : @"false";
	
	 //dictionary of attributes for the new cookie
	 NSDictionary *newCookieDict = [NSMutableDictionary
	 dictionaryWithObjectsAndKeys:@"fizy.com", NSHTTPCookieDomain,
	 provider, NSHTTPCookieName,
	 @"/", NSHTTPCookiePath,
	 actValue, NSHTTPCookieValue, nil];

	//create a new cookie
	 NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:newCookieDict];
	 
	 [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
	
	NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::%@::%@", [self getServerPath], provider, actValue]];
	
	[providerRequest request:targetURL method:@"GET" bodyData:nil];
}

- (void) login:(NSString *)user withPassword:(NSString *)password{
    //username=omerduzyol&password=omeromer&login=1
    
    [loginRequest request:[NSURL URLWithString:[NSString stringWithFormat:@"%@/login", [self getServerPath]]] method:@"POST" bodyData:[NSString stringWithFormat:@"username=%@&password=%@&login=1",user,password]];
    
}

- (void) _loginCallback:(WebRequestHelper *)request response:(NSData *)response {
    //NSString *htmlString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

    NSArray * arrCookieCheck = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name==\"fz[token]\""]];
    
    if(arrCookieCheck != nil && [arrCookieCheck count] > 0 && [arrCookieCheck objectAtIndex:0] != nil)
        self.isLoggedIn = YES;
    else
        self.isLoggedIn = NO;
    
    if (self.loginCallbackContext != nil && [self.loginCallbackContext respondsToSelector:self.loginCallback]) {
		[self.loginCallbackContext performSelector:self.loginCallback withObject:response];
	}
}

- (BOOL) getPlaylists{
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::getPlaylists",[self getServerPath]]];
    
    [getPlaylistsRequest request:requestUrl method:@"POST" bodyData:nil];
    
    return YES;
}

- (void) _getPlaylistsCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

    NSArray *playlists = [jsonString JSONValue];
	
	[jsonString release];

    NSMutableArray *arrPlaylists = [NSMutableArray new];    
    
    for (NSDictionary * list in playlists) {
        FizyPlaylistItem *item = [list convertToType:[FizyPlaylistItem class]];
        /*
        FizyPlaylistItem *item = [FizyPlaylistItem new];
        
        item.ID = [list objectForKey:@"ID"];
        item.title = [list objectForKey:@"title"];
        item.is_shuffle_on = [[list objectForKey:@"is_shuffle_on"] boolValue];*/
        
        [arrPlaylists addObject:item];

    }
    
    if (self.getPlaylistsCallbackContext != nil && [self.getPlaylistsCallbackContext respondsToSelector:self.getPlaylistsCallback]) {
		[self.getPlaylistsCallbackContext performSelector:self.getPlaylistsCallback withObject:[arrPlaylists retain]];
	}
}

- (BOOL) renamePlaylist:(NSString *)pid withTitle:(NSString *)title{
    //PID=2168748&name=merhabalar%20ben%20listeyim
    //fizy:renamePlaylist
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::renamePlaylist",[self getServerPath]]];
    
    [renamePlaylistRequest request:requestUrl method:@"GET" bodyData:[NSString stringWithFormat:@"PID=%@&name=%@", pid, title]];
    
    return YES;
}

- (void) _renamePlaylistCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
    NSDictionary *renameResponse  = [jsonString JSONValue];
    
    if(renameResponse!=nil && [renameResponse objectForKey:@"error"] == nil){
        FizyPlaylistItem *item = [renameResponse convertToType:[FizyPlaylistItem class]];

        if (self.renamePlaylistCallbackContext != nil && [self.renamePlaylistCallbackContext respondsToSelector:self.renamePlaylistCallback]) {
            [self.renamePlaylistCallbackContext performSelector:self.renamePlaylistCallback withObject:[item retain]];
        }
    } else {
        if (self.renamePlaylistCallbackContext != nil && [self.renamePlaylistCallbackContext respondsToSelector:self.renamePlaylistError]) {
            [self.renamePlaylistCallbackContext performSelector:self.renamePlaylistError withObject:[renameResponse retain]];
        }
    }
    
}

- (BOOL) addSong:(NSString *)pid withSid:(NSString *)sid{
    //PID=2168748&SID=1syqjb&rockncoke=0
    //fizy:addSong
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::addSong",[self getServerPath]]];
    
    [addSongRequest request:requestUrl method:@"POST" bodyData:[NSString stringWithFormat:@"PID=%@&SID=%@&rockncoke=0", pid, sid]];
    
    return YES;
}

- (void) _addSongCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
    NSDictionary *songResponse  = [jsonString JSONValue];
    
    if(songResponse!=nil && [songResponse objectForKey:@"error"] == nil){
        FizySongInfo *item = [songResponse convertToType:[FizySongInfo class]];
        [item generateArtistAndSongname];
        [item initSong];
        
        item.isDirty = YES;
        
        if (self.addSongCallbackContext != nil && [self.addSongCallbackContext respondsToSelector:self.addSongCallback]) {
            [self.addSongCallbackContext performSelector:self.addSongCallback withObject:[item retain]];
        }
    } else {
        if (self.addSongCallbackContext != nil && [self.addSongCallbackContext respondsToSelector:self.addSongError]) {
            [self.addSongCallbackContext performSelector:self.addSongError withObject:[songResponse retain]];
        }
    }
}

- (BOOL) orderSong:(NSString *)pid withOrder:(NSString *)order{
    //PID	2168748
    //order	17nq7v,14ytoe,16mf6x,16l4av,159vnm,34o7ro,1syqjb
    
    //{"code":200,"order":"17nq7v,14ytoe,16mf6x,16l4av,159vnm,34o7ro,1syqjb"}
    
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::orderSong",[self getServerPath]]];
    
    [addSongRequest request:requestUrl method:@"POST" bodyData:[NSString stringWithFormat:@"PID=%@&order=%@", pid, order]];
    
    return YES;
}

- (void) _orderSongCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
    NSDictionary *songResponse  = [jsonString JSONValue];
    
    if(songResponse!=nil && [songResponse objectForKey:@"error"] == nil){
        
        if (self.orderSongCallbackContext != nil && [self.orderSongCallbackContext respondsToSelector:self.orderSongCallback]) {
            [self.orderSongCallbackContext performSelector:self.orderSongCallback withObject:[songResponse retain]];
        }
    } else {
        if (self.orderSongCallbackContext != nil && [self.orderSongCallbackContext respondsToSelector:self.orderSongError]) {
            [self.orderSongCallbackContext performSelector:self.orderSongError withObject:[songResponse retain]];
        }
    }
}


- (BOOL) removeSong:(NSString *)pid withSid:(NSString *)sid{
    //PID=2168748&SID=1syqjb
    //fizy:removeSong
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::removeSong",[self getServerPath]]];
    
    [removeSongRequest request:requestUrl method:@"POST" bodyData:[NSString stringWithFormat:@"PID=%@&SID=%@", pid, sid]];
    
    return YES;
}

- (void) _removeSongCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
    NSDictionary *songResponse  = [jsonString JSONValue];
    
    if(songResponse!=nil && [songResponse objectForKey:@"error"] == nil){
        
        if (self.removeSongCallbackContext != nil && [self.removeSongCallbackContext respondsToSelector:self.removeSongCallback]) {
            [self.removeSongCallbackContext performSelector:self.removeSongCallback withObject:[songResponse retain]];
        }
    } else {
        if (self.removeSongCallbackContext != nil && [self.removeSongCallbackContext respondsToSelector:self.removeSongError]) {
            [self.removeSongCallbackContext performSelector:self.removeSongError withObject:[songResponse retain]];
        }
    }
    
}

- (BOOL) getSongs:(NSString *)pid{
    if(!isLoggedIn)
        return NO;
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::getSongs",[self getServerPath]]];
    
    [getSongsRequest request:requestUrl method:@"POST" bodyData:[NSString stringWithFormat:@"PID=%@&self=1", pid]];
    
    return YES;
}

- (void) _getSongsCallback:(WebRequestHelper *)request response:(NSData *)response {
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
    NSArray *songsResponse  = [jsonString JSONValue];
    
    NSMutableArray *arrSongs = [NSMutableArray new];
    
    if (songsResponse != nil) {
        for (NSDictionary *songItem in songsResponse) {
            FizySongInfo *songInfo = [songItem convertToType:[FizySongInfo class]];
            songInfo.timestamp = [NSDate date];
            
            [songInfo generateArtistAndSongname];
            [songInfo initSong];
            
            songInfo.isDirty = YES;
            songInfo.source = @"";
            
            [arrSongs addObject:songInfo];
        }
    }
    
	
	[jsonString release];
	
	
	if (self.getSongsCallbackContext != nil && [self.getSongsCallbackContext respondsToSelector:self.getSongsCallback]) {
		[self.getSongsCallbackContext performSelector:self.getSongsCallback withObject:[arrSongs retain]];
	}
    
}


- (void) _setProviderCallback:(WebRequestHelper *)request response:(NSData *)response {
    
    if (self.providerCallbackContext != nil && [self.providerCallbackContext respondsToSelector:self.providerSetCallback]) {
		[self.providerCallbackContext performSelector:self.providerSetCallback withObject:response];
	}
}
    
- (void) errorCallback:(WebRequestHelper *)request withMessage:(NSString *)errorMessage{
    
    if (request == providerRequest) {
        if (self.providerCallbackContext != nil && [self.providerCallbackContext respondsToSelector:self.providerSetError]) {
            [self.providerCallbackContext performSelector:self.providerSetError withObject:[errorMessage retain]];
        }
    }
}

- (void) completed:(NSString *)sid{
	NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fizy::completed", [self getServerPath]]];
	
	[completedRequest request:targetURL method:@"POST" bodyData:[NSString stringWithFormat:@"SID=%@", sid]];
}

@end
