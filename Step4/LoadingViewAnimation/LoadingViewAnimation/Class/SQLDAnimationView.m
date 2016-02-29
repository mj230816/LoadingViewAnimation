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
static NSString *const kAnimationOfNameStep2 = @"AnimationOfName2";

// layerAnimationKey
static NSString *const kLayerAnimationKeyOfStep0 = @"AnimationKeyOfStep0";
static NSString *const kLayerAnimationKeyOfStep1 = @"AnimationKeyOfStep1";
static NSString *const kLayerAnimationKeyOfStep2 = @"AnimationKeyOfStep2";

// originalityLength
static CGFloat const kOriginalityLength = 100.0f;

// time
static CGFloat const kSQLDAnimationSpeed = 2.0f;
static CGFloat const kSQLDAnimationCompletedStep0During = 1.00f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep1During = 0.75f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep2During = 0.45f / kSQLDAnimationSpeed;

// line
static CGFloat const kSQLDOutCircleLineWidth = 30.0f;

@interface SQLDAnimationView ()

//-----------------Layer

// 外圆layer
@property (nonatomic) CAShapeLayer *circleLayer;
// 抛物线layer
@property (nonatomic) CAShapeLayer *parabolaLayer;

//-----------------Data

// 状态
@property (nonatomic) SQLDAnimationState state;

@end

@implementation SQLDAnimationView

- (void)dealloc {
    [SQLDAnimationView removeLayerFormSuperLayer:self.circleLayer];
    [SQLDAnimationView removeLayerFormSuperLayer:self.parabolaLayer];
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
    [self resetSelf];
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
    [self resetSelf];
}

/**
 *  重置状态
 */
- (void)resetSelf {
    
    // 重置状态
    self.state = SQLDAnimationStateOfNormal;
    
    // 移除所有layer
    [SQLDAnimationView removeLayerFormSuperLayer:_circleLayer];
    [SQLDAnimationView removeLayerFormSuperLayer:_parabolaLayer];
    
    // 初始化circleLayer
    if (![self.layer.sublayers containsObject:self.circleLayer]) {
        [self.layer addSublayer:self.circleLayer];
    }
    
    UIBezierPath *oval = [UIBezierPath bezierPath];
    [oval moveToPoint:CGPointMake(0, 32.075)];
    // 动画初始 -》 动画完成
    // 第三区间 -》 第一区间
    [oval addCurveToPoint:CGPointMake(32.093, 64.149)
            controlPoint1:CGPointMake(-0, 49.789)
            controlPoint2:CGPointMake(14.369, 64.149)];
    // 第四区间 -》第二区间
    [oval addCurveToPoint:CGPointMake(64.186, 32.075)
            controlPoint1:CGPointMake(49.818, 64.149)
            controlPoint2:CGPointMake(64.186, 49.789)];
    // 第一区间 -》第三区间
    [oval addCurveToPoint:CGPointMake(32.093, 0)
            controlPoint1:CGPointMake(64.186, 14.36)
            controlPoint2:CGPointMake(49.818, -0)];
    // 第二区间 -》第四区间
    [oval addCurveToPoint:CGPointMake(0, 32.075)
            controlPoint1:CGPointMake(14.369, -0)
            controlPoint2:CGPointMake(-0, 14.36)];
    
    [self zoomPath:oval];
    self.circleLayer.lineWidth = kSQLDOutCircleLineWidth;
    self.circleLayer.path = oval.CGPath;
    self.circleLayer.strokeStart = 0.125f * 0;
    self.circleLayer.strokeEnd = 0.125f * 1;
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

/**
 *  移除layer上的动画，并且将其从父layer上移除
 *
 *  @param layer 需要移除的layer
 */
+ (void)removeLayerFormSuperLayer:(CALayer *)layer {
    
    [layer removeAllAnimations];
    [layer removeFromSuperlayer];
    layer = nil;
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

#pragma mark stpe2
- (void)animationOfParabola {
    
    // 配置parabolaLayer
    if (![self.layer.sublayers containsObject:self.parabolaLayer]) {
        [self.layer addSublayer:self.parabolaLayer];
    }
    
    UIBezierPath *parabola = [UIBezierPath bezierPath];
    [parabola moveToPoint:CGPointMake(32.29, 67.614)];
    [parabola addCurveToPoint:CGPointMake(15.529, 8.396)
                controlPoint1:CGPointMake(32.29, 42.092)
                controlPoint2:CGPointMake(25.519, 19.877)];
    [parabola addCurveToPoint:CGPointMake(0, 0.088)
                controlPoint1:CGPointMake(10.922, 3.1)
                controlPoint2:CGPointMake(5.629, 0.088)];
    
    
    
    [self zoomPath:parabola];
    
    self.parabolaLayer.lineWidth = kSQLDOutCircleLineWidth;
    self.parabolaLayer.path = parabola.CGPath;
    self.parabolaLayer.strokeStart = 0.125f * 0;
    self.parabolaLayer.strokeEnd = 0.125f * 1;
    
    // animation
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation
                                              animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.toValue = @(1.0 - 0.03125);
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation
                                            animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.toValue = @(1.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[strokeEndAnimation, strokeStartAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction
                                     functionWithControlPoints:0.3 :1
                                     :0.3 :1];
    animationGroup.duration = kSQLDAnimationCompletedStep2During;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep2
                      forKey:kAnimationKeyOfName];
    [self.parabolaLayer addAnimation:animationGroup
                              forKey:kLayerAnimationKeyOfStep2];
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

/**
 *  按照现在bounds缩放layer
 */
- (void)zoomFrameWithLayer:(CALayer *)layer {
    
    // 缩放比例
    CGFloat zoomScale = [self zoomScale];
    
    CGRect otherFrame = CGRectMake(CGRectGetMinX(layer.frame) * zoomScale,
                                   CGRectGetMinY(layer.frame) * zoomScale,
                                   CGRectGetWidth(layer.frame) * zoomScale,
                                   CGRectGetHeight(layer.frame) * zoomScale);
    
    layer.frame = otherFrame;
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
    
    // step1
    if ([animationName isEqualToString:kAnimationOfNameStep1]) {
        
        [self loadingAnimationCompletedToParabola];
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

/**
 *  完成step1 -》 step2
 */
- (void)loadingAnimationCompletedToParabola {
    
    

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.circleLayer.strokeStart = 0.0f;
    self.circleLayer.strokeEnd = 1.0f;
    [CATransaction commit];
    
    [self animationOfParabola];
}

#pragma mark - getter
- (CAShapeLayer *)circleLayer {
    
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = CGRectMake(18.0f, 35.0f,
                                        64.0, 64.0f);
        _circleLayer.contentsScale = [UIScreen mainScreen].scale;
        _circleLayer.strokeColor = ANIMATION_NORMAL_COLOR.CGColor;
        
        UIColor *backgroundColor;
        backgroundColor = [UIColor clearColor];
        if (self.selfBackgroundColor) {
            backgroundColor = self.selfBackgroundColor;
        }
        _circleLayer.fillColor = backgroundColor.CGColor;
        [self zoomFrameWithLayer:_circleLayer];
    }
    
    return _circleLayer;
}

- (CAShapeLayer *)parabolaLayer {
    
    if (!_parabolaLayer) {
        _parabolaLayer = [CAShapeLayer layer];
        _parabolaLayer.frame = CGRectMake(50.0f, 0.0f,
                                          32.0, 68.0f);
        _parabolaLayer.contentsScale = [UIScreen mainScreen].scale;
        _parabolaLayer.strokeColor = ANIMATION_NORMAL_COLOR.CGColor;
        _parabolaLayer.fillColor = [UIColor clearColor].CGColor;
        [self zoomFrameWithLayer:_parabolaLayer];
        
    }
    
    return _parabolaLayer;
    
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
