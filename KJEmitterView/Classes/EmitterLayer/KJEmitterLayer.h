//
//  KJEmitterLayer.h
//  KJEmitterView
//
//  Created by 杨科军 on 2019/8/27.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^KJEmitterLayerDrawCompleteBlock)(void);
@interface KJEmitterLayer : CALayer
// 初始化
+ (instancetype)createEmitterLayerWaitTime:(CGFloat)waitTime ImageBlock:(UIImage*(^)(KJEmitterLayer *obj))block CompleteBlock:(KJEmitterLayerDrawCompleteBlock)complete;
/// 重置
- (void)restart;

/// 设置一些相关的数据
@property(nonatomic,strong,readonly) KJEmitterLayer *(^KJIgnored)(BOOL ignoredBlack,BOOL ignoredWhite);
/// pixelColor:粒子颜色 pixelMaximum:粒子最大数目 pixelBeginPoint:粒子出生位置 pixelRandomPointRange:像素粒子随机范围
@property(nonatomic,strong,readonly) KJEmitterLayer *(^KJPixel)(UIColor *pixelColor,NSInteger pixelMaximum,CGPoint pixelBeginPoint,CGFloat pixelRandomPointRange);
@end

NS_ASSUME_NONNULL_END
