    //
//  EventRecieverController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 8/25/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "EventRecieverController.h"
#import "Fizy.h"

@implementation EventRecieverController

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
	
	// Handle Audio Remote Control events (only available under iOS 4
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	}
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// This is necessary in order to get notified of the Audio Remote Control events
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	
	[self resignFirstResponder];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{	
	if (receivedEvent.type == UIEventTypeRemoteControl) {
		
        switch (receivedEvent.subtype) {
				
            case UIEventSubtypeRemoteControlTogglePlayPause:
				[[Fizy sharedFizy].player togglePlay];
                break;
            case UIEventSubtypeRemoteControlPlay:
				[[Fizy sharedFizy].player play];
                break;				
            case UIEventSubtypeRemoteControlPreviousTrack:
				[[Fizy sharedFizy].player prevSong];
                break;
				
            case UIEventSubtypeRemoteControlNextTrack:
				[[Fizy sharedFizy].player nextSong];
                break;
				
            default:
                break;
        }
    }
	
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
}


@end
