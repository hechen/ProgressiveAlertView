//
//  ViewController.m
//  ProgressAlertView
//
//  Created by He Chen on 2017/9/30.
//  Copyright © 2017 Chen. All rights reserved.
//

#import "ViewController.h"
#import <ProgressiveAlertView/HCProgressiveAlertView.h>

@interface ViewController ()

@property (nonatomic) UIButton *button;

@end

@implementation ViewController

- (void)dealloc {
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.button = ({
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 75 , self.view.bounds.size.height / 2 - 15, 150, 30)];
        b.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [b setTitle:@"Show Progress Alert..." forState:UIControlStateNormal];
        [b setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [b addTarget:self action:@selector(handleShowAlertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:b];

        b;
    });
}


#pragma mark - Action

- (void)handleShowAlertButtonClicked:(id)sender {
    if ([HCProgressiveAlertView sharedView].isVisible) {
        return;
    }

    [self beginProcessing];
}


#pragma mark - Private

- (void)beginProcessing {
    [[HCProgressiveAlertView sharedView] show];

//    [HCProgressiveAlertView sharedView].topTitle = @"Downloading...";
    [HCProgressiveAlertView sharedView].topTitle = @"粘贴自\"Chen's MacBook Pro\" ...";
    [HCProgressiveAlertView sharedView].bottomButtonText = @"取消";
    [HCProgressiveAlertView sharedView].backgroundViewClickedBlock  = ^{
#ifdef DEBUG
        NSLog(@"Alert View BackgroundView Clicked...");
#endif
    };

    __weak typeof(self) weakSelf = self;
    [HCProgressiveAlertView sharedView].bottomButtonClickedBlock = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(increaseProgress) object:nil];
        [strongSelf endProcessing];
    };

    [self unregisterNotifications];
    [self registerNotifications];
    
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
}

- (void)endProcessing {
    HCProgressiveAlertView *alertView = [HCProgressiveAlertView sharedView];

    __weak HCProgressiveAlertView *weakAlert = alertView;
    [alertView dismissWithCompletion:^{
        __strong HCProgressiveAlertView *strongAlert = weakAlert;
        strongAlert.progress = 0;
    }];
}

- (void)increaseProgress {
    CGFloat progress = [HCProgressiveAlertView sharedView].progress;
    progress += 0.05f;
    
    [HCProgressiveAlertView sharedView].progress = progress;
    
    if(progress < 1.0f){
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    } else {
        [self performSelector:@selector(endProcessing) withObject:nil afterDelay:0.4f];
    }
}


#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressAlertViewWillAppear:) name:HCPAVWillAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressAlertViewWillDisappear:) name:HCPAVWillDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressAlertViewDidDisappear:) name:HCPAVDidDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressAlertViewBackgroundViewTouchDownEvent:) name:HCPAVDidReceiveTouchEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressAlertViewCancelButtonTouchDownEvent:) name:HCPAVDidTouchDownInsideBottomButtonNotification object:nil];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HCPAVWillAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HCPAVWillDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HCPAVDidDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HCPAVDidReceiveTouchEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HCPAVDidTouchDownInsideBottomButtonNotification object:nil];
}

- (void)handleProgressAlertViewWillAppear:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"Notification Received: HCPAVWillAppearNotification");
#endif
}

- (void)handleProgressAlertViewWillDisappear:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"Notification Received: HCPAVWillDisappearNotification");
#endif
}

- (void)handleProgressAlertViewDidDisappear:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"Notification Received: HCPAVDidDisappearNotification");
#endif
}

- (void)handleProgressAlertViewBackgroundViewTouchDownEvent:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"Notification Received: HCPAVDidReceiveTouchEventNotification");
#endif
}

- (void)handleProgressAlertViewCancelButtonTouchDownEvent:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"Notification Received: HCPAVDidTouchDownInsideCancelButtonNotification");
#endif
}

@end
