//
//  LaunchViewController.m
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/3/7.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *launchView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showAnimation];
}

- (void)setData {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault dataForKey:@"LaunchImageData"]) {
        _imageView.image = [UIImage imageWithData:[userDefault dataForKey:@"LaunchImageData"]];
        _titleLab.text = [userDefault stringForKey:@"LaunchText"];
    }else {
        UIImage *image = [UIImage imageNamed:@"Splash_Image"];
        _imageView.image = image;
        [userDefault setObject:@"" forKey:@"LaunchText"];
        [userDefault setObject:@"" forKey:@"LaunchImageUrlString"];
        [userDefault setObject:UIImagePNGRepresentation(image) forKey:@"LaunchImageData"];
    }

}

- (void)showAnimation {
    
    [UIView animateWithDuration:1.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _launchView.alpha = 0.1f;
        _imageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.window.rootViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewController;
        });
        [self backgroundThreadUpdateLaunchImage];
    }];
}

- (void)backgroundThreadUpdateLaunchImage {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGFloat scale = [UIScreen mainScreen].scale;
        NSInteger imageWidth = [@(kScreenWidth * scale) integerValue];
        NSInteger imageHeight = [@(kScreenHeight * scale) integerValue];
        [NetOperation getRequestWithURL:[NSString stringWithFormat:@"prefetch-launch-images/%ld*%ld",(long)imageWidth,(long)imageHeight] parameters:nil success:^(id responseObject) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSDictionary *dicData = [responseObject[@"creatives"] firstObject];
            NSString *urlString = dicData[@"url"];
            if (!urlString && ![urlString isEqualToString:[userDefault stringForKey:@"LaunchImageUrlString"]]) {
                NSString *text = dicData[@"text"];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                [userDefault setObject:text forKey:@"LaunchText"];
                [userDefault setObject:imageData forKey:@"LaunchImageData"];
                [userDefault setObject:urlString forKey:@"LaunchImageUrlString"];
            }
        } failure:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
