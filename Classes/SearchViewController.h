//
//  SearchViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideSwipeTableViewController.h"
#import "FizySongResolver.h"


@interface SearchViewController : SideSwipeTableViewController<FizySongResolverDelegate, 
UITableViewDataSource, 
UITableViewDelegate, 
UISearchDisplayDelegate, 
UISearchBarDelegate> {
	NSInteger currentPage;
	NSMutableArray *searchResults;
	IBOutlet UIView *viewTableLoading;
	IBOutlet UIImageView *messageSearch;
	IBOutlet UIImageView *messageNoResults;	
	IBOutlet UIButton *btnFilterAll;
	IBOutlet UIButton *btnFilterAudio;
	IBOutlet UIButton *btnFilterVideo;
	
	
	BOOL recordsFinished;
	
	NSArray* buttonData;
	NSMutableArray* buttons;
	
	NSString* searchString;
	
	NSMutableDictionary *songInfoInProgress;  
	
}

@property (nonatomic, retain) IBOutlet UITableView *dataTable;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar; 


@property (nonatomic, retain) NSMutableDictionary *songInfoInProgress;  


- (void) searchByString:(NSString*)keyword;
- (IBAction) btnShowNowPlaying_touchUp:(id)sender;
- (IBAction) searchFilterButton_touchUp:(id)sender;

- (void)startSongResolveDownload:(FizySearchItem *)item forIndexPath:(NSIndexPath *)indexPath;
- (void) updateSongCell:(NSIndexPath *)indexPath;
- (void) updateOnscreenSongCells;
- (BOOL) updateSongInfo:(FizySongInfo *)info forIndexPath:(NSIndexPath *)indexPath;
- (void) purgeSongItems;
@end
