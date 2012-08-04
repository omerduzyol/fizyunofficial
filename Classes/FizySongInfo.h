//
//  FizySongInfo.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FizySongInfo : NSObject {
	NSString *ID;
	NSNumber *duration;
	NSString *provider;
	NSString *providerNumber;
	NSString *source;
	NSString *title;
	NSString *artist;
	NSString *songname;
	NSString *type;
	BOOL requiresHTTPStreaming;
	BOOL isDirty;
	BOOL canPlay;
	NSDate *timestamp;
	
	BOOL isInited;
}

@property(nonatomic,retain) NSString *ID;
@property(nonatomic,retain) NSNumber *duration;
@property(nonatomic,retain) NSString *provider;
@property(nonatomic,retain) NSString *providerNumber;
@property(nonatomic,retain) NSString *source;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *artist;
@property(nonatomic,retain) NSString *songname;
@property(nonatomic,retain) NSString *type;
@property(nonatomic,assign) BOOL requiresHTTPStreaming;
@property(nonatomic,assign) BOOL isDirty;
@property(nonatomic,assign) BOOL canPlay;
@property(nonatomic,retain) NSDate *timestamp;

- (void) generateArtistAndSongname;
- (void) initSong;
- (NSDictionary *) asDictionary;

@end
