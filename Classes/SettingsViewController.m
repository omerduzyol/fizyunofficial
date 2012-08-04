    //
//  SettingsViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileProvider.h"

@implementation SettingsViewController

@synthesize swVideoPlayback, swHighQualityOnly, swShowQueueBadge, swEnableMultitasking, swDownloadAlbumarts;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];

	if (isConfigChanged) {
		[[ProfileProvider sharedProfileProvider] saveConfig];
		
		isConfigChanged = NO;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	settings = [[ProfileProvider sharedProfileProvider] settings];
	
	swVideoPlayback.on = [[settings objectForKey:@"videoPlayback"] boolValue];
	swHighQualityOnly.on = [[settings objectForKey:@"highQualityOnly"] boolValue];
	swShowQueueBadge.on = [[settings objectForKey:@"showQueueBadge"] boolValue];
	swDownloadAlbumarts.on = [[settings objectForKey:@"downloadAlbumArts"] boolValue];
	swEnableMultitasking.on = [[settings objectForKey:@"enableMultitasking"] boolValue];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) swVideoPlayback_changed:(UISwitch *)sender{
	[settings setValue:[NSNumber numberWithBool:swVideoPlayback.on] forKey:@"videoPlayback"];
	isConfigChanged = YES;
}

- (IBAction) swHighQualityOnly_changed:(UISwitch *)sender{
	[settings setValue:[NSNumber numberWithBool:swHighQualityOnly.on] forKey:@"highQualityOnly"];
	isConfigChanged = YES;
}

- (IBAction) swShowQueueBadge_changed:(UISwitch *)sender{
	[settings setValue:[NSNumber numberWithBool:swShowQueueBadge.on] forKey:@"showQueueBadge"];
	isConfigChanged = YES;
}

- (IBAction) swDownloadAlbumarts_changed:(UISwitch *)sender{
	[settings setValue:[NSNumber numberWithBool:swDownloadAlbumarts.on] forKey:@"downloadAlbumArts"];
	isConfigChanged = YES;
}

- (IBAction) swEnableMultitasking_changed:(UISwitch *)sender{
	[settings setValue:[NSNumber numberWithBool:swEnableMultitasking.on] forKey:@"enableMultitasking"];
	isConfigChanged = YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
