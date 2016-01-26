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
    self.circleLayer.backgroundColor = [UIColor redColor].CGColor;
    
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


- (void)zoomFrameWithLayer:(CALayer *)layer {
    
    // 缩放比例
    CGFloat zoomScale = [self zoomScale];
    
    CGRect otherFrame = CGRectMake(CGRectGetMinX(layer.frame) * zoomScale,
                                   CGRectGetMinY(layer.frame) * zoomScale,
                                   CGRectGetWidth(layer.frame) * zoomScale,
                                   CGRectGetHeight(layer.frame) * zoomScale);
    
//    // 已经缩放过了
//    if (CGRectContainsRect(layer.frame, otherFrame)) {
//        return;
//    }
    
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

        [self zoomFrameWithLayer:_circleLayer];
    }
    
    return _circleLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
