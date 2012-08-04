//
//  FizyQueueChangedInfo.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/22/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fizy.h"

@class FizySongInfo;

@interface FizyQueueChangedInfo : NSObject {
	FizySongInfo *songInfo;
	FZPlayerQueueChangedReason reason;
}

@property(retain) FizySongInfo *songInfo;
@property(assign) FZPlayerQueueChangedReason reason;

@end
