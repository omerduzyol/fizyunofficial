//
//  NowPlayingViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FizyPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@class MPMoviePlayerController;
@class FizyPlayer, FizySongInfo, AudioStreamer, AlbumArtResolver, WebRequestHelper;
@class SearchViewController;

@interface NowPlayingViewController : UIViewController {
	NSTimer *durationTimer;
	
	WebRequestHelper *albumArtDownloader;
	AlbumArtResolver *artResolver;
	
	FizyPlayer *fizyPlayer;
	FizySongInfo *currentSong;
	
	UIBarButtonItem *showQueue;
	UIBarButtonItem *showPlaying;
	

	MPMoviePlayerController *player;
	AudioStreamer *streamer;
	
	BOOL queueOpen;
	BOOL isSeeking;
	BOOL isHTTPStreaming;
	BOOL isQueuedSong;
	BOOL isVideoPlaying;
	BOOL isPlaying;
	BOOL isBusy;
}

@property (nonatomic, retain) MPMoviePlayerController *player;

@property (nonatomic, retain) IBOutlet UISlider *durationSlider;
@property (nonatomic, retain) IBOutlet UILabel *lblCurrentTime;
@property (nonatomic, retain) IBOutlet UILabel *lblMaxTime;
@property (nonatomic, retain) IBOutlet UILabel *lblSeekingTime;
@property (nonatomic, retain) IBOutlet UILabel *lblSongTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblSongIndex;
@property (nonatomic, retain) IBOutlet UIView *viewAlbumArt;
@property (nonatomic, retain) IBOutlet UIImageView *imgAlbumArt;
@property (nonatomic, retain) IBOutlet UIImageView *imgProvider;
@property (nonatomic, retain) IBOutlet UIView *viewVideo;
@property (nonatomic, retain) IBOutlet UIButton *btnAddToPlaylist;
@property (nonatomic, retain) IBOutlet UIButton *btnPrevSong;
@property (nonatomic, retain) IBOutlet UIButton *btnNextSong;
@property (nonatomic, retain) IBOutlet UIButton *btnPlay;
@property (nonatomic, retain) IBOutlet UIButton *btnPause;
@property (nonatomic, retain) IBOutlet UIButton *btnShare;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *mediaLoading;
@property (nonatomic, retain) IBOutlet SearchViewController *searchView;
@property (nonatomic, retain) IBOutlet UITabBarItem *queueTabItem;
@property (nonatomic, retain) IBOutlet UIView *topView;
@property (nonatomic, retain) IBOutlet UIView *queueView;
@property (nonatomic, retain) IBOutlet UIView *halfView;

@property (assign) BOOL isSeeking;
@property (assign) BOOL isHTTPStreaming;
@property (assign) BOOL isQueuedSong;
@property (assign) BOOL isVideoPlaying;
@property (assign) BOOL isPlaying;
@property (assign) BOOL isBusy;

#pragma mark -
#pragma mark Event Handlers

- (IBAction) btnPrevSong_touchUp:(id)sender;
- (IBAction) btnNextSong_touchUp:(id)sender;
- (IBAction) btnPlay_touchUp:(id)sender;
- (IBAction) btnPause_touchUp:(id)sender;
- (IBAction) btnAddToPlaylist_touchUp:(id)sender;
- (IBAction) btnShare_touchUp:(id)sender;
- (IBAction) playerBeginSeek:(UISlider*)sender;
- (IBAction) playerBeingSeek:(UISlider*)sender;
- (IBAction) playerEndSeek:(UISlider*)sender;
- (IBAction) toggleQueueView: (id) sender;

#pragma mark -
#pragma mark Methods

- (void) play;
- (void) togglePlay;
- (void) pause;
- (void) stop;
- (void) nextSong;
- (void) prevSong;

- (void) updatePlayerButtons;
- (void) determinePrevSong;
- (void) determineNextSong;
- (void) showHideQueueView:(BOOL)hide animated:(BOOL)isAnimated;
- (FZPlayerStatus) playerStatus;

- (void) albumArtResolver_Resolved:(NSString *)albumArtURL;
- (void) albumArtResolver_Error:(NSString *)message;
- (void) albumArtDownloader_Downloaded:(WebRequestHelper *)req withResponse:(NSData *)response;
- (void) albumArtDownloader_Error:(WebRequestHelper*)req withMessage:(NSString *)message;

- (void) internalSetupPlayer:(NSURL*)songURL;
- (void) setCurrentSong:(FizySongInfo *)newSong;
- (FizySongInfo *) getCurrentSong;

- (void) registerPlayerNotifications;
- (void) unregisterPlayerNotifications;

- (void) destroyStreamer;
- (void) destroyPlayer;

- (void) resetSeekbar;
- (double) getPlaybackTime;
- (void) observeDurationTimer;
- (void) invalidateDurationTimer;
- (void) updateQueueBadge;

@end
