//
//  StoryCellViewModel.h
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/2/20.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StoryCellViewModel : NSObject

@property (strong,readonly,nonatomic)NSString *storyID;
@property (strong,nonatomic)UIImage *preImage;
@property (strong,nonatomic)UIImage *displayImage;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (void)loadDisplayImage;
- (void)relesaeInvalidObjects;

@end
