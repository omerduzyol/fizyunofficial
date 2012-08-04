//
//  Fizy.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FizySongInfo.h"
#import "FizySearchItem.h"
#import "FizyPlayer.h"
#import "FizyQueueChangedInfo.h"
#import "FizyPlaylistItem.h"
#import "ProfileProvider.h"
#import "AlbumArtResolver.h"

@class WebRequestHelper;

@interface Fizy : NSObject {
	id searchCallbackContext;
	id getSongCallbackContext;
	id nowPlayingCallbackContext;
	id completedCallbackContext;
    id providerCallbackContext;
    id loginCallbackContext;
    id getPlaylistsCallbackContext;
    id getSongsCallbackContext;
    id renamePlaylistCallbackContext;
    id addSongCallbackContext;
    id removeSongCallbackContext;
    id orderSongCallbackContext;
	
	SEL searchCallback;
	SEL getSongCallback;
	SEL nowPlayingCallback;
	SEL completedCallback;
    SEL providerSetCallback;
    SEL providerSetError;
    SEL loginCallback;
    SEL loginError;
    SEL getPlaylistsCallback;
    SEL getPlaylistsError;
    SEL getSongsCallback;
    SEL getSongsError;
    SEL renamePlaylistCallback;
    SEL renamePlaylistError;
    SEL addSongCallback;
    SEL addSongError;
    SEL removeSongCallback;
    SEL removeSongError;
    SEL orderSongCallback;
    SEL orderSongError;
	
	WebRequestHelper *searchRequest;
	WebRequestHelper *getSongRequest;
	WebRequestHelper *nowPlayingRequest;
	WebRequestHelper *completedRequest;
    WebRequestHelper *loginRequest;
    WebRequestHelper *getPlaylistsRequest;
    WebRequestHelper *getSongsRequest;
    WebRequestHelper *renamePlaylistRequest;
    WebRequestHelper *addSongRequest;
    WebRequestHelper *removeSongRequest;
    WebRequestHelper *orderSongRequest;
	
	WebRequestHelper *providerRequest;
	
	FizyPlayer *player;
    
    BOOL isLoggedIn;
}

@property (nonatomic, retain) id searchCallbackContext;
@property (nonatomic, retain) id getSongCallbackContext;
@property (nonatomic, retain) id nowPlayingCallbackContext;
@property (nonatomic, retain) id completedCallbackContext;
@property (nonatomic, retain) id providerCallbackContext;
@property (nonatomic, retain) id loginCallbackContext;
@property (nonatomic, retain) id getPlaylistsCallbackContext;
@property (nonatomic, retain) id getSongsCallbackContext;
@property (nonatomic, retain) id renamePlaylistCallbackContext;
@property (nonatomic, retain) id addSongCallbackContext;
@property (nonatomic, retain) id removeSongCallbackContext;
@property (nonatomic, retain) id orderSongCallbackContext;

@property (nonatomic, assign) SEL searchCallback;
@property (nonatomic, assign) SEL getSongCallback;
@property (nonatomic, assign) SEL nowPlayingCallback;
@property (nonatomic, assign) SEL completedCallback;
@property (nonatomic, assign) SEL providerSetCallback;
@property (nonatomic, assign) SEL providerSetError;
@property (nonatomic, assign) SEL loginCallback;
@property (nonatomic, assign) SEL loginError;
@property (nonatomic, assign) SEL getPlaylistsCallback;
@property (nonatomic, assign) SEL getPlaylistsError;
@property (nonatomic, assign) SEL getSongsCallback;
@property (nonatomic, assign) SEL getSongsError;
@property (nonatomic, assign) SEL renamePlaylistCallback;
@property (nonatomic, assign) SEL renamePlaylistError;
@property (nonatomic, assign) SEL addSongCallback;
@property (nonatomic, assign) SEL addSongError;
@property (nonatomic, assign) SEL removeSongCallback;
@property (nonatomic, assign) SEL removeSongError;
@property (nonatomic, assign) SEL orderSongCallback;
@property (nonatomic, assign) SEL orderSongError;

@property (nonatomic, retain) FizyPlayer *player;

@property (nonatomic, assign) BOOL isLoggedIn;

+ (Fizy *)sharedFizy;

- (NSString *) getServerPath;

- (void) search:(NSString*)query 
		   page:(NSInteger)p 
		   type:(NSString *)t 
		quality:(NSString *)q 
	   duration:(NSString *)d;

- (void) getSong:(NSString *)sid;
- (void) nowPlaying:(NSString *)sid;
- (void) setProvider:(BOOL)isActive forProvider:(NSString *)provider;
- (void) completed:(NSString *)sid;

- (void) login:(NSString *)user withPassword:(NSString *)password;
- (BOOL) getPlaylists;
- (BOOL) getSongs:(NSString *)pid;
- (BOOL) renamePlaylist:(NSString *)pid withTitle:(NSString *)title;
- (BOOL) addSong:(NSString *)pid withSid:(NSString *)sid;
- (BOOL) removeSong:(NSString *)pid withSid:(NSString *)sid;
- (BOOL) orderSong:(NSString *)pid withOrder:(NSString *)order;

- (void) errorCallback:(WebRequestHelper *)request withMessage:(NSString *)errorMessage;

@end
