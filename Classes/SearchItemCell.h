//
//  SearchItemCell.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/19/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SideSwipeTableViewCell.h"


@interface SearchItemCell : SideSwipeTableViewCell {
	BOOL disabled;
	UIView *disabler;
	
	UIImageView *viewSelectedImage;
	UIImageView *viewDisabledImage;
	UIImageView *viewNormalImage;
}

@property (nonatomic,assign) BOOL disabled;

@end
