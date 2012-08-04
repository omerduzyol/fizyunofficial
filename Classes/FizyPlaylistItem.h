//
//  FizyPlaylistItem.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FizyPlaylistItem : NSObject

@property(nonatomic, retain) NSString *ID;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, assign) BOOL *is_shuffle_on;

- (NSDictionary *) asDictionary;

@end


