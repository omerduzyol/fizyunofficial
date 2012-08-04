//
//  DetailViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Fizy.h"

@implementation DetailViewController

@synthesize songInfo, modalView, lblTitle, imgTypeIcon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    modalView.layer.cornerRadius = 5;
    modalView.layer.borderWidth = 2;
    modalView.layer.borderColor = HEXCOLOR(0xecefd3f7).CGColor;
    
    modalView.layer.shadowOffset = CGSizeMake(-5, 10);
    modalView.layer.shadowRadius = 5;
    modalView.layer.shadowOpacity = 1;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)btnPlay_touchUp:(id)sender{
    [[Fizy sharedFizy].player setCurrentSong:songInfo];
    [[Fizy sharedFizy].player showNowPlaying];	
    
    [self hide];
}

-(IBAction)btnAddToList_touchUp:(id)sender{
    
}

-(IBAction)btnAddToQueueBegin_touchUp:(id)sender{
    [[Fizy sharedFizy].player addSongQueue:songInfo toBeginning:YES];
    
    [self hide];
}

-(IBAction)btnAddToQueueEnd_touchUp:(id)sender{
    [[Fizy sharedFizy].player addSongQueue:songInfo toBeginning:NO];
    
    [self hide];
}

-(void)initialDelayEnded {
    modalView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    modalView.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    modalView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    modalView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    modalView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

-(void) setSongInfo:(FizySongInfo *)info{
    songInfo = [info retain];
    
    NSInteger minutes = floor([info.duration floatValue] /60);
    NSInteger seconds = round([info.duration floatValue] - minutes * 60);
    
    lblTitle.text = [NSString stringWithFormat:@"%@ / [%02d:%02d]", info.title, minutes, seconds];
    
}  

-(void) show{
    self.view.hidden = NO;
    modalView.hidden = NO;
    
    self.view.alpha = 1;
    
    [self initialDelayEnded];
}

-(void) hide{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationStopped1)];
    modalView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    modalView.alpha = 0.0;
    [UIView commitAnimations];
    
}

-(void)hideAnimationStopped1{
    modalView.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationStopped2)];
    self.view.alpha = 0;
    [UIView commitAnimations];
}

-(void)hideAnimationStopped2{
    //[self.view removeFromSuperview];
    UIView * supervw = [self.view superview];
    [supervw sendSubviewToBack:self.view];
    
    self.view.hidden = YES;
}

-(IBAction)btnClose_touchUp:(id)sender{
    [self hide];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
