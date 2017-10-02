//
// Created by He Chen on 2017/10/2.
//

#import "HCCheckMarkView.h"

@interface HCCheckMarkView()

@property (nonatomic) CAShapeLayer *innerLayer;

@end

@implementation HCCheckMarkView


#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _strokeColor = [UIColor blueColor];
        _strokeThickness = 3;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_innerLayer removeFromSuperlayer];
        _innerLayer = nil;
    }
}


#pragma mark - Getter

- (CAShapeLayer *)innerLayer {
    if (!_innerLayer) {
        UIBezierPath* bezierPath = [self checkMarkPath];

        _innerLayer = [CAShapeLayer layer];
        _innerLayer.path = bezierPath.CGPath;
        _innerLayer.strokeColor = self.strokeColor.CGColor;
        _innerLayer.lineWidth = self.strokeThickness;
        _innerLayer.lineCap = kCALineCapRound;
        _innerLayer.lineJoin = kCALineJoinRound;
        _innerLayer.fillColor = nil;
    }

    return _innerLayer;
}


#pragma mark - Setter

- (void)setFrame:(CGRect)frame {
    if(!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];

        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if (_strokeColor == strokeColor) {
        return;
    }

    _strokeColor = strokeColor;
    self.innerLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    if (_strokeThickness == strokeThickness) {
        return;
    }

    _strokeThickness = strokeThickness;
    self.innerLayer.lineWidth = strokeThickness;
}


#pragma mark - Private

- (void)layoutAnimatedLayer {
    // we need redraw the layer path in case the frame of current view has changed.
    UIBezierPath *bezierPath = [self checkMarkPath];

    self.innerLayer.path = bezierPath.CGPath;

    CALayer *layer = self.innerLayer;
    [self.layer addSublayer:layer];
}


#pragma mark - Helpers

- (UIBezierPath *)checkMarkPath {
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];

    // first point: At the middle of the left edge.
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 2.f)];
    // line to second point: 1 / 3 of the bottom edge.
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(self.frame) + self.frame.size.width * 1.f / 3.f, CGRectGetMaxY(self.frame))];
    // then, line to third point: right-top corner.
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame))];

    return bezierPath;
}

@end
