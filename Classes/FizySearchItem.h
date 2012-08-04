//
//  FizySearchItem.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FizySongInfo;

@interface FizySearchItem : NSObject {
	NSString *ID;
	NSNumber *duration;
	NSString *title;
	NSString *type;
	NSString *artist;
	NSString *songname;
	FizySongInfo *songInfo;
}

@property(nonatomic, retain) NSString *ID;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *artist;
@property(nonatomic, retain) NSString *songname;
@property(nonatomic, retain) FizySongInfo *songInfo;

- (void) generateArtistAndSongname;

@end
