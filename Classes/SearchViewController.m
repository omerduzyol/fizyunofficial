    //
//  SearchViewController.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/8/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchItemCell.h"
#import "FizyUnofficialAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Fizy.h"

#define BUTTON_LEFT_MARGIN 33.0//25.0
#define BUTTON_SPACING 40.0//28.0

@interface SearchViewController (PrivateStuff)
 -(void) setupSideSwipeView;
 -(UIImage*) imageFilledWith:(UIColor*)color using:(UIImage*)startImage;
@end

@implementation SearchViewController

@synthesize dataTable, searchBar, songInfoInProgress;

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

	UIImageView *fizyLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-header.png"]];	
	self.navigationItem.titleView = fizyLogo;
	
	
	UIImageView* iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-searchbar.png"]];
	iview.frame = CGRectMake(0, 0, 320, 44);
	[self.searchBar insertSubview:iview atIndex:1];
	[iview release];
	
	for (UIView *subview in self.searchBar.subviews) {
		if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
			[subview removeFromSuperview];
			break;
		}
	}  

	/*
	imgRowMediaSong = [UIImage imageNamed:@"icon-tablerow-song-normal.png"];
	imgRowMediaVideo = [UIImage imageNamed:@"icon-tablerow-video-normal.png"];
	
	imgRowMediaSongPlaying = [UIImage imageNamed:@"icon-tablerow-song-playing.png"];
	imgRowMediaVideoPlaying = [UIImage imageNamed:@"icon-tablerow-video-playing.png"];*/
	
	self.dataTable.hidden = YES;
	messageSearch.hidden = NO;
	
	
	// create custom now playing button
/*	UIButton *buttonNowPlaying = [UIButton 
	
	UIBarButtonItem* nowPlayingBarItem = [[UIBarButtonItem alloc] initWithCustomView:[UIImage imageNamed:@"button-nowplaying.png"]];
	self.navigationItem.rightBarButtonItem = nowPlayingBarItem;*/
	
	//src.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-searchbar.png"]];
	
	currentPage = 0;
	
	[Fizy sharedFizy].searchCallbackContext = self;
	[Fizy sharedFizy].searchCallback = @selector(searchResponseLoaded:);
	
	searchResults = [[NSMutableArray alloc] init];
	
	// Setup the title and image for each button within the side swipe view
	buttonData = [[NSArray arrayWithObjects:
				   [NSDictionary dictionaryWithObjectsAndKeys:@"play", @"tag", @"button-rowactions-play.png", @"image", nil],
				   [NSDictionary dictionaryWithObjectsAndKeys:@"queueBegin", @"tag", @"button-rowactions-addqueuebegin.png", @"image", nil],
				   [NSDictionary dictionaryWithObjectsAndKeys:@"queueEnd", @"tag", @"button-rowactions-addqueueend.png", @"image", nil],
				   /*[NSDictionary dictionaryWithObjectsAndKeys:@"addPlaylist", @"tag", @"button-rowactions-addplaylist.png", @"image", nil],*/
				   [NSDictionary dictionaryWithObjectsAndKeys:@"songInfo", @"tag", @"button-rowactions-more.png", @"image", nil],
                   nil] retain];
	buttons = [[NSMutableArray alloc] initWithCapacity:buttonData.count];
	
	self.sideSwipeView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, dataTable.frame.size.width, dataTable.rowHeight)] autorelease];
	[self setupSideSwipeView];
	
	self.songInfoInProgress = [NSMutableDictionary dictionary];
    
}

/*
- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	
	
	//[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	//[self resignFirstResponder];
}*/


- (void) setupSideSwipeView
{
	// Add the background pattern
	self.sideSwipeView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"dotted-pattern.png"]];
	
	// Overlay a shadow image that adds a subtle darker drop shadow around the edges
	UIImage* shadow = [[UIImage imageNamed:@"inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	UIImageView* shadowImageView = [[[UIImageView alloc] initWithFrame:self.sideSwipeView.frame] autorelease];
	shadowImageView.alpha = 0.6;
	shadowImageView.image = shadow;
	shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.sideSwipeView addSubview:shadowImageView];
	
	// Iterate through the button data and create a button for each entry
	CGFloat leftEdge = BUTTON_LEFT_MARGIN;
	for (NSDictionary* buttonInfo in buttonData)
	{
		// Create the button
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		// Make sure the button ends up in the right place when the cell is resized
		button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		
		// Get the button image
		UIImage* buttonImage = [UIImage imageNamed:[buttonInfo objectForKey:@"image"]];
		
		// Set the button's frame
		button.frame = CGRectMake(leftEdge, self.sideSwipeView.center.y - buttonImage.size.height/2.0, buttonImage.size.width, buttonImage.size.height);
		
		// Add the image as the button's background image
		// [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
		//UIImage* grayImage = [self imageFilledWith:[UIColor colorWithWhite:0.9 alpha:1.0] using:buttonImage];
		[button setImage:buttonImage forState:UIControlStateNormal];
		
		// Add a touch up inside action
		[button addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
		
		// Keep track of the buttons so we know the proper text to display in the touch up inside action
		[buttons addObject:button];
		
		// Add the button to the side swipe view
		[self.sideSwipeView addSubview:button];
		
		// Move the left edge in prepartion for the next button
		leftEdge = leftEdge + buttonImage.size.width + BUTTON_SPACING;
	}
}

#pragma mark Button touch up inside action
- (IBAction) touchUpInsideAction:(UIButton*)button
{
	NSIndexPath* indexPath = [self.tableView indexPathForCell:self.sideSwipeCell];
	
	NSUInteger index = [buttons indexOfObject:button];
	NSDictionary* buttonInfo = [buttonData objectAtIndex:index];
	NSString *tag = [buttonInfo objectForKey:@"tag"];

	FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];

	if ([tag isEqualToString:@"play"]) {
        [[Fizy sharedFizy].player setCurrentSong:item.songInfo];
		[[Fizy sharedFizy].player showNowPlaying];	
        
		[self updateOnscreenSongCells];
	} else if ([tag isEqualToString:@"queueBegin"]) {
		[[Fizy sharedFizy].player addSongQueue:item.songInfo toBeginning:YES];
	} else if ([tag isEqualToString:@"queueEnd"]) {
		[[Fizy sharedFizy].player addSongQueue:item.songInfo toBeginning:NO];
	} else if ([tag isEqualToString:@"songInfo"]) {
        FizyUnofficialAppDelegate * appDelegate =  (FizyUnofficialAppDelegate *)[UIApplication sharedApplication].delegate;

        [appDelegate showSongDetail:item.songInfo];
	}
        
        

	/*
	[[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"%@ on cell %d", [buttonInfo objectForKey:@"title"], indexPath.row]
								 message:nil
								delegate:nil
					   cancelButtonTitle:nil
					   otherButtonTitles:@"OK", nil] autorelease] show];*/
	
	[self removeSideSwipeView:YES];
}

#pragma mark Generate images with given fill color
// Convert the image's fill color to the passed in color
-(UIImage*) imageFilledWith:(UIColor*)color using:(UIImage*)startImage
{
	// Create the proper sized rect
	CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
	
	// Create a new bitmap context
	CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
	
	// Use the passed in image as a clipping mask
	CGContextClipToMask(context, imageRect, startImage.CGImage);
	// Set the fill color
	CGContextSetFillColorWithColor(context, color.CGColor);
	// Fill with color
	CGContextFillRect(context, imageRect);
	
	// Generate a new image
	CGImageRef newCGImage = CGBitmapContextCreateImage(context);
	UIImage* newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
	
	// Cleanup
	CGContextRelease(context);
	CGImageRelease(newCGImage);
	
	return newImage;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/




#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if(searchResults == nil)
		return 0;
	
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	if(searchResults == nil)
		return 0;
		
	return [searchResults count];
	
}

- (void)determineSearchResultSong:(SearchItemCell *)cell withInfo:(FizySongInfo *)songInfo {
	cell.disabled = !songInfo.canPlay;
	
	NSLog(@"source is: %@", songInfo.source);
	NSLog(@"provider is :%@", songInfo.provider);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	SearchItemCell *cell = (SearchItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
		cell = [[[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];
	
	if (item != nil) {
		
		BOOL itemIsPlaying = NO;
		FizySongInfo *current = [[Fizy sharedFizy].player getCurrentSong];
		if (current != nil && [current.ID isEqualToString:item.ID])
			itemIsPlaying = YES;
		
		
		cell.textLabel.text = item.songname;
		
		NSInteger minutes = floor([item.duration floatValue] /60);
		NSInteger seconds = round([item.duration floatValue] - minutes * 60);
		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / [%02d:%02d]", item.artist, minutes, seconds];
		
		// Configure the cell...
		cell.supressDeleteButton = ![self gestureRecognizersSupported];
		
		if (item.songInfo==nil) {
            cell.disabled = NO;
			// start song info resolver
			[self startSongResolveDownload:item forIndexPath:indexPath];
		} else {
			[self determineSearchResultSong:cell withInfo:item.songInfo];
		}
		
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
	} else {
		return nil;
	}
	
}


#pragma mark -
#pragma mark Table cell songResolver support

- (void)startSongResolveDownload:(FizySearchItem *)item forIndexPath:(NSIndexPath *)indexPath
{
	FizySongResolver *songResolver = [songInfoInProgress objectForKey:indexPath];
	if (songResolver == nil) {
		songResolver = [[FizySongResolver alloc] init];
		songResolver.item = item;
		songResolver.indexPathInTableView = indexPath;
		songResolver.delegate = self;
		
		[songInfoInProgress setObject:songResolver forKey:indexPath];
		[songResolver startDownload];
		[songResolver release];
	}
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadSongInfoForOnscreenRows
{
    if ([searchResults count] > 0)
    {
        NSArray *visiblePaths = [dataTable indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
			FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];
            if (!item.songInfo) { // avoid the song info download if the song already has an info
				[self startSongResolveDownload:item forIndexPath:indexPath];
			}
        }
    }
}

// called by our FizySongResolver when a song info is ready to be displayed
- (void)songResolved:(NSIndexPath *)indexPath
{
	FizySongResolver *songResolver = [songInfoInProgress objectForKey:indexPath];
	if (songResolver != nil) {
		SearchItemCell *cell = (SearchItemCell *)[dataTable cellForRowAtIndexPath:songResolver.indexPathInTableView];

		[self determineSearchResultSong:cell withInfo:songResolver.item.songInfo];

		if (cell.selected) {
			[[Utility sharedHUD] hide:YES];

			if (!cell.disabled) {                
                if ([[Fizy sharedFizy].player playerStatus] == FZ_PLAYERSTATUS_STOPPED || 
                    [[Fizy sharedFizy].player playerStatus] == FZ_PLAYERSTATUS_NA) {
                    
                    [[Fizy sharedFizy].player setCurrentSong:songResolver.item.songInfo];
                    [[Fizy sharedFizy].player showNowPlaying];	
                    
                    [self updateOnscreenSongCells];
                } else {
                    
                    FizyUnofficialAppDelegate * appDelegate =  (FizyUnofficialAppDelegate *)[UIApplication sharedApplication].delegate;
                    
                    [appDelegate showSongDetail:songResolver.item.songInfo];
                }
			}
		}
	}
}

- (void) updateSongCell:(NSIndexPath *)indexPath{
	FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];
	
	if (!item) 
		return;
	
	UITableViewCell *cell = [dataTable cellForRowAtIndexPath:indexPath];
	
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

- (void) updateOnscreenSongCells{
	//NSLog(@"Updating onscreen cells...");
	
	NSArray *visiblePaths = [dataTable indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		[self updateSongCell:indexPath];
	}
}

- (BOOL) updateSongInfo:(FizySongInfo *)info forIndexPath:(NSIndexPath *)indexPath {
	FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];

	if (!item) 
		return NO;
	
	if(item.songInfo != nil){
		[item.songInfo release];
		item.songInfo = nil;
	}
	
	item.songInfo = info;
	
	return YES;
}

#pragma mark -
#pragma mark Deferred item loading (UIScrollViewDelegate)

- (void)loadRemainingTableItems:(UIScrollView *)scrollView{
	if(recordsFinished)
		return;
	
	NSLog(@"check scrolled to end of table?");
	
	CGPoint off = scrollView.contentOffset;
	CGSize csize = scrollView.contentSize;
	CGSize fsize = dataTable.frame.size;
	
	NSInteger cpos = csize.height + dataTable.contentInset.bottom;
	
	if ((off.y+fsize.height) >= cpos && dataTable.tableFooterView == nil) {
		NSLog(@"end of tableview");
		dataTable.tableFooterView = viewTableLoading;
		
		[dataTable setContentOffset:CGPointMake(0, off.y +viewTableLoading.frame.size.height) animated:YES];
		
		//[self searchBarSearchButtonClicked:nil];
		[self searchByString:nil];
	} else {
		//tblItems.tableFooterView = nil;
	}
	
	
}


// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadRemainingTableItems:scrollView];
		[self loadSongInfoForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadRemainingTableItems:scrollView];
	[self loadSongInfoForOnscreenRows];
}


- (void) purgeSongItems {
	if (searchResults != nil) {
		for (NSObject *obj in searchResults) {
			[obj release];
			obj = nil;
		}
		
		[searchResults removeAllObjects];
		[searchResults release];
		searchResults = nil;
		
		// Release any cached data, images, etc. that aren't in use.
		// terminate all pending download connections
		NSArray *allDownloads = [self.songInfoInProgress allValues];
		[allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
		
		for (NSString *key in [self.songInfoInProgress allKeys]) {
			[self.songInfoInProgress removeObjectForKey:key];	
		}
		
		[dataTable reloadData];
	}
	
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SearchItemCell *cell = (SearchItemCell *)[dataTable cellForRowAtIndexPath:indexPath];

	if (cell.disabled) {
		//TODO: give unsupported content alert 
		cell.selected = NO;
		
		[Utility alertMessage:@"Sorry iOS cannot play this media!" message:@"You have selected unsupported flash based content that we cannot filter out from search results. Please select another item(s) from the list."];

		return;
	}
	
	FizySearchItem *item = [searchResults objectAtIndex:indexPath.row];
	
	if(item.songInfo == nil)
	{
		
		[[Utility sharedHUD] show:YES];
		
		[self startSongResolveDownload:item forIndexPath:indexPath];
	} else {
        if ([[Fizy sharedFizy].player playerStatus] == FZ_PLAYERSTATUS_STOPPED || 
            [[Fizy sharedFizy].player playerStatus] == FZ_PLAYERSTATUS_NA) {

            [[Fizy sharedFizy].player setCurrentSong:item.songInfo];
            [[Fizy sharedFizy].player showNowPlaying];	
            
            [self updateOnscreenSongCells];
        } else {
            
            FizyUnofficialAppDelegate * appDelegate =  (FizyUnofficialAppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate showSongDetail:item.songInfo];
        }
        
	}
	
}

- (IBAction) btnShowNowPlaying_touchUp:(id)sender{
	[[Fizy sharedFizy].player showNowPlaying];
}


#pragma mark -
#pragma mark Inline Search

- (void)dismissInlineSearch{
	//self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	
	//letUserSelectRow = YES;
	//isSearching = NO;
	//	self.navigationItem.rightBarButtonItem = nil;
	//self.indexTable.scrollEnabled = YES;
	//self.dataTable.scrollEnabled = YES;
	
	//[ovController.view removeFromSuperview];
	//[ovController release];
	//ovController = nil;
	
	//	searchBar.showsCancelButton = NO;
	[searchBar setShowsCancelButton:NO animated:YES];
	[self.dataTable reloadData];
	
	[searchBar setShowsScopeBar:NO];
	[searchBar sizeToFit];  

}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[self dismissInlineSearch];
	
	if (self.searchBar.text == nil) {
		self.searchBar.text = searchString;
	}
}


- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	
	//self.dataTable.scrollEnabled = NO;
	
	//[searchBar setShowsScopeBar:YES];
	
	[searchBar sizeToFit];

	NSLog(@"begin editing");
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	/*
	//Remove all objects first.
	[filteredSearchResults removeAllObjects];
	
	if([searchText length] > 0) {
		//[ovController.view removeFromSuperview];
		isSearching = YES;
		self.dataTable.scrollEnabled = YES;
		
		//[self searchTableView];
		[self filterTableView];
		
		[self.dataTable reloadData];
	}
	else {
		//[self.indexTable insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		isSearching = NO;
		self.dataTable.scrollEnabled = NO;
	}*/
	
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	//[self searchBarSearchButtonClicked:searchBar];
}

- (void)searchResponseLoaded:(NSDictionary *)response{
	[[Utility sharedHUD] hide:YES];

	[self.searchBar setShowsCancelButton:NO animated:YES];
	
	//[searchBar setShowsScopeBar:NO];
	
	[searchBar sizeToFit];
	
/*	if (searchResults != nil) {
		[searchResults release];
		searchResults = nil;
	}*/
	
	if (response != nil) {
		[searchResults addObjectsFromArray:[response objectForKey:@"results"]];
		
		//searchResults = [response objectForKey:@"results"];
		
		NSInteger totalPages = [[response objectForKey:@"totalpages"] intValue];
		
		currentPage = [[response objectForKey:@"currentpage"] intValue];
		
		if (currentPage >= totalPages+1) {
			recordsFinished = YES;
		} else {
			currentPage++;
		}
		
		
		
		
	}
	
	messageSearch.hidden = YES;
	self.dataTable.tableFooterView = nil;

	if ([searchResults count] > 0) {
		[self.dataTable reloadData];		
		
		if (self.dataTable.hidden) {
			self.dataTable.contentOffset = CGPointMake(0, -15);
		} else {
            
            CGPoint currPoint = self.dataTable.contentOffset;
            
            self.dataTable.contentOffset = CGPointMake(currPoint.x, currPoint.y + self.dataTable.rowHeight);

        }
		
		self.dataTable.hidden = NO;
		messageNoResults.hidden = YES;
	} else {
		self.dataTable.hidden = YES;
		messageNoResults.hidden = NO;
	}

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	if ([self.searchBar.text isEqualToString:@""] || self.searchBar.text == nil) {
		return;
	}
	
	[self.searchBar resignFirstResponder];
		

	if (self.searchBar != nil) {
		currentPage = 0;
		recordsFinished = NO;
		
		recordsFinished = NO;
		self.dataTable.tableFooterView = nil;
		self.dataTable.contentOffset = CGPointMake(0, 0);
		
		[self purgeSongItems];
		
		if (searchResults != nil && [searchResults count] > 0) {
			[searchResults release];
		}
		
		searchResults = [[NSMutableArray alloc] init];
		
		[self.dataTable reloadData];
	}
	
	[self searchByString:self.searchBar.text];
}

- (void) searchByString:(NSString*)keyword{

	if (keyword != nil && ![keyword isEqualToString:searchString] && ![keyword isEqualToString:@""]) {
		[searchString release];
		searchString = [[NSString alloc] initWithString:keyword];
	}
	
	[[Utility sharedHUD] show:YES];
	
	NSString *type = nil;
	
	if (btnFilterAll.selected) {
		type = @"";
	} else if (btnFilterAudio.selected) {
		type = @"audio";
	} else if (btnFilterVideo.selected) {
		type = @"video";
	}
	
	[[Fizy sharedFizy] search:searchString page:currentPage type:type quality:nil duration:nil];
}

- (IBAction) searchFilterButton_touchUp:(UIButton *)sender{
	if (sender == btnFilterAll) {
		btnFilterAudio.selected = NO;
		btnFilterVideo.selected = NO;
		btnFilterAll.selected = YES;
	} else if (sender == btnFilterAudio) {
		btnFilterAudio.selected = YES;
		btnFilterVideo.selected = NO;
		btnFilterAll.selected = NO;
	} else if (sender == btnFilterVideo) {
		btnFilterAudio.selected = NO;
		btnFilterVideo.selected = YES;
		btnFilterAll.selected = NO;
	}
	
	[self searchBarSearchButtonClicked:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	// terminate all pending download connections
    NSArray *allDownloads = [self.songInfoInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[buttons release];
	[buttonData release];
	
	[songInfoInProgress release];

    [super dealloc];
}


@end
