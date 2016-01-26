//
//  SQLDAnimationView.m
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/25.
//  Copyright © 2016年 宋千. All rights reserved.
//

#import "SQLDAnimationView.h"

// color
#define ANIMATION_NORMAL_COLOR      [UIColor blueColor]
#define ANIMATION_COMPLETE_COLOR    [UIColor greenColor]
#define ANIMATION_FAIL_COLOR        [UIColor redColor]

// originalityLength
static CGFloat const kOriginalityLength = 100.0f;

// time
static CGFloat const kSQLDAnimationSpeed = 2.0f;
static CGFloat const kSQLDAnimationCompletedStep0During = 1.00f / kSQLDAnimationSpeed;

// line
static CGFloat const kSQLDOutCircleLineWidth = 30.0f;

@interface SQLDAnimationView ()

//-----------------Layer

// 外圆layer
@property (nonatomic) CAShapeLayer *circleLayer;

@end

@implementation SQLDAnimationView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initSelf];
        
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self initSelf];
    }
    
    return self;
}

#pragma mark - public method

/**
 *  正在加载
 */
- (void)loading {
    [self animationOfALoop];
}

/**
 *  加载成功
 *
 *  @param block 成功后的回调block
 */
- (void)loadingSuccessedCompletedBlock:(void(^)(void))block {
    
}

/**
 *  加载失败
 *
 *  @param block 失败后的回调block
 */
- (void)loadingFailedCompletedBlock:(void(^)(void))block {
    
}

#pragma mark - private method

- (void)initSelf {
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            MIN(self.frame.size.width, self.frame.size.height),
                            MIN(self.frame.size.width, self.frame.size.height));
    [self.layer addSublayer:self.circleLayer];
}

- (void)animationOfALoop {
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    animation.toValue = @(-M_PI * 2);
    animation.duration = kSQLDAnimationCompletedStep0During;
    animation.delegate = self;
    [self.circleLayer addAnimation:animation
                            forKey:nil];
}

#pragma mark - 缩放处理
/**
 *  缩放比例
 */
- (CGFloat)zoomScale {
    
    CGFloat currentLength = MIN(CGRectGetWidth(self.bounds),
                                CGRectGetHeight(self.bounds));
    // 不考虑线段宽度
    CGFloat zoomScale = (currentLength / kOriginalityLength);
    return zoomScale;
    
}

/**
 *  按照现在bounds缩放path
 */
- (void)zoomPath:(UIBezierPath *)path {
    
    // path缩放比例
    CGFloat applyTransformScale = [self zoomScale];
    
    // 缩放path
    [path applyTransform:CGAffineTransformMakeScale(applyTransformScale,
                                                    applyTransformScale)];
}

- (void)zoomFrameWithLayer:(CALayer *)layer {
    
    // 缩放比例
    CGFloat zoomScale = [self zoomScale];
    
    CGRect otherFrame = CGRectMake(CGRectGetMinX(layer.frame) * zoomScale,
                                   CGRectGetMinY(layer.frame) * zoomScale,
                                   CGRectGetWidth(layer.frame) * zoomScale,
                                   CGRectGetHeight(layer.frame) * zoomScale);
    
    layer.frame = otherFrame;
}

#pragma mark - getter
- (CAShapeLayer *)circleLayer {
    
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = CGRectMake(18.0f, 35.0f,
                                        64.0, 64.0f);
        _circleLayer.contentsScale = [UIScreen mainScreen].scale;
        _circleLayer.strokeColor = ANIMATION_NORMAL_COLOR.CGColor;
        _circleLayer.lineWidth = kSQLDOutCircleLineWidth;
        
        
        UIBezierPath *oval = [UIBezierPath bezierPath];
        [oval moveToPoint:CGPointMake(0, 32.075)];
        [oval addCurveToPoint:CGPointMake(32.093, 64.149)
                controlPoint1:CGPointMake(-0, 49.789)
                controlPoint2:CGPointMake(14.369, 64.149)];
        [oval addCurveToPoint:CGPointMake(64.186, 32.075)
                controlPoint1:CGPointMake(49.818, 64.149)
                controlPoint2:CGPointMake(64.186, 49.789)];
        [oval addCurveToPoint:CGPointMake(32.093, 0)
                controlPoint1:CGPointMake(64.186, 14.36)
                controlPoint2:CGPointMake(49.818, -0)];
        [oval addCurveToPoint:CGPointMake(0, 32.075)
                controlPoint1:CGPointMake(14.369, -0)
                controlPoint2:CGPointMake(-0, 14.36)];
        
        [self zoomPath:oval];
        _circleLayer.path = oval.CGPath;
        UIColor *backgroundColor;
        backgroundColor = [UIColor clearColor];
        if (self.selfBackgroundColor) {
            backgroundColor = self.selfBackgroundColor;
        }
        _circleLayer.fillColor = backgroundColor.CGColor;
        _circleLayer.strokeStart = 0.0f;
        _circleLayer.strokeEnd = 0.125f;
        [self zoomFrameWithLayer:_circleLayer];
    }
    
    return _circleLayer;
}

#pragma mark - CAAniamtionDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self animationOfALoop];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
  // 新添加的代码-----start
  // 新添加的代码-----end
*/

@end
