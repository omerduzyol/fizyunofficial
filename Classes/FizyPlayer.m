//
//  FizyPlayer.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/10/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "FizyPlayer.h"
#import "FizyQueueChangedInfo.h"
#import "NowPlayingViewController.h"
#import "ProfileProvider.h"

NSString * const FZPlayerQueueChangedNotification = @"FZPlayerQueueChangedNotification";
NSString * const FZPlayerPlayModeChangedNotification = @"FZPlayerPlayModeChangedNotification";
NSString * const FZPlayerSongChangedNotification = @"FZPlayerSongChangedNotification";

@implementation FizyPlayer

@synthesize nowPlaying, songQueue, isJumping, queueIndex;

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
        NSMutableDictionary * dict = [[ProfileProvider sharedProfileProvider] settings];
        
        isShuffleOn = [[dict objectForKey:@"shuffle"] boolValue];
        isRepeatOn = [[dict objectForKey:@"repeat"] boolValue];
        
		songQueue = [NSMutableArray new];
		queueIndex = -1;
        
        
	}
	
	return self;
}

- (void) play{
	[nowPlaying play];
}

- (void) togglePlay{
	[nowPlaying togglePlay];
}

- (void) pause{
	[nowPlaying pause];
}

- (void) stop{
	[nowPlaying stop];
}

- (void) nextSong{
	[nowPlaying nextSong];
}

- (void) prevSong{
	[nowPlaying prevSong];
}

- (void) setCurrentSong:(FizySongInfo *)newSong{
	[nowPlaying setCurrentSong:newSong];
}

- (FizySongInfo *) getCurrentSong
{
	return [nowPlaying getCurrentSong];
}

- (FizySongInfo *) getNextSong
{
	NSInteger nextIndex = queueIndex+1;
	NSInteger totalSongs = [songQueue count];
	if (totalSongs == 0) {
		return nil;
	}

	if (nextIndex > totalSongs-1) {
		if (!isRepeatOn) {	
			return nil;	
		} else {
			nextIndex = 0;
		}
	} 
	
	return [songQueue objectAtIndex:nextIndex];
}

- (FizySongInfo *) getPrevSong
{
	NSInteger prevIndex = queueIndex-1;
	if (prevIndex < 0) {
		return nil;
	}
	
	return [songQueue objectAtIndex:prevIndex];
}

- (BOOL) isBusy{
	return nowPlaying.isBusy;
}

- (BOOL) checkSongQueued:(FizySongInfo *)song {
	NSInteger row = [songQueue indexOfPredicate:[NSPredicate predicateWithFormat:@"ID == %@", song.ID]];
	return (row != NSNotFound);
}

- (void) addSongQueue:(FizySongInfo *)newSong toBeginning:(BOOL)beginning
{
	// check current playing song queued before?
	FizySongInfo *playingSong = [self getCurrentSong];
	if (playingSong != nil && playingSong != newSong) {
		NSInteger playingRow = [songQueue indexOfPredicate:[NSPredicate predicateWithFormat:@"ID == %@", playingSong.ID]];
		if (playingRow == NSNotFound) {
			[self addSongQueue:playingSong toBeginning:YES];
		}
	}
	//  && [songQueue count] == queueIndex+1
	NSInteger insertedAt = 0;
	if (beginning) {
		[songQueue insertObject:newSong atIndex:queueIndex+1];	
		insertedAt = queueIndex+1;
	} else {
		[songQueue addObject:newSong];	
		insertedAt = [songQueue count]-1;
	}
	
	if (playingSong == newSong && queueIndex == -1) {
		queueIndex = insertedAt;
	}
	
	
	FizyQueueChangedInfo *info = [[FizyQueueChangedInfo new] autorelease];
	
	info.songInfo = newSong;
	info.reason = FZ_QUEUECHANGED_FOR_ADD;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerQueueChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:info forKey:@"info"]];
	
	isQueueSaved = NO;
}

- (void) moveSongFromIndex:(NSUInteger)fromIndex toIndexPath:(NSUInteger)toIndex {
	FizySongInfo *movedSong = [self.songQueue objectAtIndex:fromIndex];
	
	[self.songQueue moveObjectFromIndex:fromIndex
							  toIndex:toIndex];
	
	if (queueIndex == fromIndex) {
		queueIndex = toIndex;
	} else if (queueIndex == toIndex) {
		queueIndex = fromIndex;
	}
	
	FizyQueueChangedInfo *info = [[FizyQueueChangedInfo new] autorelease];
	
	info.songInfo = movedSong;
	info.reason = FZ_QUEUECHANGED_FOR_REORDER;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerQueueChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:info forKey:@"info"]];
	
	isQueueSaved = NO;
	
}

- (BOOL) setQueueIndex:(FizySongInfo *)song {
	NSInteger row = [songQueue indexOfPredicate:[NSPredicate predicateWithFormat:@"ID == %@", song.ID]];
	if (row == NSNotFound) {
		return NO;
	} else {
		queueIndex = row;
	}
	
	NSLog(@"Player: queue index: %d", row);
	return YES;
}

- (BOOL) isQueuePlaying {
	FizySongInfo *playingSong = [self getCurrentSong];
	if (playingSong != nil) {
		NSInteger playingRow = [songQueue indexOfPredicate:[NSPredicate predicateWithFormat:@"ID == %@", playingSong.ID]];
		if (playingRow == NSNotFound) {
			return NO;
		} else {
			return YES;
		}
	}
	
	return NO;
}

- (NSInteger) saveQueueAsPlaylist:(NSString *)playlistName
{
    NSMutableArray *playlists = [[ProfileProvider sharedProfileProvider] playlists];
    
    NSMutableDictionary *dictPlaylist = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrItems = [[NSMutableArray alloc] init];

    [dictPlaylist setObject:playlistName forKey:@"name"];	
	
	for (FizySongInfo *song in songQueue) {		
		NSMutableDictionary *dictJson = [[NSMutableDictionary alloc] init];
		
		[dictJson setObject:song.ID forKey:@"ID"];
		[dictJson setObject:song.duration forKey:@"duration"];
		[dictJson setObject:song.provider forKey:@"provider"];
		[dictJson setObject:song.providerNumber forKey:@"providerNumber"];
		[dictJson setObject:song.source forKey:@"source"];
		[dictJson setObject:song.title forKey:@"title"];
		[dictJson setObject:song.artist forKey:@"artist"];
		[dictJson setObject:song.songname forKey:@"songname"];
		[dictJson setObject:song.type forKey:@"type"];
		[dictJson setObject:(song.requiresHTTPStreaming ? @"true":@"false") forKey:@"requiresHTTPStreaming"];
		[dictJson setObject:@"true" forKey:@"isDirty"];
		[dictJson setObject:(song.canPlay ? @"true":@"false") forKey:@"canPlay"];
		
		[arrItems addObject:dictJson];
		
	}
    
    [dictPlaylist setObject:[arrItems retain] forKey:@"items"];
    
    [playlists addObject:[dictPlaylist retain]];
    
    [[ProfileProvider sharedProfileProvider] saveConfig];
    
    [arrItems release];
    [dictPlaylist release];
}

- (BOOL) removeSongFromQueue:(NSUInteger)index{
	if (index >= [songQueue count]) {
		return NO;
	}
	
	FizySongInfo *song = [songQueue objectAtIndex:index];
	
	[songQueue removeObjectAtIndex:index];
	
	
	FizySongInfo *currentSong = [self getCurrentSong];
	
	NSInteger playingIndex = [songQueue indexOfPredicate:[NSPredicate predicateWithFormat:@"ID == %@", currentSong.ID]];
	if (playingIndex == NSNotFound) {
		queueIndex = -1;
	} else if (playingIndex != queueIndex) {
		queueIndex = playingIndex;
	}
	
	FizyQueueChangedInfo *info = [[FizyQueueChangedInfo new] autorelease];
	
	info.songInfo = song;
	info.reason = FZ_QUEUECHANGED_FOR_REMOVE;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerQueueChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:info forKey:@"info"]];
	
	[song release];
	
	isQueueSaved = NO;
	
	return YES;
}

- (void) clearQueue
{
	//
	for (NSObject *obj in songQueue) {		
		[obj release];
	}
	
	[songQueue removeAllObjects];
	
	queueIndex = -1;
	
	FizyQueueChangedInfo *info = [[FizyQueueChangedInfo new] autorelease];
	
	info.songInfo = nil;
	info.reason = FZ_QUEUECHANGED_FOR_CLEAR;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerQueueChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:info forKey:@"info"]];
}

- (BOOL) loadQueue{
	NSMutableArray *arrJsonQueue = [[ProfileProvider sharedProfileProvider] queue];
	
	for (NSDictionary *dictSong in arrJsonQueue) {
		FizySongInfo *songInfo = [dictSong convertToType:[FizySongInfo class]];
		
		[songQueue addObject:songInfo];
	}
	
	queueIndex = -1;
	
	FizyQueueChangedInfo *info = [[FizyQueueChangedInfo new] autorelease];
	
	info.songInfo = nil;
	info.reason = FZ_QUEUECHANGED_FOR_ADD;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerQueueChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:info forKey:@"info"]];
	
	return [arrJsonQueue count] > 0;
}

- (void) saveQueue{
	if(isQueueSaved)
		return;
	
	NSMutableArray *arrJsonQueue = [[ProfileProvider sharedProfileProvider] queue];
	
	for (NSObject *obj in arrJsonQueue) {
		[obj release];
	}
	
	[arrJsonQueue removeAllObjects];
	
	for (FizySongInfo *song in songQueue) {		
		NSMutableDictionary *dictJson = [[NSMutableDictionary alloc] init];
		
		[dictJson setObject:song.ID forKey:@"ID"];
		[dictJson setObject:song.duration forKey:@"duration"];
		[dictJson setObject:song.provider forKey:@"provider"];
		[dictJson setObject:song.providerNumber forKey:@"providerNumber"];
		[dictJson setObject:song.source forKey:@"source"];
		[dictJson setObject:song.title forKey:@"title"];
		[dictJson setObject:song.artist forKey:@"artist"];
		[dictJson setObject:song.songname forKey:@"songname"];
		[dictJson setObject:song.type forKey:@"type"];
		[dictJson setObject:(song.requiresHTTPStreaming ? @"true":@"false") forKey:@"requiresHTTPStreaming"];
		[dictJson setObject:@"true" forKey:@"isDirty"];
		[dictJson setObject:(song.canPlay ? @"true":@"false") forKey:@"canPlay"];
		
		[arrJsonQueue addObject:dictJson];
		
	}
	
	[[ProfileProvider sharedProfileProvider] saveConfig];
	
	isQueueSaved = YES;
}


- (void) setShuffle:(BOOL)isOn {
	isShuffleOn = isOn;
	
    NSMutableDictionary * dict = [[ProfileProvider sharedProfileProvider] settings];
    
    if (isOn) {
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"shuffle"];
        
    } else  
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"shuffle"];
    
    
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerPlayModeChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:@"shuffle" forKey:@"mode"]];
	
}

- (BOOL) getShuffle {
	return isShuffleOn;
}

- (void) setRepeat:(BOOL)isOn{
	isRepeatOn = isOn;
    NSMutableDictionary * dict = [[ProfileProvider sharedProfileProvider] settings];
    
    if (isOn) {
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"repeat"];
        
    } else  
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"repeat"];
    
	
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerPlayModeChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:isOn ? @"repeat" : @"norepeat" forKey:@"mode"]];
}

- (BOOL) getRepeat{
	return isRepeatOn;
}

- (void) notifySongChange:(FizySongInfo *)song{
	[[NSNotificationCenter defaultCenter] postNotificationName:FZPlayerSongChangedNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:song forKey:@"song"]];
	
}

- (FZPlayerStatus) playerStatus{
	return [nowPlaying playerStatus];
}

- (void) showNowPlaying{
	[Utility performSelectorOnAppDelegate:@"showNowPlaying"];
}



@end
