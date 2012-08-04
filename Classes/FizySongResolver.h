//
//  FizySongResolver.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/19/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FizySongInfo, FizySearchItem;
@protocol FizySongResolverDelegate;

@interface FizySongResolver : NSObject {
	FizySearchItem *item;
    NSIndexPath *indexPathInTableView;
    id <FizySongResolverDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *infoConnection;	
}

@property (nonatomic, retain) FizySearchItem *item;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <FizySongResolverDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *infoConnection;

- (void)startDownload;
- (void)cancelDownload;



@end


@protocol FizySongResolverDelegate 

- (void)songResolved:(NSIndexPath *)indexPath;

@end