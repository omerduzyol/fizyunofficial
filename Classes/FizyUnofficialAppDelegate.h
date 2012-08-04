//
//  FizyUnofficialAppDelegate.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@class NowPlayingViewController, EventRecieverController, SplashViewController;
@class DetailViewController, FizySongInfo;

static MBProgressHUD *HUD;

@interface FizyUnofficialAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	UINavigationController *mainNavController;
	NowPlayingViewController *nowPlayingViewController;
	EventRecieverController *eventReciever;
    SplashViewController *splashViewController;
	
	BOOL bgIsPlaying;
}

- (MBProgressHUD *) getHUD;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *mainNavController;
@property (nonatomic, retain) IBOutlet NowPlayingViewController *nowPlayingViewController;
@property (nonatomic, retain) IBOutlet EventRecieverController *eventReciever;
@property (nonatomic, retain) IBOutlet DetailViewController *detailView;
@property (nonatomic, retain) IBOutlet SplashViewController *splashViewController;

- (void) showNowPlaying;
- (void)showSongDetail:(FizySongInfo *)songInfo;
- (void)showMainScreen;

@end
