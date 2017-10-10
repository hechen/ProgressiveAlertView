//
//  HCProgressiveAlertView.m
//
//  Created by hechen on 2017/9/20.
//

#import "HCProgressiveAlertView.h"
#import "HCProgressAnimatedView.h"
#import "HCCheckMarkView.h"

#import "UIColor+Extension.h"


NSString * _Nonnull const HCPAVDidReceiveTouchEventNotification = @"HCPAVDidReceiveTouchEventNotification";
NSString * _Nonnull const HCPAVDidTouchDownInsideBottomButtonNotification = @"HCPAVDidTouchDownInsideBottomButtonNotification";
NSString * _Nonnull const HCPAVWillDisappearNotification = @"HCPAVWillDisappearNotification";
NSString * _Nonnull const HCPAVDidDisappearNotification = @"HCPAVDidDisappearNotification";
NSString * _Nonnull const HCPAVWillAppearNotification = @"HCPAVWillAppearNotification";

/// margin between TitleLabel and top of HUD container.
static const CGFloat HCPAVTitleLabelTopMargin = 20.0f;
/// margin between TitleLabel and left edge or right edge of HUD container.
static const CGFloat HCPAVTitleLabelHorizonalMargin = 38.0f;
/// height of cancel button.
static const CGFloat HCPAVCancelButtonHeight = 43.f;
/// height of separator line.
static const CGFloat HCPAVSeparatorLineHeight = 0.5f;
/// padding between ring and its top object (titleLabel or HUD-top-edge)
static const CGFloat HCPAVRingViewVerticalPadding = 20.f;
/// fixed width of HUD container.
static const CGFloat HCPAVHUDWidth = 270.f;
/// completion sign frame
static const CGFloat HCPAVCompletionSignWidth = 15.f;
static const CGFloat HCPAVCompletionSignHeight = 15.f;

@interface HCProgressiveAlertView()

@property (nonatomic, readonly) UIWindow *frontWindow;

@property (nonatomic) UIControl *controlView;

@property (nonatomic) UIView *backgroundView;

@property (nonatomic) UIVisualEffectView *hudView;

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) HCProgressAnimatedView *placeholderRingView;

@property (nonatomic) HCProgressAnimatedView *ringView;

@property (nonatomic) HCCheckMarkView *completionView;

@property (nonatomic) UIView *separatorView;

@property (nonatomic) UIButton *bottomButton;

@end

@implementation HCProgressiveAlertView

#pragma mark - Public

+ (instancetype)sharedView {
    static HCProgressiveAlertView *alertView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[HCProgressiveAlertView alloc] init];
    });

    return alertView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView.alpha = 0;
        self.ringView.alpha = 0;
        self.titleLabel.alpha = 0;
        self.ringView.alpha = 0;
        self.bottomButton.alpha = 0;
        self.separatorView.alpha = 0;
        self.completionView.alpha = 0;

        // title
        _titleTextColor = [UIColor blackColor];
        _titleTextFont = [UIFont boldSystemFontOfSize:17.f];

        // Circle
        _progressBackgroundColor = [UIColor colorWithHex:@"#c7c7c7"];
        _progressForegroundColor = [UIColor colorWithHex:@"#007aff"];
        _progressCircleThickness = 3.f;
        _progressCircleRadius = 31.f;

        // Separator
        _separatorColor = [UIColor colorWithHex:@"#BFBFBF"];

        // Cancel Button
        _cancelButtonTextColor = [UIColor colorWithHex:@"#007aff"];
        _cancelButtonTextFont = [UIFont boldSystemFontOfSize:17.f];

        // Completion Sign
        _completionSignColor = [UIColor colorWithHex:@"#007aff"];
        _completionSignThickness = 3.f;

        // Animation Duration
        _fadeInAnimationDuration = 0.15;
        _fadeOutAnimationDuration = 0.15;

        //
        _alertViewCornerRadius = 14.f;
    }
    return self;
}


#pragma mark - Getter

- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = window.windowLevel >= UIWindowLevelNormal;
        BOOL windowKeyWindow = window.isKeyWindow;

        if (windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }

    return nil;
}

- (UIControl*)controlView {
    if(!_controlView) {
        _controlView = [UIControl new];
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.backgroundColor = [UIColor clearColor];
        _controlView.userInteractionEnabled = YES;
        [_controlView addTarget:self action:@selector(handleControlViewTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
    }

    // Update frames
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _controlView.frame = windowBounds;

    return _controlView;
}

- (UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [UIView new];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if(!_backgroundView.superview){
        [self insertSubview:_backgroundView belowSubview:self.hudView];
    }

    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];

    // Update frame
    if(_backgroundView){
        _backgroundView.frame = self.bounds;
    }

    return _backgroundView;
}

- (HCProgressAnimatedView *)placeholderRingView {
    if (!_placeholderRingView) {
        _placeholderRingView = [[HCProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }

    _placeholderRingView.strokeColor = self.progressBackgroundColor;
    _placeholderRingView.strokeThickness = self.progressCircleThickness;
    _placeholderRingView.radius = self.progressCircleRadius;
    _placeholderRingView.strokeEnd = 1;

    return _placeholderRingView;
}

- (HCProgressAnimatedView *)ringView {
    if (!_ringView) {
        _ringView = [[HCProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }

    _ringView.strokeColor = self.progressForegroundColor;
    _ringView.strokeThickness = self.progressCircleThickness;
    _ringView.radius = self.progressCircleRadius;

    return _ringView;
}

- (HCCheckMarkView *)completionView {
    if (!_completionView) {
        _completionView = [[HCCheckMarkView alloc] initWithFrame:CGRectZero];
    }

    _completionView.strokeColor = self.completionSignColor;
    _completionView.strokeThickness = self.completionSignThickness;

    return _completionView;
}

- (UIVisualEffectView *)hudView {
    if(!_hudView) {
        _hudView = [[UIVisualEffectView alloc] initWithFrame:CGRectZero];
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _hudView.contentView.userInteractionEnabled = YES;
    }

    if(!_hudView.superview) {
        [self addSubview:_hudView];
    }

    _hudView.layer.cornerRadius = self.alertViewCornerRadius;

    return _hudView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }

    if (!_titleLabel.superview) {
        [self.hudView.contentView addSubview:_titleLabel];
    }

    _titleLabel.textColor = self.titleTextColor;
    _titleLabel.font = self.titleTextFont;

    return _titleLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
    }

    if (!_separatorView.superview) {
        [self.hudView.contentView addSubview:_separatorView];
    }

    _separatorView.backgroundColor = self.separatorColor;

    return _separatorView;
}

- (UIButton *)bottomButton {
    if (!_bottomButton) {
        _bottomButton = [UIButton new];
        [_bottomButton setBackgroundColor:[UIColor clearColor]];
        
        // default title
        [_bottomButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [_bottomButton addTarget:self action:@selector(handleBottomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    if (!_bottomButton.superview) {
        [self.hudView.contentView addSubview:_bottomButton];
    }

    [_bottomButton setTitleColor:self.cancelButtonTextColor forState:UIControlStateNormal];
    _bottomButton.titleLabel.font = self.cancelButtonTextFont;

    return _bottomButton;
}


#pragma mark - Setter

- (void)setTopTitle:(NSString *)topTitle {
    _topTitle = topTitle;
    
    self.titleLabel.text = topTitle;
}

- (void)setBottomButtonText:(NSString *)bottomButtonText {
    _bottomButtonText = bottomButtonText;
    
    [self.bottomButton setTitle:bottomButtonText forState:UIControlStateNormal];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;

    // update progress only when view is visible.
    if (![self isVisible]) {
        return;
    }

    [self showProgress:progress];
}


- (BOOL)isVisible {
    return self.backgroundView.alpha != 0;
}

- (void)show {
    [self showProgress:0];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)())completion {
    __weak HCProgressiveAlertView *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        HCProgressiveAlertView *strongSelf = weakSelf;
        [strongSelf fadeOutWithCompletion:completion];
        [strongSelf setNeedsDisplay];
    }];

}

#pragma mark - Private

- (void)showProgress:(CGFloat)progress {
    __weak HCProgressiveAlertView *weakAlertView = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        HCProgressiveAlertView *strongSelf = weakAlertView;

        [strongSelf updateViewHierarchy];

        // 当然我们都会先传入非负数
        if (progress >= 0) {
            if (!strongSelf.placeholderRingView.superview) {
                [strongSelf.hudView.contentView addSubview:strongSelf.placeholderRingView];
            }

            if (!strongSelf.ringView.superview) {
                [strongSelf.hudView.contentView addSubview:strongSelf.ringView];
            }

            if (progress >= 1.f) {
                // show completion layer when progress reach 100%
                if (!strongSelf.completionView.superview) {
                    [strongSelf.hudView.contentView addSubview:strongSelf.completionView];
                }
            }

            [CATransaction begin];
            [CATransaction setDisableActions:YES];

            strongSelf.ringView.strokeEnd = progress;

            [CATransaction commit];
        } else {
            [strongSelf cancelRingLayerAnimation];
        }

        [strongSelf fadeIn];
    }];
}

- (void)updateViewHierarchy {
    if (!self.controlView.window) {
        [self.frontWindow addSubview:self.controlView];
    } else {
        // The HUD is already on screen, but maybe not in front. Therefore
        // ensure that overlay will be on top of rootViewController (which may
        // be changed during runtime).
        [self.controlView.superview bringSubviewToFront:self.controlView];
    }

    // Add self to the overlay view
    if (!self.superview) {
        [self.controlView addSubview:self];
    }
}

- (void)updateViewFrames {
    // Calculate size of string
    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;

    if (self.titleLabel.text.length > 0) {
        CGFloat remainSpace = HCPAVHUDWidth - 2 * HCPAVTitleLabelHorizonalMargin;
        CGSize constraintSize = CGSizeMake(remainSpace, CGFLOAT_MAX);
        labelRect = [self.titleLabel.text boundingRectWithSize:constraintSize
                                                       options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                    attributes:@{
                                                            NSFontAttributeName: self.titleLabel.font
                                                    }
                                                       context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));
    }

    CGFloat hudWidth = HCPAVHUDWidth;
    CGFloat hudHeight = HCPAVTitleLabelTopMargin + labelHeight + self.progressCircleRadius * 2 + HCPAVRingViewVerticalPadding + HCPAVSeparatorLineHeight + HCPAVCancelButtonHeight;
    if (self.titleLabel.text.length > 0) {
        hudHeight += HCPAVRingViewVerticalPadding;
    }

    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    // title label
    self.titleLabel.frame = CGRectMake((hudWidth - labelWidth) / 2.f, HCPAVTitleLabelTopMargin, labelWidth, labelHeight);

    // circle
    // edge | <-> |title | <-> | circle |
    CGFloat ringViewY = HCPAVTitleLabelTopMargin;
    if (self.topTitle.length > 0) {
        ringViewY += labelHeight;
        ringViewY += HCPAVRingViewVerticalPadding;
    }

    self.ringView.frame = CGRectMake(hudWidth / 2.f - self.ringView.radius, ringViewY, self.ringView.radius * 2, self.ringView.radius * 2);
    self.completionView.frame = CGRectMake(0, 0, HCPAVCompletionSignWidth, HCPAVCompletionSignHeight);

    // separator
    self.separatorView.frame = CGRectMake(0, hudHeight - HCPAVCancelButtonHeight - HCPAVSeparatorLineHeight, hudWidth, HCPAVSeparatorLineHeight);

    // bottom button
    self.bottomButton.frame = CGRectMake(0, hudHeight - HCPAVCancelButtonHeight, hudWidth, HCPAVCancelButtonHeight);

    [CATransaction commit];
}

- (void)positionHUD {
    self.frame = [[UIApplication sharedApplication].delegate window].bounds;
    self.hudView.center = self.backgroundView.center;
    self.placeholderRingView.center = self.ringView.center;
    self.completionView.center = self.ringView.center;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    [self.hudView.layer removeAllAnimations];
    self.ringView.strokeEnd = 0.f;

    [CATransaction commit];

    [self.ringView removeFromSuperview];
    [self.placeholderRingView removeFromSuperview];

    [self.completionView removeFromSuperview];
}


#pragma mark - Fade In && Out

- (void)fadeIn {
    [self fadeInWithCompletion:nil];
}

- (void)fadeInWithCompletion:(void(^)())completion {
    [self updateViewFrames];
    [self positionHUD];
    [self fadeInCompletionView];

    if (self.backgroundView.alpha == 1) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:HCPAVWillAppearNotification
                                                        object:self
                                                      userInfo:nil];

    // shake hud
    self.hudView.transform = self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.5f, 1/1.5f);

    __weak typeof(self)weakSelf = self;

    void (^animationBlock)() = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.hudView.transform = CGAffineTransformIdentity;
        [strongSelf fadeInEffects];
    };

    void (^completionBlock)() = ^ {
        if (completion) {
            completion();
        }
    };

    if (self.fadeInAnimationDuration <= 0) {
        animationBlock();
        completionBlock();
        return;
    }

    [UIView animateWithDuration:self.fadeInAnimationDuration
                          delay:0
                        options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:animationBlock
                     completion:^(BOOL finished) {
                         completionBlock();
                     }];
}

- (void)fadeInCompletionView {
    if (self.completionView.alpha == 1) {
        return;
    }

    if (self.fadeInAnimationDuration == 0) {
        self.completionView.alpha = 1;
        return;
    }

    [UIView animateWithDuration:self.fadeInAnimationDuration animations:^{
        self.completionView.alpha = 1;
    }];
}

- (void)fadeOutWithCompletion:(void(^)())completion {
    if (self.backgroundView.alpha == 0) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:HCPAVWillDisappearNotification
                                                        object:self
                                                      userInfo:nil];

    __weak typeof(self)weakSelf = self;

    void (^animationBlock)() = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3f, 1/1.3f);
        [strongSelf fadeOutEffects];
    };

    void (^completionBlock)() = ^ {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.backgroundView.alpha == 0) {
            for (UIView *v in @[strongSelf.controlView, strongSelf.backgroundView, strongSelf.hudView, strongSelf] ) {
                [v removeFromSuperview];
            }

            [strongSelf cancelRingLayerAnimation];

            UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
            [rootController setNeedsStatusBarAppearanceUpdate];

            [[NSNotificationCenter defaultCenter] postNotificationName:HCPAVDidDisappearNotification
                                                                object:self
                                                              userInfo:nil];

            if (completion) {
                completion();
            }
        }
    };

    if (self.fadeOutAnimationDuration <= 0) {
        animationBlock();
        completionBlock();
        return;
    }

    [UIView animateWithDuration:self.fadeOutAnimationDuration
                          delay:0
                        options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                     animations:animationBlock
                     completion:^(BOOL finished) {
                         completionBlock();
                     }];
}

- (void)fadeInEffects {
    // Add blur effect
    UIBlurEffectStyle blurEffectStyle = UIBlurEffectStyleLight;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
    self.hudView.effect = blurEffect;

    self.hudView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];

    // Fade in views
    self.backgroundView.alpha = 1.f;
    self.titleLabel.alpha = 1.f;
    self.ringView.alpha = 1.f;
    self.placeholderRingView.alpha = 1.f;
    self.bottomButton.alpha = 1;
    self.separatorView.alpha = 1;

    if (self.progress >= 1) {
        self.completionView.alpha = 1.f;
    }
}

- (void)fadeOutEffects {
    // remove blur effect
    self.hudView.effect = nil;

    // Remove background color
    self.hudView.backgroundColor = [UIColor clearColor];

    // Fade out views
    self.backgroundView.alpha = 0;
    self.titleLabel.alpha = 0;
    self.ringView.alpha = 0;
    self.placeholderRingView.alpha = 0;
    self.bottomButton.alpha = 0;
    self.separatorView.alpha = 0;
    self.completionView.alpha = 0;
}


#pragma mark - Action

- (void)handleBottomButtonClicked:(id)sender {
    if (sender != self.bottomButton) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HCPAVDidTouchDownInsideBottomButtonNotification
     object:self
     userInfo:nil];
    
    if (self.bottomButtonClickedBlock) {
        self.bottomButtonClickedBlock();
    }
}

- (void)handleControlViewTouchDownEvent:(id)sender {
    if (sender != self.controlView) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HCPAVDidReceiveTouchEventNotification
     object:self
     userInfo:nil];
    
    if (self.backgroundViewClickedBlock) {
        self.backgroundViewClickedBlock();
    }
}

@end
