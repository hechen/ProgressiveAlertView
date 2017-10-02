//
// Created by He Chen on 2017/9/19.
//

#import <UIKit/UIKit.h>

/*
 *  环状 UI
 * */
@interface HCProgressAnimatedView : UIView

/// 环的半径
@property (nonatomic) CGFloat radius;

/// 环的厚度
@property (nonatomic) CGFloat strokeThickness;

/// 环的颜色
@property (nonatomic) UIColor *strokeColor;

/// 当前环末端的位置
@property (nonatomic) CGFloat strokeEnd;

@end
