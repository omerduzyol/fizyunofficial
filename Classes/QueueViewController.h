//
//  QueueViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/21/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Fizy.h"

@interface QueueViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	FizyPlayer *player;
	UIBarButtonItem *toggleEdit;
	UIBarButtonItem *doneEdit;
	
    BOOL shouldSaveAsPlaylist;

}

@property (nonatomic, retain) IBOutlet UITableView *dataTable;
@property (nonatomic, retain) IBOutlet UITableView *dataTableMirror;
@property (nonatomic, retain) IBOutlet UIButton *btnShuffleMode;
@property (nonatomic, retain) IBOutlet UIButton *btnRepeatMode;
@property (nonatomic, retain) IBOutlet UIButton *btnSaveQueue;
@property (nonatomic, retain) IBOutlet UIButton *btnClear;
@property (nonatomic, retain) IBOutlet UIImageView *msgTip;
@property (nonatomic, retain) IBOutlet UIView *viewButtons;

- (void)toggleEditMode:(UIBarButtonItem*)sender;
- (IBAction) btnClearQueue_touchUp:(UIButton *)button;
- (IBAction) btnShuffleMode_touchUp:(UIButton *)button;
- (IBAction) btnRepeatMode_touchUp:(UIButton *)button;
- (IBAction) btnSaveQueue_touchUp:(UIButton *)button;
- (void) updateOnscreenSongCells:(UITableView *)tableView;
- (void) updateSongCell:(NSIndexPath *)indexPath forTable:(UITableView *)tableView;

@end
