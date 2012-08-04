//
//  FizySongInfo.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "FizySongInfo.h"


@implementation FizySongInfo

@synthesize ID, duration, provider, providerNumber, source, title, artist, songname, type, requiresHTTPStreaming, isDirty, timestamp, canPlay;

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

- (void) initSong {
	
	if ([self.provider isEqualToString:@"wrzuta"]) {
		if ([self.type isEqualToString:@"mp3"]) {
			self.canPlay = YES;
			self.requiresHTTPStreaming = YES;
		} else {
			self.canPlay = NO;
		}
	} else if ([self.provider isEqualToString:@"soundcloud"]) {
		self.canPlay = YES;
	} else if ([self.provider isEqualToString:@"grooveshark"]) {

		if ([self.source hasPrefix:@"http"]) {			
			self.canPlay = YES;
		} else {
			// TODO: unknown state fix later.
			self.canPlay = NO;
		}
	} else if ([self.provider isEqualToString:@"dailymotion"]) {
		self.canPlay = YES;
	} else if ([self.provider isEqualToString:@"youtube"]) {
		self.canPlay = YES;
	} else {
		self.canPlay = NO;
	}
	
}

- (NSDictionary *) asDictionary {
	//{"ID":"16jxnv","providerNumber":"3","type":"mp3","title":"tarkan - asla vazgecemem","duration":"252","provider":"wrzuta","source":"http:\/\/fz.fizy.com\/6d33034c4562dd139c64fb2664f46d9c","lyrics":"ah, g\u00f6zlerin\r<br\/> g\u00f6zlerin beni benden alan\r<br\/> sislerin ardindan, bu\u011fulu bakan\r<br\/> \r<br\/> ah, s\u00f6zlerin\r<br\/> s\u00f6zlerin beni benden \u00e7alan\r<br\/> bir nehir misali, kalbime akan\r<br\/> \r<br\/> asla, asla vazge\u00e7emem, senden asla\r<br\/> olamam ben sensiz\r<br\/> yapamam sevgisiz\r<br\/> asla, asla vazge\u00e7emem, senden asla\r<br\/> olamam ben sensiz\r<br\/> yapamam kimsesiz\r<br\/> \r<br\/> ah, sa\u00e7larin\r<br\/> sa\u00e7larin alev alev yakan\r<br\/> r\u00fczgarla savrulup bin i\u015fik sa\u00e7an\r<br\/> "}
	
	NSMutableDictionary *dictJson = [[NSMutableDictionary alloc] init];
	
	[dictJson setObject:ID forKey:@"ID"];
	[dictJson setObject:duration forKey:@"duration"];
	[dictJson setObject:provider forKey:@"provider"];
	[dictJson setObject:providerNumber forKey:@"providerNumber"];
	[dictJson setObject:source forKey:@"source"];
	[dictJson setObject:title forKey:@"title"];
	[dictJson setObject:artist forKey:@"artist"];
	[dictJson setObject:songname forKey:@"songname"];
	[dictJson setObject:type forKey:@"type"];
	[dictJson setObject:(requiresHTTPStreaming ? @"true":@"false") forKey:@"requiresHTTPStreaming"];
	[dictJson setObject:(isDirty ? @"true":@"false") forKey:@"isDirty"];
	[dictJson setObject:(canPlay ? @"true":@"false") forKey:@"canPlay"];
	
	//NSString *result = [dictJson JSONRepresentation];
	
	NSDictionary *result = [NSDictionary dictionaryWithDictionary:dictJson];
	
	[dictJson release];
	
	return [result autorelease];
}

@end


