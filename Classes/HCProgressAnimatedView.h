//
// Created by He Chen on 2017/9/19.
//

#import <UIKit/UIKit.h>

/*
 *  Circle, which can show progress
 * */
@interface HCProgressAnimatedView : UIView

@property (nonatomic) CGFloat radius;

@property (nonatomic) CGFloat strokeThickness;

@property (nonatomic) UIColor *strokeColor;

/// affect the progress (0.0 ~ 1.0)
@property (nonatomic) CGFloat strokeEnd;

@end
