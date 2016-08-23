//
//  HomeViewController.m
//  ZhiHuDaily
//
//  Created by 洪鹏宇 on 16/2/1.
//  Copyright © 2016年 洪鹏宇. All rights reserved.
//

#import "HomeViewController.h"
#import "HomePageViewModel.h"
#import "UITableView+Extension.h"
#import "CarouselView.h"
#import "CounterfeitNavBarView.h"
#import "SectionTitleView.h"
#import "DetailStoryViewController.h"
#import "RefreshView.h"

static const CGFloat kMainTableViewRowHeight = 95.f;
static const CGFloat kSectionHeaderHeight = 36.f;
static const CGFloat kNavigationBarHeight = 56.f;



@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic)UIScrollView *mainScrollView;

@property (strong,nonatomic)CarouselView *carouseView;
@property (strong,nonatomic)CounterfeitNavBarView *navBarView;
@property (strong,nonatomic)RefreshView *refreshView;
@property (strong,nonatomic)UITableView *mainTableView;
@property (strong,nonatomic)HomePageViewModel *viewModel;

@end

@implementation HomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewModel = [HomePageViewModel new];
        [self.viewModel getLatestStories];
    }
    return self;
}

- (void)configAllObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainScrollViewToTop:) name:@"TapStatusBar" object:nil];
    [self.viewModel addObserver:self forKeyPath:@"sectionViewModels" options:NSKeyValueObservingOptionNew context:nil];
    [self.viewModel addObserver:self forKeyPath:@"top_stories" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeAllObservers {
    [self.viewModel removeObserver:self forKeyPath:@"sectionViewModels"];
    [self.viewModel removeObserver:self forKeyPath:@"top_stories"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   
    if ([object isEqual:self.viewModel]) {
        [_refreshView stopAnimation];
        if ([keyPath isEqualToString:@"sectionViewModels"]) {
            NSUInteger kind = [change[NSKeyValueChangeKindKey] integerValue];
            switch (kind) {
                case NSKeyValueChangeSetting:
                    [_mainTableView reloadData];
                    break;
                case NSKeyValueChangeInsertion:
                    [_mainTableView insertSections:[NSIndexSet indexSetWithIndex:self.viewModel.sectionViewModels.count-1] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                case NSKeyValueChangeReplacement:
                    [_mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    break;
            }
        }
        if ([keyPath isEqualToString:@"top_stories"]) {
            [self.carouseView reloadDataWithStories:self.viewModel.top_stories];
        }
        [_refreshView stopAnimation];
    }

}

- (void)dealloc {
    [self removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
    [self configAllObservers];
}

- (void)initSubViews{
    _mainScrollView = ({
        UIScrollView *view = [UIScrollView new];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.bottom.equalTo(self.view);
        }];
        view.clipsToBounds = NO;
        view;
    });
    
    _mainTableView = ({
        UITableView *view = [UITableView new];
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.and.bottom.equalTo(self.view);
        }];
        view.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200.f)];
        [view setDisableTableHeaderView:YES];
        view.showsVerticalScrollIndicator= NO;
        view.dataSource = self;
        view.delegate = self;
        view.rowHeight = kMainTableViewRowHeight;
        [view registerClass:[UITableViewCell class] forCellReuseIdentifier:@"story"];
        [view registerClass:[SectionTitleView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([SectionTitleView class])];
        view;
    });
    
    _carouseView = ({
        CarouselView *view = [[CarouselView alloc] initWithFrame:CGRectMake(0.f, -((kScreenWidth-220.f)/2+20.f), kScreenWidth, kScreenWidth)];
        [self.mainScrollView addSubview:view];
        [view reloadDataWithStories:self.viewModel.top_stories];
        view.displayHeight = 220.f;
        view.tap = ^(NSIndexPath *indexPath){
            NSString *storyID = _carouseView.items[indexPath.item][@"id"];
            DetailStoryViewModel *dvm = [[DetailStoryViewModel alloc] initWithStoryID:storyID];
            dvm.allStoriesID = self.viewModel.allStoriesID;
            DetailStoryViewController *detailVC = [[DetailStoryViewController alloc] initWithViewModel:dvm];
            MainViewController *mainVC = (MainViewController *)self.view.window.rootViewController;
            [mainVC.interaction attachToViewController:detailVC];
            detailVC.transitioningDelegate = mainVC;
            [mainVC presentViewController:detailVC animated:YES completion:nil];
        };
        view;
    });
    
    _navBarView = ({
        CounterfeitNavBarView *view = [CounterfeitNavBarView new];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.and.right.equalTo(self.view);
            make.height.mas_equalTo(kNavigationBarHeight);
        }];
        
        view.titleLab.attributedText = [[NSAttributedString alloc] initWithString:@"今日新闻" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [view.leftBtn setImage:[UIImage imageNamed:@"Home_Icon"] forState:UIControlStateNormal];
        [view.leftBtn setImage:[UIImage imageNamed:@"Home_Icon_Highlight"] forState:UIControlStateHighlighted];
        view.leftBtnTapAction = ^(){
            MainViewController *mainVC = (MainViewController *)self.view.window.rootViewController;
            [mainVC showMenuView];
        };
        view;
    });

}

//- (void)viewDidLayoutSubviews {
//    CGFloat titleOriginY = _navBarView.titleLab.top;
//    CGFloat titleOriginX = _navBarView.titleLab.left;
//    RefreshView *rv = [[RefreshView alloc] initWithFrame:CGRectMake(titleOriginX-25, titleOriginY, 20, 20)];
//    [self.view addSubview:rv];
//    _refreshView = rv;
//}
//
- (void)mainScrollViewToTop:(NSNotification *)noti {
    [_mainTableView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateContentOfScreenVisibleRows {
    NSArray *indexPaths = [_mainTableView indexPathsForVisibleRows];
    for(NSIndexPath *indexPath in indexPaths){
        UITableViewCell *cell = [_mainTableView cellForRowAtIndexPath:indexPath];
        StoryCellViewModel *vm = [_viewModel cellViewModelAtIndexPath:indexPath];
        if (!vm.displayImage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [vm loadDisplayImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.contentView.layer.contents = (__bridge id _Nullable)(vm.displayImage.CGImage);
                });
            });
        }
    }
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateContentOfScreenVisibleRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateContentOfScreenVisibleRows];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetY = scrollView.contentOffset.y;
    
    if (offSetY<=0.f&&offSetY>= -80.f) {
        _mainScrollView.contentOffset = CGPointMake(0, offSetY/2);
        _carouseView.displayHeight = 220.f - offSetY;
    }else if (offSetY<-80.f) {
        [_mainTableView setContentOffset:CGPointMake(0, -80.f)];
    }else if (offSetY>0&&offSetY<220.f) {
        _mainScrollView.contentOffset = CGPointMake(0, offSetY);
    }

    if (offSetY <= 0) {
        _navBarView.backgroundView.backgroundColor = [UIColor colorWithRed:60.f/255.f green:198.f/255.f blue:253.f/255.f alpha:0.f];
    }else {
        _navBarView.backgroundView.backgroundColor = [UIColor colorWithRed:60.f/255.f green:198.f/255.f blue:253.f/255.f alpha:offSetY/(_mainTableView.tableHeaderView.height-36.f)] ;
    }
    //
    //
    //            if ( -offSetY <= 50) {
    //                [_refreshView redrawFromProgress:-offSetY/45];
    //            }else if (-offSetY <= 100) {
    //                if (!_mainTableView.dragging) {
    //                    [_refreshView startAnimation];
    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                        [self.viewModel getLatestStories];
    //                    });
    //                }
    //            }
    
    if (offSetY + _mainTableView.height + kMainTableViewRowHeight > _mainTableView.contentSize.height && !self.viewModel.isLoading) {
        [self.viewModel getPreviousStories];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story"];
    StoryCellViewModel *vm = [_viewModel cellViewModelAtIndexPath:indexPath];
    
    if (vm.displayImage) {
        cell.contentView.layer.contents = (__bridge id _Nullable)(vm.displayImage.CGImage);
    }else{
        if (!tableView.dragging&&!tableView.decelerating) {
            [vm loadDisplayImage];
            cell.contentView.layer.contents = (__bridge id _Nullable)vm.displayImage.CGImage;

        }else {
            cell.contentView.layer.contents = (__bridge id _Nullable)(vm.preImage.CGImage);
        }
    }
    cell.contentView.layer.contentsScale = [UIScreen mainScreen].scale;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryCellViewModel *vm = [self.viewModel cellViewModelAtIndexPath:indexPath];
    DetailStoryViewModel *dvm = [[DetailStoryViewModel alloc] initWithStoryID:vm.storyID];
    dvm.allStoriesID = self.viewModel.allStoriesID;
    DetailStoryViewController *detailVC = [[DetailStoryViewController alloc] initWithViewModel:dvm];
    MainViewController *mainVC = (MainViewController *)self.view.window.rootViewController;
    [mainVC.interaction attachToViewController:detailVC];
    detailVC.transitioningDelegate = mainVC;
    [mainVC presentViewController:detailVC animated:YES completion:nil];
    [self.mainTableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return kSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    SectionTitleView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([SectionTitleView class])];
    headerView.contentView.backgroundColor = [UIColor colorWithRed:60.f/255.f green:198.f/255.f blue:253.f/255.f alpha:1.f];
    headerView.textLabel.attributedText = [self.viewModel titleForSection:section];
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (section == 0) {
        [self.navBarView.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kNavigationBarHeight);
        }];
        [super updateViewConstraints];
        self.navBarView.titleLab.alpha = 1.f;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (section == 0) {
        [self.navBarView.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20.f);
        }];
        [super updateViewConstraints];
        self.navBarView.titleLab.alpha = 0.f;
    }

}

@end
