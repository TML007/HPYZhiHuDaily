//
//  CarouselView.m
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/2/24.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "CarouselView.h"
#import "StoryCellViewModel.h"
#import "DetailHeaderView.h"
#import "TopStoryCollectionViewCell.h"


@interface CarouselView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(strong,nonatomic)NSTimer *timer;
@property (strong,nonatomic)UIPageControl *pageControl;
@property (strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)NSMutableDictionary *imageCached;

@end

@implementation CarouselView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageCached = @{}.mutableCopy;
        [self initSubViews];
        [self addObserver:self forKeyPath:@"displayHeight" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"displayHeight"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"displayHeight"]) {

        NSArray *visiblecells = [_collectionView visibleCells];
        if (visiblecells.count>0) {
            TopStoryCollectionViewCell *cell = [visiblecells firstObject];
            cell.coverHeightConstraint.constant = _displayHeight;
            [_pageControl mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-(self.width-_displayHeight)/2);
            }];
            [super updateConstraints];
        }

    }
}

- (void)initSubViews{
    
    self.collectionView = ({
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.itemSize = CGSizeMake(self.width,self.height);
        flowlayout.minimumInteritemSpacing = 0.f;
        flowlayout.minimumLineSpacing = 0.f;
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, self.height) collectionViewLayout:flowlayout];
        view.backgroundColor = [UIColor grayColor];
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.pagingEnabled = true;
        view.delegate = self;
        view.dataSource = self;
        [self addSubview:view];
        [view registerNib:[UINib nibWithNibName:@"TopStoryCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TopStory"];
        view;
    });
    
    self.pageControl = ({
        UIPageControl *pc = [UIPageControl new];
        [self addSubview:pc];
        [pc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-(self.width-220)/2);
        }];
        pc.pageIndicatorTintColor = [UIColor grayColor];
        pc.currentPageIndicatorTintColor = [UIColor whiteColor];
        pc;
    });
}

- (void)reloadDataWithStories:(NSArray *)stories {
    if (stories.count>0) {
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:stories];
        [tmp insertObject:[stories lastObject] atIndex:0];
        [tmp addObject:[stories firstObject]];
        self.items = tmp;
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.pageControl.numberOfPages = stories.count;
        self.pageControl.currentPage = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(nextItem) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}



- (void)nextItem {
    int currentItem = self.collectionView.contentOffset.x/self.bounds.size.width;
    currentItem ++;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentItem inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TopStory";
    TopStoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *story = self.items[indexPath.item];
    cell.titleLab.attributedText = [[NSAttributedString alloc] initWithString:story[@"title"]  attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:21],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *imageUrlString = story[@"image"];
    UIImage *image = _imageCached[imageUrlString];
    if (!image) {
        image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
        [_imageCached setObject:image forKey:imageUrlString];
    }
    cell.imageView.image = image;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tap) {
        self.tap(indexPath);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.x <= self.bounds.size.width/4) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(self.items.count-2) inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    else if(scrollView.contentOffset.x >= (self.items.count-5/4)*self.bounds.size.width){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    _pageControl.currentPage = scrollView.contentOffset.x/self.bounds.size.width - 1;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.f]];
}


@end
