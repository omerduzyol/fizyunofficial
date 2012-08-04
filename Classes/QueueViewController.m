    //
//  QueueViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/21/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "QueueViewController.h"
#import "SearchItemCell.h"
#import "Fizy.h"

@implementation QueueViewController

@synthesize dataTable, dataTableMirror, btnShuffleMode, btnRepeatMode, btnSaveQueue, btnClear, msgTip, viewButtons;

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
	
	toggleEdit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditMode:)];
	doneEdit = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(toggleEditMode:)];
	
	
	player = [Fizy sharedFizy].player;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fizyPlayerQueueChanged:) 
												 name:FZPlayerQueueChangedNotification 
											   object:player];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fizyPlayerSongChanged:) 
												 name:FZPlayerSongChangedNotification 
											   object:player];
	
	
	NSMutableDictionary *setts = [[ProfileProvider sharedProfileProvider] settings];
    
    btnRepeatMode.selected = [[setts objectForKey:@"repeat"] boolValue];
    btnShuffleMode.selected = [[setts objectForKey:@"shuffle"] boolValue];
    
    msgTip.hidden = NO;
    viewButtons.hidden = YES;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Fizy Player Notifications
- (void) fizyPlayerQueueChanged:(NSNotification*)notification{
	FizyQueueChangedInfo *info = [[notification userInfo] objectForKey:@"info"];
	
	if(info.reason == FZ_QUEUECHANGED_FOR_REMOVE){
		//[self updateOnscreenSongCells:dataTable];
		//[self updateOnscreenSongCells:dataTableMirror];
		
		return;
	}
	
	if (!dataTable.editing) {
		if ([player.songQueue count] > 0) {
			[self.navigationItem setRightBarButtonItem:toggleEdit animated:YES];	
			
			btnClear.enabled = YES;
			btnSaveQueue.enabled = YES;
            
            msgTip.hidden = YES;
            viewButtons.hidden = NO;
		} else {
			[self.navigationItem setRightBarButtonItem:nil animated:YES];
			
			btnClear.enabled = NO;
			btnSaveQueue.enabled = NO;
            
            msgTip.hidden = NO;
            viewButtons.hidden = YES;
		}
	}

	if (info.reason != FZ_QUEUECHANGED_FOR_REORDER) {
		[dataTable reloadData];
	}
	
	[dataTableMirror reloadData];
}

- (void) fizyPlayerSongChanged:(NSNotification*)notification{
	FizySongInfo *song = [[notification userInfo] objectForKey:@"song"];
	
	[self updateOnscreenSongCells:dataTable];
	[self updateOnscreenSongCells:dataTableMirror];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if (player.songQueue == nil)
		return 0;
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger count = 0 ;
	
	if(player.songQueue == nil)
		return count;
	else {
		count = [player.songQueue count];
	}

	return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"QueueCell";
	static NSString *CellIdentifier2 = @"QueueCellInline";

	/*
	 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	 if (cell == nil) {
	 cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	 
	 }*/
	
	SearchItemCell *cell = nil;
	
	if (tableView == dataTable) {
		cell = (SearchItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil){
			cell = [[[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}	
	} else {
		cell = (SearchItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil){
			cell = [[[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	
	FizySongInfo *item = [player.songQueue objectAtIndex:indexPath.row];
	
	BOOL itemIsPlaying = NO;
	FizySongInfo *current = [[Fizy sharedFizy].player getCurrentSong];
	if (current != nil && [current.ID isEqualToString:item.ID])
		itemIsPlaying = YES;
	
	
	cell.textLabel.text = item.songname;
	
	NSInteger minutes = floor([item.duration floatValue] /60);
	NSInteger seconds = round([item.duration floatValue] - minutes * 60);
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / [%02d:%02d]", item.artist, minutes, seconds];
	
	/*
	if ([item.type isEqualToString:@"mp3"] || [item.type isEqualToString:@"m4a"]) {
		cell.imageView.image = [UIImage imageNamed:@"icon-tablerow-song-normal.png"];
	} else {
		cell.imageView.image =[UIImage imageNamed:@"icon-tablerow-video-normal.png"];
	}*/
	
	if ([item.type isEqualToString:@"mp3"] || [item.type isEqualToString:@"m4a"]) {
		if (itemIsPlaying) {
			cell.imageView.image = [UIImage imageNamed:@"icon-tablerow-song-playing.png"];
		} else {
			cell.imageView.image = [UIImage imageNamed:@"icon-tablerow-song-normal.png"];	
		}
	} else {
		if (itemIsPlaying) {
			cell.imageView.image =[UIImage imageNamed:@"icon-tablerow-video-playing.png"];
		} else {
			cell.imageView.image =[UIImage imageNamed:@"icon-tablerow-video-normal.png"];
		}
		
	}
	
	return cell;
}

- (void) updateSongCell:(NSIndexPath *)indexPath forTable:(UITableView *)tableView{
	if (indexPath.row >= [player.songQueue count]) {
		return;
	}
	
	FizySearchItem *item = [player.songQueue objectAtIndex:indexPath.row];
	
	if (!item) 
		return;

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	BOOL itemIsPlaying = NO;
	FizySongInfo *current = [[Fizy sharedFizy].player getCurrentSong];
	if (current != nil && [current.ID isEqualToString:item.ID])
		itemIsPlaying = YES;
	
	if ([item.type isEqualToString:@"mp3"] || [item.type isEqualToString:@"m4a"]) {
		if (itemIsPlaying) {
			cell.imageView.image = [UIImage imageNamed:@"icon-tablerow-song-playing.png"];
		} else {
			cell.imageView.image = [UIImage imageNamed:@"icon-tablerow-song-normal.png"];	
		}
	} else {
		if (itemIsPlaying) {
			cell.imageView.image =[UIImage imageNamed:@"icon-tablerow-video-playing.png"];
		} else {
			cell.imageView.image =[UIImage imageNamed:@"icon-tablerow-video-normal.png"];
		}
		
	}
}

- (void) updateOnscreenSongCells:(UITableView *)tableView{
	//NSLog(@"Updating onscreen cells...");
	
	NSArray *visiblePaths = [tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		[self updateSongCell:indexPath forTable:tableView];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FizySongInfo *item = [player.songQueue objectAtIndex:indexPath.row];
	
	//NSLog(@"row selected");
	
	[[Fizy sharedFizy].player setCurrentSong:item];
	if (tableView == dataTable) {
		[[Fizy sharedFizy].player showNowPlaying];		
	}
	
	[self updateOnscreenSongCells:dataTable];
	[self updateOnscreenSongCells:dataTableMirror];
	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

	[player moveSongFromIndex:[fromIndexPath row] toIndexPath:[toIndexPath row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{	/*
	if (player.queueIndex == indexPath.row && [player isQueuePlaying]) {
		return NO;
	}*/	
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([player removeSongFromQueue:indexPath.row]) {
		[dataTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		[dataTableMirror deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

- (void)toggleEditMode:(UIBarButtonItem*)sender{

	[dataTable setEditing:!dataTable.editing animated:YES];
	[dataTableMirror setEditing:!dataTableMirror.editing animated:YES];
	
	if (dataTable.editing) {
		[self.navigationItem setRightBarButtonItem:doneEdit animated:YES];
	} else {
		[self.navigationItem setRightBarButtonItem:toggleEdit animated:YES];
	}

}

#pragma mark -
#pragma mark UI Events

- (IBAction) btnClearQueue_touchUp:(UIButton *)button{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Queue" 
										   message:@"Are you sure want to clear queue?"
										  delegate:self 
								 cancelButtonTitle:@"No" 
								 otherButtonTitles:@"Yes", nil];
	alert.tag = 0x01;
		
	[alert show];
	[alert release];
	
}

- (IBAction) btnShuffleMode_touchUp:(UIButton *)button{
	if (![player getShuffle]) {
		[player setShuffle:YES];
		button.selected = YES;
		
		btnRepeatMode.enabled = NO;
        btnRepeatMode.selected = NO;
		
		[player setRepeat:NO];
	} else {
		[player setShuffle:NO];
		button.selected = NO;
		
		btnRepeatMode.enabled = YES;
	}
	
}

- (IBAction) btnRepeatMode_touchUp:(UIButton *)button{
	if (![player getRepeat]) {
		[player setRepeat:YES];
		button.selected = YES;
		
	} else {
		[player setRepeat:NO];
		button.selected = NO;
		
	}
}

- (IBAction) btnSaveQueue_touchUp:(UIButton *)button{
    
    return;
    
    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:@"Save Queue as Playlist" message:@"\n\n\n"
                                                           delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    
    inputAlert.tag = 0x02;
    
    UILabel *lblPlaylistName = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    lblPlaylistName.font = [UIFont systemFontOfSize:16];
    lblPlaylistName.textColor = [UIColor whiteColor];
    lblPlaylistName.backgroundColor = [UIColor clearColor];
    lblPlaylistName.shadowColor = [UIColor blackColor];
    lblPlaylistName.shadowOffset = CGSizeMake(0,-1);
    lblPlaylistName.textAlignment = UITextAlignmentCenter;
    lblPlaylistName.text = @"Playlist Name";
    [inputAlert addSubview:lblPlaylistName];
    
    
    UITextField *txtPlaylistName = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
//    passwordField.font = [UIFont systemFontOfSize:18];
//    passwordField.backgroundColor = [UIColor whiteColor];
  //  passwordField.secureTextEntry = NO;
    txtPlaylistName.borderStyle = UITextBorderStyleRoundedRect;
    txtPlaylistName.keyboardAppearance = UIKeyboardAppearanceAlert;
    txtPlaylistName.delegate = self;
    txtPlaylistName.tag = 0x02;
    [txtPlaylistName becomeFirstResponder];
    [inputAlert addSubview:txtPlaylistName];
    
  //  [inputAlert setTransform:CGAffineTransformMakeTranslation(0,109)];
    [inputAlert show];
    [inputAlert release];
    
    [txtPlaylistName release];
    [lblPlaylistName release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// prompt for queue clear?
	if(alertView.tag == 0x01){
		if (buttonIndex == 1) {
			[player clearQueue];	
		}
	}
    
    // prompt for queue save?
	if(alertView.tag == 0x02){
		if (buttonIndex == 1) {
            shouldSaveAsPlaylist = YES;
		}
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 0x02) {
        shouldSaveAsPlaylist = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0x02 && shouldSaveAsPlaylist) {
        [player saveQueueAsPlaylist:[textField text]];   
        shouldSaveAsPlaylist = NO;
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:FZPlayerQueueChangedNotification
												  object:player];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:FZPlayerSongChangedNotification
												  object:player];
}


- (void)dealloc {
    [super dealloc];
	
	[toggleEdit release];
	[doneEdit release];
}


@end
