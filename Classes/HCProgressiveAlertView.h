//
//  HCProgressiveAlertView.h
//
//  Created by hechen on 2017/9/20.
//

#import <UIKit/UIKit.h>

extern NSString * _Nonnull const HCPAVDidReceiveTouchEventNotification;
extern NSString * _Nonnull const HCPAVDidTouchDownInsideBottomButtonNotification;
extern NSString * _Nonnull const HCPAVWillDisappearNotification;
extern NSString * _Nonnull const HCPAVDidDisappearNotification;
extern NSString * _Nonnull const HCPAVWillAppearNotification;

NS_ASSUME_NONNULL_BEGIN

/**
 
 */
@interface HCProgressiveAlertView : UIView

// ------------------------------------------------
// Appearance

// default is bold 17pt
@property (nonatomic) UIFont *titleTextFont;

// default is Black Color
@property (nonatomic) UIColor *titleTextColor;

// default is #007aff
@property (nonatomic) UIColor *progressForegroundColor;

// default is #c7c7c7
@property (nonatomic) UIColor *progressBackgroundColor;

// default is #BFBFBF
@property (nonatomic) UIColor *separatorColor;

// default is #007aff
@property (nonatomic) UIColor *cancelButtonTextColor;

// default is bold 17pt
@property (nonatomic) UIFont *cancelButtonTextFont;

// default is 0.15
@property (nonatomic) NSTimeInterval fadeInAnimationDuration;

// default is 0.15
@property (nonatomic) NSTimeInterval fadeOutAnimationDuration;

// default is 31
@property (nonatomic) CGFloat progressCircleRadius;

// default is 3
@property (nonatomic) CGFloat progressCircleThickness;

// default is 14
@property (nonatomic) CGFloat alertViewCornerRadius;

// default is 3
@property (nonatomic) CGFloat completionSignThickness;

// default is #007aff
@property (nonatomic) UIColor *completionSignColor;


// --------------------------------------------------
// Parameters for business logic

@property (nonatomic) NSString *topTitle;

@property (nonatomic) NSString *bottomButtonText;

@property (nonatomic) CGFloat progress;

@property (nonatomic, copy) void(^bottomButtonClickedBlock)(void);

@property (nonatomic, copy) void(^backgroundViewClickedBlock)(void);


// --------------------------------------------------
// Public Methods

+ (instancetype)sharedView;

- (BOOL)isVisible;

- (void)show;

- (void)dismiss;

- (void)dismissWithCompletion:(nullable void(^)())completion;

@end

NS_ASSUME_NONNULL_END
