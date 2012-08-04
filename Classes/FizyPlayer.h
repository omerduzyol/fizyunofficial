//
//  FizyPlayer.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/10/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NowPlayingViewController;
@class FizySongInfo;

typedef enum
{
	FZ_QUEUECHANGED_NA = 0,
	FZ_QUEUECHANGED_FOR_ADD,
	FZ_QUEUECHANGED_FOR_UPDATE,
	FZ_QUEUECHANGED_FOR_REORDER,
	FZ_QUEUECHANGED_FOR_REMOVE,
	FZ_QUEUECHANGED_FOR_CLEAR
} FZPlayerQueueChangedReason;

typedef enum
{
	FZ_PLAYERSTATUS_NA = 0,
	FZ_PLAYERSTATUS_STOPPED,
	FZ_PLAYERSTATUS_PLAYING,
	FZ_PLAYERSTATUS_PAUSED,
	FZ_PLAYERSTATUS_WAITING,
	FZ_PLAYERSTATUS_SEEKING
} FZPlayerStatus;

extern NSString * const FZPlayerQueueChangedNotification;
extern NSString * const FZPlayerPlayModeChangedNotification;
extern NSString * const FZPlayerSongChangedNotification;

@interface FizyPlayer : NSObject {
	NowPlayingViewController *nowPlaying;

	NSMutableArray *songQueue;
	NSInteger queueIndex;
	BOOL isJumping;
	BOOL isShuffleOn;
	BOOL isRepeatOn;
	BOOL isQueueSaved;
}

@property (nonatomic, retain) NowPlayingViewController *nowPlaying;
@property (nonatomic, retain) NSMutableArray *songQueue;
@property (assign, readonly) NSInteger queueIndex;
@property (nonatomic, assign) BOOL isJumping;

- (BOOL) checkSongQueued:(FizySongInfo *)song;
- (void) addSongQueue:(FizySongInfo *)newSong toBeginning:(BOOL)beginning;
- (void) moveSongFromIndex:(NSUInteger)fromIndex toIndexPath:(NSUInteger)toIndex;
- (BOOL) removeSongFromQueue:(NSUInteger)index;
- (BOOL) setQueueIndex:(FizySongInfo *)song;
- (BOOL) isQueuePlaying;
- (NSInteger) saveQueueAsPlaylist:(NSString *)playlistName;
- (void) clearQueue;
- (BOOL) loadQueue;
- (void) saveQueue;
- (void) setShuffle:(BOOL)isOn;
- (BOOL) getShuffle;
- (void) setRepeat:(BOOL)isOn;
- (BOOL) getRepeat;

- (FZPlayerStatus) playerStatus;

- (void) play;
- (void) togglePlay;
- (void) pause;
- (void) stop;
- (void) nextSong;
- (void) prevSong;

- (void) setCurrentSong:(FizySongInfo *)newSong;
- (FizySongInfo *) getCurrentSong;

- (FizySongInfo *) getPrevSong;
- (FizySongInfo *) getNextSong;

- (void) showNowPlaying;
- (BOOL) isBusy;

- (void) notifySongChange:(FizySongInfo *)song;

@end
