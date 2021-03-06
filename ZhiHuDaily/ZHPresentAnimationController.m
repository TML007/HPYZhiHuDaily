//
//  ZHPresentAnimationController.m
//  ZHTransition
//
//  Created by 洪鹏宇 on 16/8/21.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "ZHPresentAnimationController.h"

@implementation ZHPresentAnimationController

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.animationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGRect originFrame  = fromView.frame;
    toView.frame = CGRectOffset(originFrame, screenWidth , 0);
    UIView *containView = transitionContext.containerView;
    [containView addSubview:toView];
    [UIView animateWithDuration:self.animationDuration animations:^{
        toView.frame = originFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
