//
//  SearchItemCell.m
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/19/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import "SearchItemCell.h"
#import "SideSwipeTableViewCell.h"

@implementation SearchItemCell
@synthesize disabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		disabler = [[UIView alloc] init];
		disabler.backgroundColor = [UIColor grayColor];
		disabler.alpha = 0.6;
		disabler.hidden = YES;
		[self addSubview:disabler];
	
		viewNormalImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-tablerow-normal.png"]];
		viewSelectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-tablerow-selected.png"]];
		viewDisabledImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-tablerow-disabled.png"]];
		
		[self setSelectedBackgroundView:viewSelectedImage];
		[self setBackgroundView:viewNormalImage];
		
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	disabler.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	
}

-(void)setDisabled:(BOOL)value{
	disabled = value;	
	
	disabler.hidden = !value;
	
	if(value){
		[self setBackgroundView:viewDisabledImage];
	} else {
		[self setBackgroundView:viewNormalImage];
	}

	//self.backgroundView = 
}



@end
