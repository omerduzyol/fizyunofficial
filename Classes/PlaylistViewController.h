//
//  PlaylistViewController.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSArray *playlists;
    
    IBOutlet UIView *msgNoRecords;
    IBOutlet UIView *loginContainer;
    IBOutlet UITextField *txtUserName;
    IBOutlet UITextField *txtPassword;
    
    UITextField *activeTextField;
    
    CGRect oldFrame;
    
}

@property (nonatomic, retain) IBOutlet UITableView *dataTable;

-(IBAction)btnAddClick:(id)sender;
-(IBAction)btnLoginClick:(id)sender;

- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;

@end
