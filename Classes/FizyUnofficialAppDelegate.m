//
//  FizyUnofficialAppDelegate.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "FizyUnofficialAppDelegate.h"
#import "MBProgressHUD.h"
#import "NowPlayingViewController.h"
#import "DetailViewController.h"
#import "EventRecieverController.h"
#import "SplashViewController.h"
#import "Fizy.h"

@implementation FizyUnofficialAppDelegate

@synthesize window;
@synthesize tabBarController, detailView, mainNavController, nowPlayingViewController, eventReciever, splashViewController;

- (MBProgressHUD *) getHUD{
	return HUD;
}

- (void)showSongDetail:(FizySongInfo *)songInfo{
    [self.window bringSubviewToFront:detailView.view];
    detailView.songInfo = songInfo;
    [detailView show];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"url", url);
	
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	
	// The hud will dispable all input on the view
    HUD = [[MBProgressHUD alloc] initWithWindow:self.window];
	HUD.labelText = @"Loading";
	
	// Add HUD to screen
    [self.window addSubview:HUD];
    
    [self.window addSubview:detailView.view];
	
	
	[mainNavController pushViewController:tabBarController animated:NO];
	
	[self.window addSubview:mainNavController.view];
    
    
	// setup and show splash view	
	[self.window addSubview:splashViewController.view];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)showMainScreen{
    [self.window bringSubviewToFront:mainNavController.view];
    [splashViewController.view removeFromSuperview];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"Fizy going to back...");
	
	bgIsPlaying = [nowPlayingViewController playerStatus] == FZ_PLAYERSTATUS_PLAYING;
	
	if(![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue]){
		NSLog(@"Multitasking disabled, pausing media.");
		
		[[Fizy sharedFizy].player pause];
		
		return;
	}
	
	[self.window addSubview:eventReciever.view];
    
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
	NSLog(@"avail");
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
	NSLog(@"unavail");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"Fizy went to back.");
	
	[[Fizy sharedFizy].player saveQueue];
	
	if(bgIsPlaying && [nowPlayingViewController playerStatus] != FZ_PLAYERSTATUS_PLAYING &&
	   [[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue]){
		
		if([[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"videoPlayback"] boolValue] && nowPlayingViewController.isVideoPlaying)
			return;
			
		[[Fizy sharedFizy].player play];
			
	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	NSLog(@"will enter foreground..");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	NSLog(@"Fizy came to front.");
	
	if(![[[[ProfileProvider sharedProfileProvider] settings] objectForKey:@"enableMultitasking"] boolValue] && bgIsPlaying){
		NSLog(@"Multitasking disabled, restoring media state...");
		
		[[Fizy sharedFizy].player play];
		
		return;
	}
	
	[eventReciever.view removeFromSuperview];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	[[ProfileProvider sharedProfileProvider] saveConfig];
	
}

#pragma mark -
#pragma mark UINavigationController Delegates


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	if(viewController == tabBarController){
		[viewController.navigationController setNavigationBarHidden:YES animated:YES];
	} else {
		[viewController.navigationController setNavigationBarHidden:NO animated:YES];
	}	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	
	if(viewController == tabBarController){

	} else {

	}
	
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void) showNowPlaying{
	[mainNavController pushViewController:nowPlayingViewController animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

