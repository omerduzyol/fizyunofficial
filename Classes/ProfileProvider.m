//
//  ProfileProvider.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 9/25/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "JSON.h"
#import "ProfileProvider.h"

@implementation ProfileProvider
@synthesize isFirstLaunch;

SYNTHESIZE_SINGLETON_FOR_CLASS(ProfileProvider);


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
		configPath = [self getConfigPath];
		
		[self copyConfigIfNeeded:NO];
		
		NSString *jsonString = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:NULL];
		
		profileRoot = [[jsonString JSONValue] deepCopy];
		
		if(profileRoot == nil || 
		   [profileRoot objectForKey:@"settings"] == nil ||
		   [profileRoot objectForKey:@"queue"] == nil ||
		   [profileRoot objectForKey:@"playlists"] == nil){
			
			NSLog(@"ProfileProvider: Invalid config file!");
			
			[self copyConfigIfNeeded:YES];
			
			return nil;
		} else {
			NSLog(@"ProfileProvider: Loaded successfully.");
			configSettings = [[NSMutableDictionary alloc] init];
			
			[configSettings addEntriesFromDictionary:[profileRoot objectForKey:@"settings"]];
			
			NSLog(@"setts: %@", [configSettings description]);
			
			
			configQueue = [[NSMutableArray alloc] init];
			[configQueue addObjectsFromArray:[profileRoot objectForKey:@"queue"]];
			
			configPlaylists = [[NSMutableArray alloc] init];
			[configPlaylists addObjectsFromArray:[profileRoot objectForKey:@"playlists"]];
		}
	}
	
	return self;
}

- (NSMutableDictionary *) settings{
	return configSettings;
}

- (NSMutableArray *) queue {
	return configQueue;
}

- (NSMutableArray *) playlists{
	return configPlaylists;
}

- (void) saveConfig {
	NSLog(@"ProfileProvider: Saving configuration...");
	//NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:configSettings forKey:@"settings"];
	
	NSDictionary *tmpDict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:configSettings, configQueue, configPlaylists, nil]
														forKeys: [NSArray arrayWithObjects:@"settings", @"queue", @"playlists", nil ]];

	NSString *stringData = [tmpDict JSONRepresentation];

	NSError *err = nil;
	
	BOOL result = [stringData writeToFile:[self getConfigPath] atomically:YES encoding:NSUTF8StringEncoding error:&err];
	if(!result && err != nil) {
		NSLog(@"ProfileProvider: Write error : %@", [err description]);
	}
	/*
	 if([stringData writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:&err]){
	 NSLog(@"Settings: Config saved!");	
	 } else {
	 NSLog(@"Settings: Config can't saved! Error: %@", [err description]);
	 }
	 */
}

- (void) copyConfigIfNeeded:(BOOL)force {
	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	
	BOOL success = [fileManager fileExistsAtPath:configPath]; 
	
	if(!success || force) {
		
		NSString *defaultConfigPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"Profile.json" ];
		
		if (force && success) {
			[fileManager removeItemAtPath:configPath error:nil];
		}
		
		self.isFirstLaunch = YES;
		
		success = [fileManager copyItemAtPath:defaultConfigPath toPath:configPath error:&error];
		
		if (!success) 
			NSAssert1(0, @"ProfileProvider: Failed to create writable config file with message '%@'.", [error localizedDescription]);
		else {
			NSLog(@"ProfileProvider: Config %@ copied to documents.",@"Settings.json");
			
		}
		
	} else {
		self.isFirstLaunch = NO;
	}
	
}

- (NSString *) getConfigPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent: @"Profile.json"];
}

-(void) dealloc{
	[configSettings release];
	[configQueue release];
	[configPlaylists release];
	
	[configPath release];
	[super dealloc];
}

@end
