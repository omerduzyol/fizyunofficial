//
//  DominosAlertView.h
//  DominosAciktik
//
//  Created by Ömer Düzyol on 1/15/11.
//  Copyright 2011 MagiClick Digital Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UICustomAlertView : UIAlertView {
	UIColor *fillColor;
	UIColor *borderColor;	
}


//+ (void) setBackgroundColor:(UIColor *) background  withStrokeColor:(UIColor *) stroke;

- (void) drawRoundedRect:(CGRect) rrect inContext:(CGContextRef) context withRadius:(CGFloat) radius;

- (id)initWithTitle:(NSString *)title message:(NSString *)message 
	backgroundColor:(UIColor *) background  
		strokeColor:(UIColor *) stroke
		   delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
