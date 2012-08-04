//
//  FizySearchItem.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "FizySearchItem.h"


@implementation FizySearchItem

@synthesize ID, duration, title, type, artist, songname, songInfo;

- (void) generateArtistAndSongname {
	NSRange delimiter = [self.title rangeOfString:@"-"];
	if (delimiter.location < 0 || delimiter.location == NSNotFound) {
		delimiter = [self.title rangeOfString:@" "];
	}
	
	self.title = [self.title stringByDecodingHTMLEntities];
	
	if (delimiter.location > 0 && delimiter.location != NSNotFound) {
		self.artist = [[[self.title substringToIndex:delimiter.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString];
		self.songname = [[[self.title substringFromIndex:delimiter.location+delimiter.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] capitalizedString];
	} else {
		self.artist = [self.title capitalizedString];
		self.songname = [self.title capitalizedString];
	}
}

@end
