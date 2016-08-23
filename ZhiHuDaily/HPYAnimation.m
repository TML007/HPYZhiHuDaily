//
//  HPYAnimation.m
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/3/1.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "HPYAnimation.h"

@implementation HPYAnimation


- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.animationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    CGRect originalFrame = fromView.frame;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    if (_presenting) {
        toView.frame = CGRectOffset(originalFrame, screenBounds.size.width, 0);
        [containerView addSubview:toView];
    }else {
        toView.frame = originalFrame;
        [containerView insertSubview:toView belowSubview:fromView];
    }
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (_presenting) {
            toView.frame = originalFrame;
        }else {
            fromView.frame = CGRectOffset(originalFrame, screenBounds.size.width, 0);
        }
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


@end
