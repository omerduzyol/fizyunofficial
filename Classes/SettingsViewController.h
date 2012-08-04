//
//  SettingsViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
	
	NSMutableDictionary *settings;
	
	BOOL isConfigChanged;
}

@property (nonatomic, retain) IBOutlet UISwitch *swVideoPlayback;
@property (nonatomic, retain) IBOutlet UISwitch *swHighQualityOnly;
@property (nonatomic, retain) IBOutlet UISwitch *swShowQueueBadge;
@property (nonatomic, retain) IBOutlet UISwitch *swEnableMultitasking;
@property (nonatomic, retain) IBOutlet UISwitch *swDownloadAlbumarts;

- (IBAction) swVideoPlayback_changed:(UISwitch *)sender;
- (IBAction) swHighQualityOnly_changed:(UISwitch *)sender;
- (IBAction) swShowQueueBadge_changed:(UISwitch *)sender;
- (IBAction) swDownloadAlbumarts_changed:(UISwitch *)sender;
- (IBAction) swEnableMultitasking_changed:(UISwitch *)sender;


@end
