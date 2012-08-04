    //
//  NowPlayingViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "NowPlayingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SearchViewController.h"
#import "URLParser.h"
#import "Fizy.h"
#import "MobileVideoProvider.h"
#import "AudioStreamer.h"
#import "WebRequestHelper.h"
#import "SHK.h"

@implementation NowPlayingViewController

@synthesize durationSlider, lblCurrentTime, lblMaxTime, lblSeekingTime, lblSongTitle, lblSongIndex, viewAlbumArt, imgAlbumArt, imgProvider, viewVideo, btnAddToPlaylist, btnPrevSong, btnNextSong, btnPlay, btnPause, btnShare;
@synthesize player, mediaLoading, searchView, queueTabItem, topView, queueView, halfView;
@synthesize isSeeking, isHTTPStreaming, isQueuedSong, isVideoPlaying, isPlaying, isBusy;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	showQueue = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-top-queue.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleQueueView:)];
	showPlaying = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleQueueView:)];
	
	//self.navigationItem.rightBarButtonItem = showQueue;
	
	// Setup custom slider images
    UIImage *minImage = [UIImage imageNamed:@"slider-progress.png"];
    UIImage *maxImage = [UIImage imageNamed:@"slider-bg.png"];

	[durationSlider setThumbImage:[UIImage imageNamed:@"slider-thumb.png"] forState:UIControlStateNormal];
	[durationSlider setThumbImage:[UIImage imageNamed:@"slider-thumb-highlight.png"] forState:UIControlStateHighlighted];
	[durationSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
	[durationSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
	
	fizyPlayer = [Fizy sharedFizy].player;
	fizyPlayer.nowPlaying = self;
	
	// register fizy player notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fizyPlayerQueueChanged:) 
												 name:FZPlayerQueueChangedNotification 
											   object:fizyPlayer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fizyPlayerSongChanged:) 
												 name:FZPlayerSongChangedNotification 
											   object:fizyPlayer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fizyPlayerPlayModeChanged:) 
												 name:FZPlayerPlayModeChangedNotification 
											   object:fizyPlayer];
	
	
	
	[Fizy sharedFizy].getSongCallbackContext = self;
	[Fizy sharedFizy].getSongCallback = @selector(getSongCallback:);
	
	artResolver = [[AlbumArtResolver alloc] init];
	artResolver.callbackContext = self;
	artResolver.resolveCallbackHandler = @selector(albumArtResolver_Resolved:);
	artResolver.errorCallbackHandler = @selector(albumArtResolver_Error:);
	
	albumArtDownloader = [[WebRequestHelper alloc] init];
	albumArtDownloader.callbackContext = self;
	albumArtDownloader.responseCallbackHandler = @selector(albumArtDownloader_Downloaded:withResponse:);
	albumArtDownloader.errorCallbackHandler = @selector(albumArtDownloader_Error:withMessage:);
		
	isQueuedSong = NO;
	
	self.player = nil;
	
	NSLog(@"Setting up audio session");
	// setting up audio session
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
	NSError *setCategoryError = nil;
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
	if (setCategoryError) { 
		/* handle the error condition */ 
		NSLog(@"AVAudio: %@", [setCategoryError description]);
	}
	
	NSError *activationError = nil;
	[audioSession setActive:YES error:&activationError];
	if (activationError) { /* handle the error condition */ 
		NSLog(@"AVAudio: %@", [activationError description]);
	}
	
	//[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	if (currentSong == nil) {
		lblSongTitle.text = @"no song selected";
		durationSlider.userInteractionEnabled = NO;
		durationSlider.value = 0.0;
	}

	if (currentSong!=nil && player.playbackState == MPMoviePlaybackStatePlaying && isVideoPlaying) {
		//viewVideo.hidden = NO;
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	if (currentSong!=nil && player.playbackState == MPMoviePlaybackStatePlaying && 
		isVideoPlaying && [[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue]) {
		
		[self pause];
		
		[Utility alertMessage:@"Background video is not supported" message:@"You cannot listen media at background when video playback is enabled. If you want to use background play, you should disable video playback at settings tab."];
		//NSLog(@"Player: You cannot listen media at background when video playback is enabled.");
	}

}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	
	if (queueOpen) {
		[self showHideQueueView:YES animated:NO];
	}
	
	if (currentSong!=nil && player.playbackState == MPMoviePlaybackStatePlaying && isVideoPlaying) {
		//viewVideo.hidden = YES;
		
	}
	
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
*/

- (void) getSongCallback:(FizySongInfo *)songInfo{
	//NSIndexPath *indexPath = [searchView.dataTable indexPathForSelectedRow];
	
	//[searchView updateSongInfo:songInfo forIndexPath:indexPath];
	
	[songInfo initSong];
	
	[self setCurrentSong:songInfo];
}
				 
- (IBAction) toggleQueueView:(id) sender{
	if (queueOpen){
		/*
		// start the animated transition
		[UIView beginAnimations:@"toggleQueueView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:halfView cache:YES];
		
		queueView.hidden = YES;
		topView.hidden = NO;
		
		// commit the transition animation
		[UIView commitAnimations];
		
		queueOpen = NO;
		
		[self.navigationItem setRightBarButtonItem:showQueue animated:YES];
		self.navigationItem.title = @"Now Playing";*/
		[self showHideQueueView:YES animated:YES];
	} else {
		/*
		// start the animated transition
		[UIView beginAnimations:@"toggleQueueView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:halfView cache:YES];
		
		queueView.hidden = NO;
		topView.hidden = YES;
		
		// commit the transition animation
		[UIView commitAnimations];
		
		queueOpen = YES;
		
		[self.navigationItem setRightBarButtonItem:showPlaying animated:YES];
		self.navigationItem.title = @"Queue";*/
		[self showHideQueueView:NO animated:YES];
	}
}

- (void)showHideQueueView:(BOOL)hide animated:(BOOL)isAnimated{
	if (hide){
		if (isAnimated) {
			// start the animated transition
			[UIView beginAnimations:@"toggleQueueView" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.6];
			[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:halfView cache:YES];
		}
		
		queueView.hidden = YES;
		topView.hidden = NO;
		
		if (isAnimated) {
			// commit the transition animation
			[UIView commitAnimations];			
		}
		
		queueOpen = NO;
		
		[self.navigationItem setRightBarButtonItem:showQueue animated:isAnimated];
		self.navigationItem.title = @"Now Playing";
	} else {
		if (isAnimated) {
			// start the animated transition
			[UIView beginAnimations:@"toggleQueueView" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.6];
			[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:halfView cache:YES];
		}		
		
		queueView.hidden = NO;
		topView.hidden = YES;
		
		if (isAnimated) {
			// commit the transition animation
			[UIView commitAnimations];
		}
		
		queueOpen = YES;
		
		[self.navigationItem setRightBarButtonItem:showPlaying animated:isAnimated];
		self.navigationItem.title = @"Queue";
	}
}

#pragma mark -
#pragma mark Seekbar and Duration Events

- (void) resetSeekbar {
	durationSlider.userInteractionEnabled = NO;
	durationSlider.value = 0;
}

- (double) getPlaybackTime{
	double playbackTime = 0;

	if (isHTTPStreaming) {
		if (streamer.bitRate != 0.0)
		{
			double progress = streamer.progress;
			double duration = streamer.duration;
			
			if (duration > 0)
			{
				playbackTime = 100 * progress / duration;
				//durationSlider.userInteractionEnabled = YES;
			} else {
				playbackTime = 0;
			}

		}
	} else {
		
		if (self.player.duration <= 0) {
			playbackTime = 0;
		} else {
			playbackTime = self.player.currentPlaybackTime;
		}

	}
	
	return playbackTime;
}

- (void) updatePlayerDuration:(NSTimer*)timer {	
	double playbackTime = [self getPlaybackTime];
	
	if (!isSeeking) 
		durationSlider.value = playbackTime;

	NSInteger minutes = floor(playbackTime / 60);
	NSInteger seconds = round(playbackTime - minutes * 60);
	
	if (minutes<0)
		minutes = 0;
	
	if (seconds<0)
		seconds = 0;
	
	lblCurrentTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
	
	if (isPlaying && !mediaLoading.hidden) {
		mediaLoading.hidden = YES;
	}
}

- (void) playerBeginSeek:(UISlider*)sender {
	isSeeking = YES;
	NSLog(@"begin %f", sender.value);
	
	lblSeekingTime.text = lblCurrentTime.text;
	
	// start the animated transition
	[UIView beginAnimations:@"toggleQueueView" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.4];
	//[UIView setAnimationTransition: UIViewAnimationTransition forView:halfView cache:YES];
	
	lblSeekingTime.alpha = 1;
	lblSongIndex.alpha = 0;
	
	// commit the transition animation
	[UIView commitAnimations];
}

- (void) playerBeingSeek:(UISlider*)sender {
	if (!isSeeking)
		return;
	
	double playbackTime = 0;
	
	//NSLog(@"seeking %f", sender.value);
	
	if (isHTTPStreaming) {
		playbackTime = (sender.value / 100.0) * streamer.duration;
	} else {
		playbackTime = sender.value;
	}
	
	NSInteger minutes = floor(playbackTime / 60);
	NSInteger seconds = round(playbackTime - minutes * 60);
	
	if (minutes<0)
		minutes = 0;
	
	if (seconds<0)
		seconds = 0;
	
	lblSeekingTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
	
}

- (void) playerEndSeek:(UISlider*)sender {
	NSLog(@"end %f", sender.value);
	
//	lblSeekingTime.hidden = YES;
//	lblSongIndex.hidden = NO;
	
	// start the animated transition
	[UIView beginAnimations:@"toggleQueueView" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.6];
	//[UIView setAnimationTransition: UIViewAnimationTransition forView:halfView cache:YES];
	
	lblSeekingTime.alpha = 0;
	lblSongIndex.alpha = 1;
	
	// commit the transition animation
	[UIView commitAnimations];
	
	self.mediaLoading.hidden = NO;

	if (isHTTPStreaming) {
		double newSeekTime = (sender.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	} else {
		self.player.currentPlaybackTime = sender.value;		
		/*
		if (self.player.playbackState != MPMoviePlaybackStatePlaying)
			[self play];*/
	}

	isSeeking = NO;
}

- (void) observeDurationTimer{
	[self invalidateDurationTimer];
	
	durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePlayerDuration:) userInfo:nil repeats:YES];
}

- (void) invalidateDurationTimer{
	if (durationTimer!= nil) {
		[durationTimer invalidate];	
		durationTimer = nil;
	}
}

#pragma mark -
#pragma mark Player Methods

- (void) play
{	
	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && isVideoPlaying)
			return;
	}
	
	if (isHTTPStreaming) {
		if (currentSong.isDirty && [self playerStatus] == FZ_PLAYERSTATUS_STOPPED) {
			NSLog(@"Selected song was dirty, app needs refresh url...");
			
			NSString *songID = currentSong.ID;
			
			[[Utility sharedHUD] show:YES];	
			[[Fizy sharedFizy] getSong:songID];
			
			[currentSong release];
			currentSong = nil;
			
			return;
		}
		
		currentSong.isDirty = YES;

		[streamer start];
	} else {
		[self.player play];	
	}
}

- (void) togglePlay
{
	
	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && isVideoPlaying)
			return;
	}
	
	if (isHTTPStreaming) {
		[streamer pause];
	} else {
		if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
			[self.player pause];
		} else {
			[self.player play];
			
			[self observeDurationTimer];
		}
	}
	
}

- (void) pause
{

	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && isVideoPlaying)
			return;
	}
	
	if (isHTTPStreaming) {
		[streamer pause];
	} else {
		[self.player pause];
	}
}

- (void) stop
{
	
	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && isVideoPlaying)
			return;
	}
	
	if (isHTTPStreaming) {
		[streamer stop];
	} else {
		[self.player stop];	
	}
}

- (void) nextSong
{
	
	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"]  boolValue] && isVideoPlaying)
			return;
	}
	
	[self determineNextSong];
}

- (void) prevSong
{
	
	// if app was switched to background and user tried to change playstate?
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
	{
		if (![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue])
			return;
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && isVideoPlaying)
			return;
	}
	
	[self determinePrevSong];
}

- (void) updatePlayerButtons{
	if (fizyPlayer.queueIndex < 0 || (currentSong != nil && ![fizyPlayer checkSongQueued:currentSong])) {
		btnNextSong.enabled = NO;
		btnPrevSong.enabled = NO;
		
		return;
	}
	
	if ([fizyPlayer getRepeat]) {
		btnNextSong.enabled = YES;	
		
		btnPrevSong.enabled = YES;
		
		return;
	} else {
		if ([fizyPlayer.songQueue count]-1 == fizyPlayer.queueIndex) {
			btnNextSong.enabled = NO;	
		} else {
			btnNextSong.enabled = YES;
		}		
		
		
	}	
	
	if (fizyPlayer.queueIndex == 0) {
		btnPrevSong.enabled = NO;
	} else if ([fizyPlayer.songQueue count] == 0) {
		btnPrevSong.enabled = NO;
	} else {
		btnPrevSong.enabled = YES;
	}
	
}

- (void) determineNextSong{
	if (fizyPlayer.isJumping) {
		return;
	}
	
	NSLog(@"Player: Determining next song...");
	
	FizySongInfo *nextSong = [fizyPlayer getNextSong]; 
	if (nextSong != nil) {
		fizyPlayer.isJumping = YES;
		
		[self setCurrentSong:nextSong];
	} /*else if ([fizyPlayer getRepeat] && [fizyPlayer.songQueue count] > 0) {
		NSLog(@"Player: Repeat enabled, finding first song...");
		
		nextSong = [fizyPlayer.songQueue objectAtIndex:0];
		
		fizyPlayer.isJumping = YES;
		
		[self setCurrentSong:nextSong];
		
	}*/
	
	[self updatePlayerButtons];
	[self updateQueueBadge];
	
}

- (void) determinePrevSong {
	if (fizyPlayer.isJumping) {
		return;
	}
	
	FizySongInfo *prevSong = [fizyPlayer getPrevSong]; 
	if (prevSong != nil) {
		fizyPlayer.isJumping = YES;
		
		[self setCurrentSong:prevSong];		
	}
	
	[self updatePlayerButtons];
	[self updateQueueBadge];
}

- (FizySongInfo *) getCurrentSong
{
	return currentSong;
}

- (void) setCurrentSong:(FizySongInfo *)newSong {
	
	if ((newSong == nil || [newSong.ID isEqualToString:currentSong.ID]) && isPlaying) 
		return;
	else if ([newSong.ID isEqualToString:currentSong.ID] && isPlaying)  {
		[self play];
	}
	
	imgAlbumArt.contentMode = UIViewContentModeCenter;
	imgAlbumArt.image = [UIImage imageNamed:@"default-albumart.png"];
	
	NSInteger videoProvider = 0;

	// destroy and clean old player and streamer interfaces
	[self destroyPlayer];
	[self destroyStreamer];
	
	// release the old song info
	if (currentSong != nil) {
		[currentSong release];
		currentSong = nil;
	}
	
	if(newSong.isDirty){
		NSLog(@"Selected song was dirty, app needs refresh url...");
		
		[[Utility sharedHUD] show:YES];	
		[[Fizy sharedFizy] getSong:newSong.ID];
		
		return;
	}	
	
	// check provider and media content types
	NSURL *songURL = nil;
	if ([newSong.provider isEqualToString:@"soundcloud"]) {			// provider number 8
		songURL = [NSURL URLWithString:newSong.source];
		self.viewVideo.hidden = YES;
		self.viewAlbumArt.hidden = NO;
		
	} else if ([newSong.provider isEqualToString:@"grooveshark"]) {	// provider number 10
		// check if link is expired?
		NSTimeInterval expiration = [[NSDate date] timeIntervalSinceDate:newSong.timestamp];
		 
		// check link was generated within 5 minutes
		if (expiration >= (5 * 60)) {
			[[Utility sharedHUD] show:YES];	
			[[Fizy sharedFizy] getSong:newSong.ID];
			
			return;
		}
		
		songURL = [NSURL URLWithString:newSong.source];
		self.viewVideo.hidden = YES;
		self.viewAlbumArt.hidden = NO;
		
	} else if ([newSong.provider isEqualToString:@"dailymotion"]) {	// provider number 2
		self.viewVideo.hidden = NO;
		self.viewAlbumArt.hidden = YES;
		videoProvider = 2;
		
	} else if ([newSong.provider isEqualToString:@"youtube"]) {		// provider number 1
		self.viewVideo.hidden = NO;
		self.viewAlbumArt.hidden = YES;
		
		videoProvider = 1;
	} else if ([newSong.provider isEqualToString:@"wrzuta"]) {		// provider number 3
		songURL = [NSURL URLWithString:newSong.source];
		self.viewVideo.hidden = YES;
		self.viewAlbumArt.hidden = NO;
		
		[[Utility sharedHUD] hide:YES];	
	} else if ([newSong.provider isEqualToString:@"sony"]) {		// provider number 6
		// TODO: iOS doesn't support this type of content yet.
		
		self.viewVideo.hidden = YES;
		self.viewAlbumArt.hidden = NO;
		
		[[Utility sharedHUD] hide:YES];	

	} else if ([newSong.provider isEqualToString:@"muyap"]) {		// provider number -1
		// TODO: iOS doesn't support this type of content yet.
		
		self.viewVideo.hidden = YES;
		self.viewAlbumArt.hidden = NO;

		[[Utility sharedHUD] hide:YES];	

	}	
	
	isHTTPStreaming = newSong.requiresHTTPStreaming;
	
	if (songURL == nil && videoProvider == 0) {
		// TODO: give alert 
		return;
	}
	
	// save queue just in case...
	[[Fizy sharedFizy].player saveQueue];
	
	currentSong = [newSong retain];
	
	fizyPlayer.isJumping = NO;
	
	isQueuedSong = [fizyPlayer setQueueIndex:currentSong];
	
	if (!isQueuedSong) {
		lblSongIndex.text = @"1 of 1";
	} else {
		lblSongIndex.text = [NSString stringWithFormat:@"%d of %d", fizyPlayer.queueIndex+1, [fizyPlayer.songQueue count]];
	}
	
	lblSongTitle.text = newSong.title;
	imgProvider.image = [UIImage imageNamed:[NSString stringWithFormat:@"logo-provider-%@.png",newSong.provider]];

	self.mediaLoading.hidden = NO;

	if (videoProvider == 0) {
		[[Utility sharedHUD] hide:YES];	
		[self internalSetupPlayer:songURL];
		isVideoPlaying = NO;
	} else {
		isVideoPlaying = YES;
		
		switch (videoProvider) {
				// youtube
			case 1:
				
				[[MobileVideoProvider sharedMobileVideoProvider] search:[NSString stringWithFormat:@"video:%@",newSong.source]
															forProvider:videoProvider
														   withCallback:@selector(youtubeMobileCallback:) 
															  ofContext:self];				
				break;
				
				// dailymotion
			case 2:
			{
				URLParser *parser = [[[URLParser alloc] initWithURLString:newSong.source] autorelease];
				NSString *decodedUri = [parser valueForParameter:@"u"];
				
				NSArray *uriParts = [[decodedUri stringByReplacingOccurrencesOfString:@"http://www.dailymotion.com/video/"
																		   withString:@""] componentsSeparatedByString:@"_"];
				
				if (uriParts == nil || [uriParts count] <= 1) {
					//TODO:error message
					return;
				}
				
				[[MobileVideoProvider sharedMobileVideoProvider] search:[uriParts objectAtIndex:0]
															forProvider:videoProvider
														   withCallback:@selector(dailymotionMobileCallback:) 
															  ofContext:self];		
			}
				break;
			default:
				break;
		}
		
		
	}
	
	
	if ((!isVideoPlaying || (isVideoPlaying && ![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue])) && 
		[[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"downloadAlbumArts"] boolValue]) {
		[artResolver resolveAlbumArt:newSong.title];	
	}

	//FZPlayerSongChangedNotification
	
	[self updatePlayerButtons];
	
	[[Fizy sharedFizy].player notifySongChange:newSong];
}

- (void)internalSetupPlayer:(NSURL*)songURL
{
	[self resetSeekbar];
	
	lblCurrentTime.text = @"0:00";
	lblMaxTime.text = @"0:00";
	
	NSLog(@"Player: Current URL is %@", [songURL absoluteString]);
	
	if (isHTTPStreaming) {
		durationSlider.maximumValue = 100.0;
		
		NSLog(@"Player: AudioStreamer");
		
		isBusy = YES;
		
		streamer = [[AudioStreamer alloc] initWithURL:songURL];
		
		[self observeDurationTimer];
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(streamerPlaybackStateChanged:)
		 name:ASStatusChangedNotification
		 object:streamer];
		
	} else {
		
		NSLog(@"Player: MPMoviePlayer");
		
		isBusy = NO;
		
		self.player = [[MPMoviePlayerController alloc] initWithContentURL:songURL];
		self.player.shouldAutoplay = NO;

		[[self.player view] setFrame: CGRectMake(0, 0, 320, 240)];
		
		if ([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue]) {
			[viewVideo addSubview:[self.player view]];	
		}
		
		self.player.controlStyle = MPMovieControlStyleNone;
		
		self.player.useApplicationAudioSession = NO;
		
		[self registerPlayerNotifications];
		
		[player prepareToPlay];
		
	}
	
	[self play];
	
	self.btnPlay.hidden = YES;
	self.btnPause.hidden = NO;
	
	self.btnPlay.enabled = YES;
	self.btnPause.enabled = YES;
	self.btnAddToPlaylist.enabled = YES;
	self.btnShare.enabled = YES;
}

- (FZPlayerStatus) playerStatus {
	FZPlayerStatus status = FZ_PLAYERSTATUS_NA;

	if (isHTTPStreaming) {
		if (streamer == nil)
			status = FZ_PLAYERSTATUS_STOPPED;
		else if ([streamer isWaiting])
			status = FZ_PLAYERSTATUS_WAITING;
		else if ([streamer isPlaying])
			status = FZ_PLAYERSTATUS_PLAYING;
		else if ([streamer isPaused])
			status = FZ_PLAYERSTATUS_PAUSED;
		else if ([streamer isIdle])
			status = FZ_PLAYERSTATUS_STOPPED;
		else {
			if (isSeeking) {
				status = FZ_PLAYERSTATUS_SEEKING;
			}
		}

	} else {
		if (self.player == nil) {
			status = FZ_PLAYERSTATUS_STOPPED;
		}
		else if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
			status = FZ_PLAYERSTATUS_PLAYING;
		} else if (self.player.playbackState == MPMoviePlaybackStatePaused) {
			status = FZ_PLAYERSTATUS_PAUSED;
			
		} else if (self.player.playbackState == MPMoviePlaybackStateInterrupted) {
			
		} else if (self.player.playbackState == MPMoviePlaybackStateStopped) {
			status = FZ_PLAYERSTATUS_STOPPED;
		} else if (self.player.playbackState == MPMoviePlaybackStateSeekingForward) {
			status = FZ_PLAYERSTATUS_SEEKING;
		} else if (self.player.playbackState == MPMoviePlaybackStateSeekingBackward) {
			status = FZ_PLAYERSTATUS_SEEKING;
		}
	}

	return status;
}

#pragma mark -
#pragma mark AlbumArtResolver, albumArtDownloader

-(void) albumArtResolver_Resolved:(NSString *)albumArtURL{	
	if (albumArtURL) {
		NSLog(@"Player: Downloading albumart image...");
		[albumArtDownloader request:[NSURL URLWithString:albumArtURL] method:@"GET" bodyData:nil withCachePolicy:NSURLRequestReturnCacheDataElseLoad];
	} 
}

-(void) albumArtResolver_Error:(NSString *)message{
	
}

- (void) albumArtDownloader_Downloaded:(WebRequestHelper *)req withResponse:(NSData *)response {
	NSLog(@"Player: Albumart downloaded");

	imgAlbumArt.image = nil;
	UIImage *albumArtImage = [UIImage imageWithData:response];

	if(albumArtImage.size.height <= 240){
		imgAlbumArt.contentMode = UIViewContentModeCenter;
	} else {
		imgAlbumArt.contentMode = UIViewContentModeScaleAspectFill | UIViewContentModeBottom;
	}
	imgAlbumArt.image = albumArtImage;

}

- (void) albumArtDownloader_Error:(WebRequestHelper*)req withMessage:(NSString *)message {
	
}

#pragma mark -
#pragma mark AudioStreamer functions

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void) destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		
		[self invalidateDurationTimer];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
		
		isBusy = NO;
		
		NSLog(@"Streamer: Destroyed");
	}
}

//
// streamerPlaybackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)streamerPlaybackStateChanged:(NSNotification *)aNotification
{
	
	if ([streamer isWaiting])
	{
		NSLog(@"Streamer: Waiting");
		
		self.mediaLoading.hidden = NO;

		isPlaying = NO;
		isBusy = YES;
	}
	else if ([streamer isPlaying])
	{
		NSLog(@"Streamer: Playing");
		
		isPlaying = YES;
		isBusy = NO;
		
		self.btnPlay.hidden = YES;
		self.btnPause.hidden = NO;
		self.mediaLoading.hidden = YES;
		
		NSInteger minutes = floor(streamer.duration /60);
		NSInteger seconds = round(streamer.duration - minutes * 60);
		
		lblMaxTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];

		durationSlider.value = 0.0;
		durationSlider.userInteractionEnabled = YES;
		
	}
	else if ([streamer isPaused]) {
		NSLog(@"Streamer: Paused");
		
		isPlaying = NO;
		isBusy = NO;
		
		self.mediaLoading.hidden = YES;
		self.btnPlay.hidden = NO;
		self.btnPause.hidden = YES;

	}
	else if ([streamer isIdle])
	{
		NSLog(@"Streamer: Idle");
		
		isPlaying = NO;
		isBusy = NO;
		
		self.mediaLoading.hidden = YES;
		self.btnPlay.hidden = NO;
		self.btnPause.hidden = YES;
		
		[self resetSeekbar];
		[self destroyStreamer];
		[self invalidateDurationTimer];

		[self determineNextSong];
	}
}


#pragma mark -
#pragma mark MPMoviePlayer functions

- (void) destroyPlayer {
	if (self.player != nil) {
		[self.player stop];
		
		[self unregisterPlayerNotifications];
		
		[self.player release];
		
		self.player = nil;
		
		[self invalidateDurationTimer];
		
		NSLog(@"MPMoviePlayer: Destroyed");
	}
}

- (void) registerPlayerNotifications{
	// registering movie player notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerDurationAvailable:) 
												 name:MPMovieDurationAvailableNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerPlaybackStateDidChange:) 
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerDidEnterFullscreen:) 
												 name:MPMoviePlayerDidEnterFullscreenNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerDidExitFullscreen:) 
												 name:MPMoviePlayerDidExitFullscreenNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerLoadStateDidChange:) 
												 name:MPMoviePlayerLoadStateDidChangeNotification
											   object:self.player];
	
    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerPlayBackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:self.player];
	
    // Register to receive a notification when the movie scaling mode has changed. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(playerScalingModeDidChange:) 
												 name:MPMoviePlayerScalingModeDidChangeNotification 
											   object:self.player];
	
}

- (void) unregisterPlayerNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMovieDurationAvailableNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMoviePlayerDidEnterFullscreenNotification
											   object:self.player];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:MPMoviePlayerDidExitFullscreenNotification
												  object:self.player];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMoviePlayerLoadStateDidChangeNotification
											   object:self.player];
	
    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:self.player];
	
    // Register to receive a notification when the movie scaling mode has changed. 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
												 name:MPMoviePlayerScalingModeDidChangeNotification 
											   object:self.player];
	
}

#pragma mark -
#pragma mark Movie Player Notifications

// MPMovieDurationAvailableNotification
- (void) playerDurationAvailable:(NSNotification*)notification
{
	MPMoviePlayerController* notified =[notification object];

	
	durationSlider.enabled = YES;
	durationSlider.maximumValue = notified.duration;
	durationSlider.value = 0.0;
	durationSlider.userInteractionEnabled = YES;
	
	NSInteger minutes = floor(notified.duration /60);
	NSInteger seconds = round(notified.duration - minutes * 60);
	
	lblMaxTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
	
	self.mediaLoading.hidden = YES;

	[self observeDurationTimer];
}


// MPMoviePlayerPlaybackStateDidChangeNotification
- (void) playerPlaybackStateDidChange:(NSNotification*)notification
{
	if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
		NSLog(@"MPMoviePlayer: Playing");
		self.mediaLoading.hidden = YES;
		[self updateQueueBadge];
		isPlaying = YES;

	} else if (self.player.playbackState == MPMoviePlaybackStatePaused) {
		NSLog(@"MPMoviePlayer: Paused");
		isPlaying = NO;

	} else if (self.player.playbackState == MPMoviePlaybackStateInterrupted) {
		NSLog(@"MPMoviePlayer: Interrupted");
		isPlaying = NO;
	} else if (self.player.playbackState == MPMoviePlaybackStateStopped) {
		NSLog(@"MPMoviePlayer: Stopped");
		[self resetSeekbar];
		self.mediaLoading.hidden = YES;
		isPlaying = NO;
	} else if (self.player.playbackState == MPMoviePlaybackStateSeekingForward) {
		self.mediaLoading.hidden = NO;
		isBusy = YES;

		NSLog(@"MPMoviePlayer: Seeking Forward");
	} else if (self.player.playbackState == MPMoviePlaybackStateSeekingBackward) {
		self.mediaLoading.hidden = NO;

		NSLog(@"MPMoviePlayer: Seeking Backward");
	}
	
	MPMusicPlaybackState playbackState = self.player.playbackState;
    if (playbackState == MPMusicPlaybackStatePaused || playbackState == MPMusicPlaybackStateStopped) {
		self.btnPlay.hidden = NO;
		self.btnPause.hidden = YES;

		[self invalidateDurationTimer];
    } else if (playbackState == MPMusicPlaybackStatePlaying) {		
		self.btnPlay.hidden = YES;
		self.btnPause.hidden = NO;
		
		[self observeDurationTimer];
    }
	
}

//MPMoviePlayerDidEnterFullscreenNotification
- (void) playerDidEnterFullscreen:(NSNotification*)notification
{
	
}

//MPMoviePlayerDidExitFullscreenNotification
- (void) playerDidExitFullscreen:(NSNotification*)notification
{
	
}

// MPMoviePlayerLoadStateDidChangeNotification
- (void) playerLoadStateDidChange:(NSNotification*)notification
{
	NSLog(@"MPMoviePlayer: Load state changed");	
}

//  Notification called when the movie finished playing.
- (void) playerPlayBackDidFinish:(NSNotification*)notification
{

	NSLog(@"MPMoviePlayer: Playback finished");
	
	[self invalidateDurationTimer];	
	[self determineNextSong];
	
}

//  Notification called when the movie scaling mode has changed.
- (void) playerScalingModeDidChange:(NSNotification*)notification
{
    /* 
	 < add your code here >
	 
	 For example:
	 MPMoviePlayerController* theMovie=[aNotification object];
	 etc.
	 */
}


#pragma mark -
#pragma mark Fizy Player Notifications
- (void) fizyPlayerQueueChanged:(NSNotification*)notification{
	if (![fizyPlayer checkSongQueued:currentSong]) {
		lblSongIndex.text = @"1 of 1";
	} else {
		lblSongIndex.text = [NSString stringWithFormat:@"%d of %d", fizyPlayer.queueIndex+1, [fizyPlayer.songQueue count]];
	}
	
	if ([[fizyPlayer songQueue] count] > 0) {
		[self.navigationItem setRightBarButtonItem:showQueue animated:YES];
	} else {
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
	}
	
	[self updatePlayerButtons];
	[self updateQueueBadge];
	
}

- (void) fizyPlayerSongChanged:(NSNotification*)notification{
	[searchView updateOnscreenSongCells];
}

- (void) fizyPlayerPlayModeChanged:(NSNotification*)notification{
	//NSString *mode = [[notification userInfo] objectForKey:@"mode"];
	
	[self updatePlayerButtons];
}

- (void) updateQueueBadge {
	[searchView updateOnscreenSongCells];
	
	NSInteger leftItems = ([fizyPlayer.songQueue count] - (fizyPlayer.queueIndex+1));

	if(leftItems<1){
		if ([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"showQueueBadge"] boolValue]){
			[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
		}
		
		queueTabItem.badgeValue = nil;
	} else {
		
		if ([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"showQueueBadge"] boolValue]){
			[UIApplication sharedApplication].applicationIconBadgeNumber = leftItems;
		}
		
		queueTabItem.badgeValue = [NSString	stringWithFormat:@"%d", leftItems];
	}
}

#pragma mark -
#pragma mark Video Providers Callbacks

- (void) youtubeMobileCallback:(NSDictionary *)response{
	[[Utility sharedHUD] hide:YES];	
	
	if ([[response objectForKey:@"result"] isEqualToString:@"ok"]) {
		NSDictionary *movie = [[[response objectForKey:@"content"] objectForKey:@"videos"] objectAtIndex:0];
		
		NSURL *streamURL = [NSURL URLWithString:[movie objectForKey:@"stream_url"]];
		[self internalSetupPlayer:streamURL];
		
	} else {
		//TODO: alert no video found and back.
		
	}	
}

- (void) dailymotionMobileCallback:(NSDictionary *)response{
	[[Utility sharedHUD] hide:YES];	
	
	NSURL *streamURL = [NSURL URLWithString:[response objectForKey:@"stream_url"]];
	[self internalSetupPlayer:streamURL];
}

#pragma mark -
#pragma mark Control Events
-(IBAction) btnPrevSong_touchUp:(id)sender{
	[self prevSong];
}

-(IBAction) btnNextSong_touchUp:(id)sender{
	[self nextSong];
}

-(IBAction) btnPlay_touchUp:(id)sender{
	[self play];
}

-(IBAction) btnPause_touchUp:(id)sender{
	[self pause];
}

-(IBAction) btnAddToPlaylist_touchUp:(id)sender{
    
}

-(IBAction) btnShare_touchUp:(id)sender{
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fizy.com/#s/%@", currentSong.ID]];
	SHKItem *item = [SHKItem URL:url title: currentSong.title];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	//[actionSheet showFromToolbar:navigationController.toolbar];
	[actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	fizyPlayer.nowPlaying = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:FZPlayerQueueChangedNotification
												  object:fizyPlayer];
	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:FZPlayerSongChangedNotification
												  object:fizyPlayer];
	
	// stop receiving remote control events
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];

}


- (void)dealloc {
	[self destroyPlayer];
	[self destroyStreamer];
	
    [super dealloc];
}


@end
