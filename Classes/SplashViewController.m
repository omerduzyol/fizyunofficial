//
//  SplashViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "Fizy.h"
#import "SplashViewController.h"
#import "UICustomAlertView.h"
#import "FizyUnofficialAppDelegate.h"

@implementation SplashViewController

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
/*
    [Fizy sharedFizy].providerCallbackContext = self;
    
    [Fizy sharedFizy].providerSetCallback = @selector(setProviderCallback:response:);
    [Fizy sharedFizy].providerSetError = @selector(setProviderError:);
  */  
}


- (void) viewWillAppear:(BOOL)animated{
    

}

- (void) viewDidAppear:(BOOL)animated{
	
	// check internet connection 
	if (![[UIDevice currentDevice] networkAvailable])
	{
        /*

		UICustomAlertView *confirmView = 
		[[UICustomAlertView alloc] initWithTitle:@"Please check your connectivity" 
										 message:@"You don't have working internet connection now. If you have 3G network Fizy will operate, otherwise you can try turn on WIFI connection and try again."
                                 backgroundColor:HEXCOLOR(0xe48005ff) strokeColor:HEXCOLOR(0xf1f3de7f) delegate:self cancelButtonTitle:@"Okay" 
							   otherButtonTitles:nil];
		
		[confirmView show];
		
		[confirmView release];*/
        
        UIAlertView *alert = 
        [[UIAlertView alloc] initWithTitle:@"Please check your connectivity"  
                                   message:@"You don't have working internet connection now. If you have 3G network Fizy will operate, otherwise you can try turn on WIFI connection and try again."
                                  delegate:self cancelButtonTitle:@"Okay" 
                         otherButtonTitles:nil];
        [alert show];
        
        [alert release];
		
		return;
	}
	
    [self performSelectorInBackground:@selector(backgroundTask) withObject:nil];

    
    //[[Fizy sharedFizy] login:@"omerduzyol" withPassword:@"omeromer"];
		
}

- (void)backgroundTask{
    
	// init and load profiles
	[ProfileProvider sharedProfileProvider];
	
	[[Fizy sharedFizy] setProvider:NO forProvider:@"metacafe"];
	[[Fizy sharedFizy] setProvider:YES forProvider:@"grooveshark"];
	    
	// load previous queue and restore state
	[[Fizy sharedFizy].player loadQueue];
    
    [Utility performSelectorOnAppDelegate:@"showMainScreen"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	exit(0);	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

	// TODO: remove allocated images
}


@end
