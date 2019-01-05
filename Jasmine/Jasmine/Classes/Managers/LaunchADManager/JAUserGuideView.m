//
//  JAUserGuideView.m
//  Jasmine
//
//  Created by xujin on 2018/6/12.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAUserGuideView.h"

@interface JAUserGuideView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation JAUserGuideView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollView = [UIScrollView new];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
//        make.top.equalTo(self.mas_top).offset(JA_StatusBarHeight);
//        make.bottom.equalTo(self.mas_bottom).offset(-JA_TabbarSafeBottomMargin);
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.height.equalTo(self.scrollView.mas_height);
        }];
        
        UIView *lastView = nil;
        NSArray *datas = [self getPageDatas];
        NSMutableArray *pageViews = [NSMutableArray new];
        for (int i=0; i<datas.count; i++) {
            BOOL showCloseButton = NO;
            if (i == datas.count-1) {
                showCloseButton = YES;
            }
            NSDictionary *dic = datas[i];
            UIView *view = [self getPageViewWithImageName:dic[@"imageName"]
                                                    title:dic[@"title"]
                                                 subTitle:dic[@"subTitle"]
                                          showCloseButton:showCloseButton];
            [contentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(contentView);
                make.bottom.equalTo(contentView);
                make.width.offset(JA_SCREEN_WIDTH);
                if (lastView) {
                    make.left.mas_equalTo(lastView.mas_right);
                }else{
                    make.left.mas_equalTo(contentView.mas_left);
                }
            }];
            [pageViews addObject:view];
            lastView = view;
        }
        [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lastView.mas_right);
        }];
        
        UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        skipButton.titleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(14));
        [skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [skipButton setTitleColor:HEX_COLOR(0xD7D7D7) forState:UIControlStateNormal];
        skipButton.layer.cornerRadius = WIDTH_ADAPTER(12.5);
        skipButton.layer.masksToBounds = YES;
        skipButton.layer.borderColor = [HEX_COLOR(0xD7D7D7) CGColor];
        skipButton.layer.borderWidth = 1;
        [self addSubview:skipButton];
        [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(JA_StatusBarHeight);
            make.right.equalTo(self.mas_right).offset(-WIDTH_ADAPTER(20));
            make.size.mas_equalTo(CGSizeMake(WIDTH_ADAPTER(50), WIDTH_ADAPTER(25)));
        }];
        self.skipButton = skipButton;
        
        UIPageControl *pageControl = [UIPageControl new];
        pageControl.numberOfPages = datas.count;
        pageControl.currentPage = 0;
        pageControl.pageIndicatorTintColor = HEX_COLOR(0xECECEC);
        pageControl.currentPageIndicatorTintColor = HEX_COLOR(0x9B9B9B);
        [self addSubview:pageControl];
        [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            if (iPhone4) {
                make.bottom.equalTo(self.mas_bottom).offset(-WIDTH_ADAPTER(15));
            } else {
                make.bottom.equalTo(self.mas_bottom).offset(-WIDTH_ADAPTER(30));
            }
        }];
        self.pageControl = pageControl;
    }
    return self;
}

- (NSArray *)getPageDatas {
    return @[
             @{
                 @"imageName":@"guide_circle",
                 @"title":@"茉莉圈子",
                 @"subTitle":@"为你找到同类知音人",
                 },
             @{
                 @"imageName":@"guide_album",
                 @"title":@"故事专辑",
                 @"subTitle":@"让你的故事更有意义",
                 },
             @{
                 @"imageName":@"guide_mall",
                 @"title":@"茉莉商城",
                 @"subTitle":@"给你的生活更多乐趣",
                 },
             @{
                 @"imageName":@"guide_more",
                 @"title":@"更懂你",
                 @"subTitle":@"茉莉3.0全方位的产品优化",
                 }
             ];
}

- (UIView *)getPageViewWithImageName:(NSString *)imageName
                               title:(NSString *)title
                               subTitle:(NSString *)subTitle
                     showCloseButton:(BOOL)showCloseButton {
    UIView *pageView = [UIView new];
    pageView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:imageName];
    [pageView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(pageView.mas_centerX);
        if (iPhone4) {
            make.top.offset(WIDTH_ADAPTER(32));
            make.size.mas_equalTo(CGSizeMake(WIDTH_ADAPTER(300), WIDTH_ADAPTER(300)));
        } else {
            make.top.offset(WIDTH_ADAPTER(iPhoneX?64+72:72));
            make.size.mas_equalTo(CGSizeMake(WIDTH_ADAPTER(300), WIDTH_ADAPTER(300)));
        }
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(30));
    titleLabel.textColor = HEX_COLOR(JA_Green);
    titleLabel.text = title;
    [pageView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (iPhone4) {
            make.top.equalTo(imageView.mas_bottom).offset(33);
        } else {
            make.top.equalTo(imageView.mas_bottom).offset(iPhoneX?30+43:43);
        }
        make.centerX.equalTo(pageView.mas_centerX);
        make.height.offset(WIDTH_ADAPTER(42));
    }];
    
    UILabel *subTitleLabel = [UILabel new];
    subTitleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(15));
    subTitleLabel.textColor = HEX_COLOR(0xC5C5C5);
    subTitleLabel.text = subTitle;
    [pageView addSubview:subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.centerX.equalTo(pageView.mas_centerX);
        make.height.offset(WIDTH_ADAPTER(21));
    }];
    
    if (showCloseButton) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.titleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(20));
        [closeButton setTitle:@"立即体验" forState:UIControlStateNormal];
        [closeButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = WIDTH_ADAPTER(22.5);
        closeButton.layer.masksToBounds = YES;
        closeButton.layer.borderColor = [HEX_COLOR(JA_Green) CGColor];
        closeButton.layer.borderWidth = 1;
        [pageView addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (iPhone4) {
                make.top.equalTo(subTitleLabel.mas_bottom).offset(WIDTH_ADAPTER(20));
            } else {
                make.top.equalTo(subTitleLabel.mas_bottom).offset(WIDTH_ADAPTER(50));
            }
            make.centerX.equalTo(pageView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(WIDTH_ADAPTER(220), WIDTH_ADAPTER(45)));
        }];
        self.closeButton = closeButton;
    }
    return pageView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewW = scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    NSInteger page = (x + scrollViewW / 2) / scrollViewW;
    [self.pageControl setCurrentPage:page];
}

@end
