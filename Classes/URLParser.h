//
//  URLParser.h
//  FizyUnofficial
//
//  Created by Ömer Düzyol on 5/16/11.
//  Copyright 2011 Creaworks Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLParser : NSObject {
	NSDictionary *parameters;
}

@property (nonatomic, retain) NSDictionary *parameters;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForParameter:(NSString *)varName;

@end
