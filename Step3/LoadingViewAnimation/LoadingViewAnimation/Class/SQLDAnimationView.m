//
//  SQLDAnimationView.m
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/25.
//  Copyright © 2016年 宋千. All rights reserved.
//

// TODO:“重置”功能中加入“合闭动画”删除语句。

#import "SQLDAnimationView.h"

// color
#define ANIMATION_NORMAL_COLOR      [UIColor blueColor]
#define ANIMATION_COMPLETE_COLOR    [UIColor greenColor]
#define ANIMATION_FAIL_COLOR        [UIColor redColor]

// animationName
static NSString *const kAnimationKeyOfName = @"AnimationKeyOfName";
static NSString *const kAnimationOfNameStep0 = @"AnimationOfName0";
static NSString *const kAnimationOfNameStep1 = @"AnimationOfName1";

// layerAnimationKey
static NSString *const kLayerAnimationKeyOfStep0 = @"AnimationKeyOfStep0";
static NSString *const kLayerAnimationKeyOfStep1 = @"AnimationKeyOfStep1";

// originalityLength
static CGFloat const kOriginalityLength = 100.0f;

// time
static CGFloat const kSQLDAnimationSpeed = 2.0f;
static CGFloat const kSQLDAnimationCompletedStep0During = 1.00f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep1During = 0.75f / kSQLDAnimationSpeed;

// line
static CGFloat const kSQLDOutCircleLineWidth = 30.0f;

@interface SQLDAnimationView ()

//-----------------Layer

// 外圆layer
@property (nonatomic) CAShapeLayer *circleLayer;

//-----------------Data

// 状态
@property (nonatomic) SQLDAnimationState state;

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
    self.state = SQLDAnimationStateOfNormal;
    [self animationOfALoop];
}

/**
 *  加载成功
 *
 *  @param block 成功后的回调block
 */
- (void)loadingSuccessedCompletedBlock:(void(^)(void))block {
    self.state = SQLDAnimationStateOfSuccess;
}

/**
 *  加载失败
 *
 *  @param block 失败后的回调block
 */
- (void)loadingFailedCompletedBlock:(void(^)(void))block {
    self.state = SQLDAnimationStateOfFail;
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
    [animation setValue:kAnimationOfNameStep0
                 forKey:kAnimationKeyOfName];
    [self.circleLayer addAnimation:animation
                            forKey:kLayerAnimationKeyOfStep0];
    
    // 圆环合闭
    CABasicAnimation *animationTransform = [CABasicAnimation animation];
    animationTransform.keyPath = @"transform.rotation.z";
    animationTransform.toValue = @(-M_PI);
}


#pragma mark step1
- (void)animationOfBecomeACircle {
    
    // 圆环合闭
    CABasicAnimation *animationTransform = [CABasicAnimation animation];
    animationTransform.keyPath = @"transform.rotation.z";
    animationTransform.toValue = @(-M_PI);
    
    // 圆环转动
    CABasicAnimation *animationStrokeEnd = [CABasicAnimation animation];
    animationStrokeEnd.keyPath = @"strokeEnd";
    animationStrokeEnd.toValue = @(1.0f);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep1
                      forKey:kAnimationKeyOfName];
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.duration = kSQLDAnimationCompletedStep1During;
    animationGroup.animations = @[animationStrokeEnd,animationTransform];
    
    [self.circleLayer addAnimation:animationGroup
                            forKey:kLayerAnimationKeyOfStep1];
    
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
    
    // 各部分动画结束处理
    NSString *animationName = [anim valueForKey:kAnimationKeyOfName];
    NSLog(@"\nStop Animation Key Of Name:%@",animationName);
    // step 0
    if ([animationName isEqualToString:kAnimationOfNameStep0]) {
        
        [self loadingAnimationCompleteToALoop];
    }
    
    
    if ([animationName isEqualToString:kAnimationOfNameStep1]) {
        
        
    }
    
    
    
}

/**
 *  加载动画完成了一个loop
 */
- (void)loadingAnimationCompleteToALoop {
    
    if (self.state == SQLDAnimationStateOfNormal) {
        
        [self animationOfALoop];
        
    } else {
        
        [self animationOfBecomeACircle];
    }
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 // 代码修改-----start
 // 代码修改-----end
 */

@end
