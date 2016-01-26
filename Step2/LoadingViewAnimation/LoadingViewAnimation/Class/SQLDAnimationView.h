//
//  SQLDAnimationView.h
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/25.
//  Copyright © 2016年 宋千. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQLDAnimationView : UIView

/**
 *  推荐配置非透明值
 *  默认值是clearColor，如果设定背景颜色将有助于动画更加流畅
 *  以及减少所占用的内存
 */
@property (nonatomic) UIColor *selfBackgroundColor;

/**
 *  正在加载
 *  在loading状态下再次调用-loading，则从开始状态加载
 */
- (void)loading;

/**
 *  加载成功
 *
 *  @param block 成功动画完成后的回调block
 */
- (void)loadingSuccessedCompletedBlock:(void(^)(void))block;

/**
 *  加载失败
 *
 *  @param block 失败动画完成后的回调block
 */
- (void)loadingFailedCompletedBlock:(void(^)(void))block;

@end
