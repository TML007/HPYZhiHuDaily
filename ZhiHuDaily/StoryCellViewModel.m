//
//  StoryCellViewModel.m
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/2/20.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "StoryCellViewModel.h"
#import "StoryModel.h"

static const CGFloat kMainTableViewRowHeight = 95.f;
static const CGFloat kSpacing = 18.f;
static const CGFloat kNormalImageW = 75.f;
static const CGFloat kNormalImageH = 75.f;

@interface StoryCellViewModel()

@property (strong,nonatomic)NSAttributedString *title;
@property (strong,nonatomic)StoryModel *story;
@property (assign,readonly,nonatomic)CGRect titleLabFrame;
@property (assign,readonly,nonatomic)CGRect imageViewFrame;

@end

@implementation StoryCellViewModel 

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _story = [[StoryModel alloc] initWithDictionary:dic error:nil];
        _storyID = _story.storyID;
    }
    return self;
}



- (NSAttributedString *)title {
    
    if (!_title) {
        _title = [[NSAttributedString alloc] initWithString:_story.title attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15],NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    
    return _title;
}

- (UIImage *)preImage {
    if (!_preImage) {
        UIImage* image;
        image = [UIImage imageNamed:@"Image_Preview"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScreenWidth, kMainTableViewRowHeight), NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextAddRect(context, CGRectMake(kSpacing, kSpacing, kScreenWidth-kSpacing*2, kMainTableViewRowHeight-kSpacing*2));
        CGContextClip(context);
        if (_story.images.count>0) {
            [image drawInRect:self.imageViewFrame];
        }
        [self.title drawInRect:self.titleLabFrame];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _preImage = image;
    }
    
    return _preImage;
}

- (void)loadDisplayImage {
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.story.images[0]]]];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScreenWidth, kMainTableViewRowHeight), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(kSpacing, kSpacing, kScreenWidth-kSpacing*2, kMainTableViewRowHeight-kSpacing*2));
    CGContextClip(context);
    [self.preImage drawInRect:CGRectMake(0, 0, kScreenWidth, kMainTableViewRowHeight)];
    [image drawInRect:self.imageViewFrame];
    if (self.story.multipic) {
        UIImage *warnImage = [UIImage imageNamed:@"Home_Morepic"];
        [warnImage drawInRect:CGRectMake(kScreenWidth-warnImage.size.width-kSpacing, kMainTableViewRowHeight-kSpacing-warnImage.size.height, warnImage.size.width, warnImage.size.height)];
    }
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.displayImage = image;
    //self.story = nil;
}

- (CGRect)imageViewFrame {
    return _story.images.count>0?CGRectMake(kScreenWidth-kNormalImageW-kSpacing, 10.f, kNormalImageH, kNormalImageW):CGRectZero;
}

- (CGRect)titleLabFrame {
    CGRect frame;
    CGFloat width = CGRectEqualToRect(self.imageViewFrame, CGRectZero) ? (kScreenWidth - kSpacing*2) : (kScreenWidth - kSpacing*3 - kNormalImageW);
    CGFloat height = [self.title boundingRectWithSize:CGSizeMake(width, kMainTableViewRowHeight - kSpacing*2) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    frame = CGRectMake(kSpacing, kSpacing, width, height);
    return frame;

}

@end
