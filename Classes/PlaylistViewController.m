//
//  PlaylistViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistViewController.h"
#import "Fizy.h"
#import "SearchItemCell.h"

@implementation PlaylistViewController

@synthesize dataTable;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

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
    
    //playlists = [[ProfileProvider sharedProfileProvider] playlists];
    
    [Fizy sharedFizy].loginCallbackContext = self;
	[Fizy sharedFizy].loginCallback = @selector(loginCallback:);
    [Fizy sharedFizy].getPlaylistsCallbackContext = self;
    [Fizy sharedFizy].getPlaylistsCallback = @selector(playlistsCallback:);
    
    [Fizy sharedFizy].getSongsCallbackContext = self;
    [Fizy sharedFizy].getSongsCallback = @selector(getSongsCallback:);
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
	
	// register keyboard notifications for invisiblity of textboxes
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];	
    
}

- (void)viewDidAppear:(BOOL)animated{
    if (playlists == nil && [Fizy sharedFizy].isLoggedIn) {
        [[Utility sharedHUD] show:YES];
        [[Fizy sharedFizy] getPlaylists];
        loginContainer.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [activeTextField resignFirstResponder];
    
	// unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (playlists == nil || [playlists count] <= 0)
		return 0;
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger count = 0 ;
	
	if(playlists == nil)
		return count;
	else {
		count = [playlists count];
	}
    
	return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"PlaylistCell";
    
	
	SearchItemCell *cell = nil;
	
		cell = (SearchItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil){
			cell = [[[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}	
	
//	FizySongInfo *item = [play objectAtIndex:indexPath.row];	    
    FizyPlaylistItem *item = [playlists objectAtIndex:indexPath.row];
    
	cell.textLabel.text = item.title;
	
	//cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / [%02d:%02d]", item.artist, minutes, seconds];
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FizyPlaylistItem *item = [playlists objectAtIndex:indexPath.row];
    
    [[Fizy sharedFizy] getSongs:item.ID];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)btnAddClick:(id)sender{

}

-(IBAction)btnLoginClick:(id)sender{
    if([txtUserName.text length] <=0)
    {
        [Utility alertMessage:@"Login Error" message:@"Please enter a valid user name."];
        return;
    }
    
    if([txtPassword.text length] <=0)
    {
        [Utility alertMessage:@"Login Error" message:@"Please enter a valid password."];
        return;
    }
    
    if(activeTextField!=nil)
        [activeTextField resignFirstResponder];
    
    [[Utility sharedHUD] show:YES];
    [[Fizy sharedFizy] login:txtUserName.text withPassword:txtPassword.text];
}

- (void)loginCallback:(NSData *)response{
    if(![Fizy sharedFizy].isLoggedIn){
        [[Utility sharedHUD] hide:YES];
        [Utility alertMessage:@"Login Error" message:@"Invalid username or password!"];
        loginContainer.hidden = NO;
    } else {
        [[Fizy sharedFizy] getPlaylists];
        loginContainer.hidden = YES;
        
        NSMutableDictionary *settings = [[ProfileProvider sharedProfileProvider] settings];
        
        [settings setValue:txtUserName.text forKey:@"userName"];
        [settings setValue:txtPassword.text forKey:@"password"];
        
        [[ProfileProvider sharedProfileProvider] saveConfig];
    }
}

- (void)playlistsCallback:(NSArray *)arrPlaylist{
    playlists = arrPlaylist;
    if (playlists == nil || [playlists count] == 0) {
        msgNoRecords.hidden = NO;
    } else {
        msgNoRecords.hidden = YES;
    }
    
    [dataTable reloadData];
    
    [[Utility sharedHUD] hide:YES];
}

- (void)getSongsCallback:(NSArray *)arrSongs{
    
    [[Utility sharedHUD] hide:YES];
    
    [[Fizy sharedFizy].player clearQueue];
    for (FizySongInfo * song in arrSongs) {
        [[Fizy sharedFizy].player addSongQueue:song toBeginning:NO];
    }
}

#pragma -
#pragma UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    activeTextField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeTextField = nil;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self btnLoginClick:nil];
    
    return YES;
}


#pragma mark -
#pragma mark Keyboard Notifications

- (void) moveViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    

    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if(up){
        oldFrame = loginContainer.frame;
        
        CGRect newFrame = loginContainer.frame;
        CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
        
        int newY = (newFrame.origin.y + activeTextField.frame.origin.y) - (keyboardFrame.origin.y /2) + newFrame.origin.y;
    
        newFrame.origin.y -= newY * (up? 1 : -1);
        newFrame.size.height -= newY * (up? -1 : 1);
    
        loginContainer.frame = newFrame;
    } else
    loginContainer.frame = oldFrame;        
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{    
    [self moveViewForKeyboard:aNotification up:YES];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification 
{
    [self moveViewForKeyboard:aNotification up:NO];
}


@end
