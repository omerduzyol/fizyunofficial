//
//  DetailViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTransitionDuration 0.3

@class FizySongInfo;

@interface DetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *imgTypeIcon;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UIView *modalView;

@property (nonatomic, retain) FizySongInfo *songInfo;

-(IBAction)btnPlay_touchUp:(id)sender;
-(IBAction)btnAddToList_touchUp:(id)sender;
-(IBAction)btnAddToQueueBegin_touchUp:(id)sender;
-(IBAction)btnAddToQueueEnd_touchUp:(id)sender;
-(IBAction)btnClose_touchUp:(id)sender;

-(void) show;
-(void) hide;

@end
