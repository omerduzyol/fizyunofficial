//
//  ProfileProvider.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 9/25/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


@interface ProfileProvider : NSObject {
	NSString *configPath;
	
	NSDictionary *profileRoot;
	NSMutableDictionary *configSettings;

	NSMutableArray *configQueue;
	NSMutableArray *configPlaylists;
	
	BOOL isFirstLaunch;
}

@property (assign) BOOL isFirstLaunch;

+ (ProfileProvider *)sharedProfileProvider;

- (NSMutableDictionary *) settings;
- (NSMutableArray *) queue;
- (NSMutableArray *) playlists;

- (void) copyConfigIfNeeded:(BOOL)force;
- (NSString *) getConfigPath;
- (void) saveConfig;

@end
