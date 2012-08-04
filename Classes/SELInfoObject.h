//
//  SELInfoObject.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/14/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SELInfoObject : NSObject {
	SEL	callback;
	id context;
	NSInteger reference;
}

@property (nonatomic, assign) SEL callback;
@property (nonatomic, retain) id context;
@property (nonatomic, assign) NSInteger reference;

@end
