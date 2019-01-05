//
//  JABottomShareView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABottomShareView.h"

@interface JABottomShareViewButton : UIButton


@end

@implementation JABottomShareViewButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        self.imageView.contentMode = UIViewContentModeCenter;
        
        self.titleLabel.font = JA_LIGHT_FONT(11);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, self.width, self.width);
    self.imageView.layer.cornerRadius = self.imageView.width*.5;
    self.titleLabel.frame = CGRectMake(0, self.width+5, self.width, 16);
}

@end

@interface JABottomShareView ()

@property (nonatomic, assign) JABottomShareViewType type; // 类型
@property (nonatomic, assign) JABottomShareOneContentType oneType; // 内容类型
@property (nonatomic, assign) JABottomShareTwoContentType twoType; // 内容类型
@property (nonatomic, strong) NSArray *shareIconArray;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *cancleButton;  // 取消按钮
@end

@implementation JABottomShareView

- (instancetype)initWithShareType:(JABottomShareViewType)type
                      contentType:(JABottomShareOneContentType)oneType
                   twoContentType:(JABottomShareTwoContentType)TwoType
{
    self = [super init];
    if (self) {
        self.type = type;
        self.oneType = oneType;
        self.twoType = TwoType;
        self.shareIconArray = @[
                                @[                                           // 第一组
                                    @{
                                        @"img":@"tool_share_timeline",
                                        @"selImg":@"tool_share_timeline",
                                        @"title":@"微信朋友圈",
                                        @"selTitle":@"微信朋友圈"
                                      },
                                    @{
                                        @"img":@"tool_share_wechat",
                                        @"selImg":@"tool_share_wechat",
                                        @"title":@"微信好友",
                                        @"selTitle":@"微信好友"
                                        },
                                    @{
                                        @"img":@"tool_share_qq",
                                        @"selImg":@"tool_share_qq",
                                        @"title":@"手机QQ",
                                        @"selTitle":@"手机QQ"
                                        },
                                    @{
                                        @"img":@"tool_share_zone",
                                        @"selImg":@"tool_share_zone",
                                        @"title":@"QQ空间",
                                        @"selTitle":@"QQ空间"
                                        },
                                    @{
                                        @"img":@"tool_share_weibo",
                                        @"selImg":@"tool_share_weibo",
                                        @"title":@"新浪微博",
                                        @"selTitle":@"新浪微博"
                                        }
                                    ],
                                @[                                           // 第二组
                                    @{
                                        @"img":@"branch_voice_collect",
                                        @"selImg":@"branch_voice_collectd",
                                        @"title":@"收藏",
                                        @"selTitle":@"取消收藏"
                                        
                                        },
                                    @{
                                        @"img":@"branch_voice_report",
                                        @"selImg":@"branch_voice_report",
                                        @"title":@"举报",
                                        @"selTitle":@"举报"
                                        
                                        },
                                    @{
                                        @"img":@"tool_share_delete",
                                        @"selImg":@"tool_share_delete",
                                        @"title":@"删除",
                                        @"selTitle":@"删除"
                                        
                                        }
                                    ],
                                ];
        

        [self setupUI];
    }
    return self;
}


- (void)setupUI
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenBottomShareView)];
    [self addGestureRecognizer:tap];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(JA_Background);
    [self addSubview:bottomView];
    
    bottomView.width = JA_SCREEN_WIDTH;
    if (self.type == JABottomShareViewTypeOneLine) {
        bottomView.height = 169;
    }else if (self.type == JABottomShareViewTypeTwoLine){
        bottomView.height = 290;
    }
    bottomView.height += JA_TabbarSafeBottomMargin;
    bottomView.y = JA_SCREEN_HEIGHT - bottomView.height;
    
    if (self.type == JABottomShareViewTypeOneLine) {
        
        [self setupScrollView_one];
        
    }else if (self.type == JABottomShareViewTypeTwoLine){
        
        [self setupScrollView_one];
        [self setupScrollView_two];
        
    }
    
    [self setupCancleButton];
}

// 创建scrollview 行一
- (void)setupScrollView_one
{
    // 获取需要展示的button
    NSArray *buttonA = self.shareIconArray[0];
    if (!buttonA.count) {
        return;
    }
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 121)];
    scroll.showsHorizontalScrollIndicator = NO;
    [self.bottomView addSubview:scroll];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, scroll.bottom - 1, JA_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    [self.bottomView addSubview:line];
    // 创建按钮
    NSArray *buttonArray = buttonA;
    if (self.oneType == JABottomShareOneContentTypeNormal) {   // 默认都展示
    }else if (self.oneType == JABottomShareOneContentTypeCustom_one){   // 定制一  （好友，朋友圈)
        buttonArray = @[buttonA[0],buttonA[1]];
    }
    
    CGFloat btnW = 59;
    CGFloat btnH = 80;
    CGFloat margin = 20;
    NSInteger count = buttonArray.count;  // 总个数
    CGFloat totleW = btnW * count + margin * (count + 1);
    if (totleW < JA_SCREEN_WIDTH) {
        margin = (JA_SCREEN_WIDTH - btnW * count) / (count + 1);
//        btnW = (JA_SCREEN_WIDTH - (count + 1) * 20) / count;
    }
    
    scroll.contentSize = CGSizeMake(totleW, 0);
    
    for (int i=0; i<buttonArray.count; i++) {
        JABottomShareViewButton *button = [JABottomShareViewButton buttonWithType:UIButtonTypeCustom];
        NSDictionary *dic = buttonArray[i];
        NSString *image = dic[@"img"];
        NSString *selImage = dic[@"selImg"];
        NSString *title = dic[@"title"];
        NSString *selTitle = dic[@"selTitle"];
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selImage] forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:selTitle forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickButton_ONE:) forControlEvents:UIControlEventTouchUpInside];
        
        button.x = margin + i * (btnW + margin);
        button.y = 22;
        button.width = btnW;
        button.height = btnH;
        
        [scroll addSubview:button];
        
    }
}

// 创建scrollview 行二
- (void)setupScrollView_two
{
    // 获取需要展示的button
    NSArray *buttonA = self.shareIconArray[1];
    if (!buttonA.count) {
        return;
    }
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 121, JA_SCREEN_WIDTH, 121)];
    scroll.showsHorizontalScrollIndicator = NO;
    [self.bottomView addSubview:scroll];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, scroll.bottom - 1, JA_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    [self.bottomView addSubview:line];
    
    // 创建按钮
    NSArray *buttonArray = buttonA;
    if (self.twoType == JABottomShareTwoContentTypeNormal) {   // 默认都展示
        
    }else if (self.twoType == JABottomShareTwoContentTypeCustom_one){   // 定制一 （收藏、删除）
        buttonArray = @[buttonA[0],buttonA[2]];
    }else if (self.twoType == JABottomShareTwoContentTypeCustom_two){   // 定制二  （收藏、举报）
        buttonArray = @[buttonA[0],buttonA[1]];
    }
    
    CGFloat btnW = 59;
    CGFloat btnH = 80;
    CGFloat margin = 20;
    NSInteger count = buttonArray.count;  // 总个数
    CGFloat totleW = btnW * count + margin * (count + 1);
    if (totleW < JA_SCREEN_WIDTH) {
//        margin = (JA_SCREEN_WIDTH - btnW * count) / (count + 1);
    }
    
    scroll.contentSize = CGSizeMake(totleW, 0);
    
    for (int i=0; i<buttonArray.count; i++) {
        JABottomShareViewButton *button = [JABottomShareViewButton buttonWithType:UIButtonTypeCustom];
        NSDictionary *dic = buttonArray[i];
        NSString *image = dic[@"img"];
        NSString *selImage = dic[@"selImg"];
        NSString *title = dic[@"title"];
        NSString *selTitle = dic[@"selTitle"];
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selImage] forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:selTitle forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickButton_ONE:) forControlEvents:UIControlEventTouchUpInside];
        
        button.x = margin + i * (btnW + margin);
        button.y = 22;
        button.width = btnW;
        button.height = btnH;
        
        [scroll addSubview:button];
        
    }
}

//// 创建scrollview 行三    暂时没用
//- (void)setupScrollView_three
//{
//    // 获取需要展示的button
//    NSArray *buttonA = self.shareIconArray[2];
//    if (!buttonA.count) {
//        return;
//    }
//
//    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 242, JA_SCREEN_WIDTH, 121)];
//    scroll.showsHorizontalScrollIndicator = NO;
//    [self.bottomView addSubview:scroll];
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, scroll.bottom - 1, JA_SCREEN_WIDTH, 1)];
//    line.backgroundColor = HEX_COLOR(JA_Line);
//    [self.bottomView addSubview:line];
//
//    // 创建按钮
//    NSArray *buttonArray = buttonA;
//    if (self.threeType == JABottomShareThreeContentTypeNormal) {   // 默认都展示
//    }
//
//    CGFloat btnW = 59;
//    CGFloat btnH = 80;
//    CGFloat margin = 20;
//    NSInteger count = buttonArray.count;  // 总个数
//    CGFloat totleW = btnW * count + margin * (count + 1);
//    if (totleW < JA_SCREEN_WIDTH) {
////        margin = (JA_SCREEN_WIDTH - btnW * count) / (count + 1);
//    }
//
//    scroll.contentSize = CGSizeMake(totleW, 0);
//
//    for (int i=0; i<buttonArray.count; i++) {
//        JABottomShareViewButton *button = [JABottomShareViewButton buttonWithType:UIButtonTypeCustom];
//        NSDictionary *dic = buttonArray[i];
//        NSString *image = dic[@"img"];
//        NSString *selImage = dic[@"selImg"];
//        NSString *title = dic[@"title"];
//        NSString *selTitle = dic[@"selTitle"];
//        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:selImage] forState:UIControlStateSelected];
//        [button setTitle:title forState:UIControlStateNormal];
//        [button setTitle:selTitle forState:UIControlStateSelected];
//        [button addTarget:self action:@selector(clickButton_ONE:) forControlEvents:UIControlEventTouchUpInside];
//
//        button.x = margin + i * (btnW + margin);
//        button.y = 22;
//        button.width = btnW;
//        button.height = btnH;
//
//        [scroll addSubview:button];
//
//    }
//}

- (void)setupCancleButton
{
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancleButton = cancleButton;
    cancleButton.width = JA_SCREEN_WIDTH;
    cancleButton.height = 48;
    cancleButton.y = self.bottomView.height - cancleButton.height - JA_TabbarSafeBottomMargin;
    cancleButton.backgroundColor = [UIColor clearColor];
    cancleButton.titleLabel.font = JA_MEDIUM_FONT(16);
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:cancleButton];
}

// 按钮的点击事件
- (void)clickButton_ONE:(UIButton *)btn
{
    if ([btn.currentTitle isEqualToString:@"微信朋友圈"]) {
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeWXSession, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"微信好友"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeWX, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"手机QQ"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeQQ, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"QQ空间"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeQQZone, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"新浪微博"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeWB, NO, btn);
        }
    }
    
    [self hiddenBottomShareView];
}

- (void)clickButton_TWO:(UIButton *)btn
{
    if ([btn.currentTitle isEqualToString:@"收藏"]) {
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeCollect, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"取消收藏"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeCollect, YES, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"举报"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeReport, NO, btn);
        }
    }else if ([btn.currentTitle isEqualToString:@"删除"]){
        if (self.bottomShareClickButton) {
            self.bottomShareClickButton(JABottomShareClickTypeDelete, NO, btn);
        }
    }
    
    [self hiddenBottomShareView];
}


- (void)onBackButton
{
    [self hiddenBottomShareView];
}

// 展示
- (void)showBottomShareView
{
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    self.bottomView.y = self.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.y = self.height - self.bottomView.height;
    }];
}

// 隐藏
- (void)hiddenBottomShareView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.y = self.height;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

@end
