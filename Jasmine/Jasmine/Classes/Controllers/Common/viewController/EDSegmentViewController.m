//
//  EDSegmentViewController.m
//  segmentView
//
//  Created by 刘宏亮 on 17/6/18.
//  Copyright © 2017年 刘宏亮. All rights reserved.
//

#import "EDSegmentViewController.h"

#define EDScreenW [UIScreen mainScreen].bounds.size.width
#define EDScreenH [UIScreen mainScreen].bounds.size.height

#define titleHeight 43
#define titleScale 1.3
#define KlineH 2

// 按钮的默认颜色
#define KnormalColor HEX_COLOR(JA_BlackTitle)

// 按钮的选中颜色
#define KselectColor HEX_COLOR(JA_Green)

// 按钮的字体大小
#define KtitleFont 15

#define KbackColor HEX_COLOR(0xe5e5e5)

#define klineColor HEX_COLOR(0x02bfa6)


@interface EDSegmentViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *titleScrollView; // 标题的scrollview

@property (nonatomic, weak) UIScrollView *contentScrollView; // 内容的scrollview

@property (nonatomic, assign) BOOL isInitial; // 是否是刚初始化
@property (nonatomic, assign) BOOL isInitialClickBtn; // 刚初始化时点击按钮

@property (nonatomic ,strong) NSMutableArray *titleButtons; // 标题按钮

@property (nonatomic, weak) UIButton *selectedButton;  // 选中的按钮

@property (nonatomic, assign) CGFloat beginOff; //初始偏移量

@property (nonatomic, weak) UIView *lineView;
@end

@implementation EDSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleButtons = [NSMutableArray array];
    self.content_scroll = YES;
    self.layoutY = 64;

    [self setupTitleScrollView];
    [self setupContentScrollView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setLayoutY:(CGFloat)layoutY {
    _layoutY = layoutY;
    self.titleScrollView.y = layoutY;
    self.contentScrollView.y = self.titleScrollView.bottom;
}

- (void)setContent_scroll:(BOOL)content_scroll
{
    _content_scroll = content_scroll;
    

    _contentScrollView.scrollEnabled = self.content_scroll;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isInitial == NO) {
        
        // 4.设置所有标题
        [self setupAllTitleButton];
        
        _isInitial = YES;
    }
    
}


#pragma mark -UIScrollViewDelegate
// 监听scrollView滚动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 获取角标
    NSInteger i = scrollView.contentOffset.x / EDScreenW;
    
    // 获取选中标题按钮
    UIButton *selectButton = self.titleButtons[i];
    // 1.选中标题
    [self selectButton:selectButton];
    
    // 2.把对应子控制器的view添加上去
    [self setupOneChildViewController:i];
    
    // 获取控制器
    UIViewController *vc = self.childViewControlArray[i];
    self.currentViewControl = vc;
    
    if (self.endScrollBlock) {
        self.endScrollBlock(vc);
    }
    
}

// 滚动scrollView就会调用 标题缩放
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.beginOff = scrollView.contentOffset.x;
    NSInteger leftI = scrollView.contentOffset.x / EDScreenW;
    // 获取左边按钮
    UIButton *leftButton = self.titleButtons[leftI];
    
    // 获取右边按钮 6
    NSInteger rightI = leftI + 1;
    UIButton *rightButton;
    if (rightI < self.titleButtons.count) {
        rightButton = self.titleButtons[rightI];
    }
    
    
    // 获取缩放比例
    if (self.title_scale) {
        
        // 0 ~ 1 => 1 ~ 1.3
        CGFloat rightScale = scrollView.contentOffset.x / EDScreenW - leftI;
        
        CGFloat leftScale = 1 - rightScale;
        
        // 对标题按钮进行缩放 1 ~ 2
        leftButton.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3 + 1);
        rightButton.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale * 0.3 + 1);
        
        if (self.title_color) {
            // 颜色渐变 -> 怎么渐变
            // 右边颜色
            UIColor *rightColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
            [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
            
            UIColor *leftColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
            [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
            
        }
    }
    
}

#pragma mark - 设置所有标题
- (void)setupAllTitleButton
{
//    self.titleScrollView.scrollEnabled = NO;
    
    NSInteger count = self.childViewControlArray.count;
    
    CGFloat btnX = self.title_margin;
    CGFloat btnY = 0;
    CGFloat btnW = (EDScreenW - 2 * btnX) / count;
    CGFloat btnH = titleHeight;
    
    for (int i = 0; i < count; i++) {
        // 创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btnX = i * btnW + self.title_margin;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        UIViewController *vc = self.childViewControlArray[i];
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
//        [btn setTitleColor:KselectColor forState:UIControlStateSelected];
        btn.titleLabel.font = JA_REGULAR_FONT(KtitleFont);
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleScrollView addSubview:btn];
        
        if (i == 0) {
//            CGFloat width = [btn.currentTitle sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}].width;
            self.lineView.frame = CGRectMake(0, 0, 12, KlineH);
            self.lineView.center = CGPointMake(btn.center.x, self.titleScrollView.bounds.size.height - 1);
//            [self titleClick:btn];
            [self selectButton:btn];
        }
        
        [self.titleButtons addObject:btn];
        
    }
    
    // 设置titleScrollView滚动范围
    CGFloat contentW = count * btnW;
    self.titleScrollView.contentSize = CGSizeMake(contentW, 0);
    // 清空水平指示条
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.contentSize = CGSizeMake(count * EDScreenW, 0);
    self.contentScrollView.pagingEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (_isInitialClickBtn == NO) {
        
        [self titleClick:self.titleButtons[0]];
        
        _isInitialClickBtn = YES;
    }
    
}

#pragma mark - 点击标题就会调用
- (void)titleClick:(UIButton *)button
{
    // 选中按钮
    [self selectButton:button];
    
    NSInteger i = button.tag;
    
    // 添加对应子控制器的view
    [self setupOneChildViewController:i];
    
    // 让scrollView滚动对应位置
    CGFloat x = i * EDScreenW;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    
    // 获取控制器
    UIViewController *vc = self.childViewControlArray[i];
    self.currentViewControl = vc;
    
    if (self.clickButtonBlock) {
        self.clickButtonBlock(vc,button);
    }
    
}
#pragma mark -把子控制器的view添加
- (void)setupOneChildViewController:(NSInteger)i
{
    UIViewController *vc = self.childViewControlArray[i];
    
    // 判断下有没有父控件
    if (vc.view.superview) return;
    
    CGFloat x = i * EDScreenW;
    // 设置vc的view的位置
    vc.view.frame = CGRectMake(x, 0, EDScreenW, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:vc.view];
    
    
//    [self.contentScrollView setNeedsLayout];
    
}
// 选中按钮
- (void)selectButton:(UIButton *)button
{
    // 恢复上一个按钮选中标题
    [_selectedButton setTitleColor:KnormalColor forState:UIControlStateNormal];
    _selectedButton.transform = CGAffineTransformIdentity;
    
    [button setTitleColor:KselectColor forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        
//        CGFloat width = [button.currentTitle sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}].width;
        self.lineView.frame = CGRectMake(0, 0, 12, KlineH);
        self.lineView.center = CGPointMake(button.center.x, self.titleScrollView.bounds.size.height - 1);
    }];
    
    
    if (self.title_scroll) {
        
        // 标题居中显示:本质就是设置偏移量
        CGFloat offsetX = button.center.x - EDScreenW * 0.5;
        
        if (offsetX < 0) {
            offsetX = 0;
        }
        
        // 处理最大偏移量
        CGFloat maxOffsetX = self.titleScrollView.contentSize.width - EDScreenW;
        
        if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
        }
        
        [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    if (self.title_scale) {
        
        // 标题缩放 -> 如何让标题缩放 改形变
        button.transform = CGAffineTransformMakeScale(titleScale, titleScale);
    }
    
    _selectedButton = button;
    
}

#pragma mark - 添加标题滚动视图
- (void)setupTitleScrollView
{
    UIScrollView *titleScrollView = [[UIScrollView alloc] init];
    titleScrollView.backgroundColor = [UIColor clearColor];
    
    CGFloat y = self.layoutY;
    
    titleScrollView.frame = CGRectMake(0, y, EDScreenW, titleHeight);
    
    [self.view addSubview:titleScrollView];
    
    _titleScrollView = titleScrollView;
    
    // FIXME:自己封装
    UIView *lonelineV = [[UIView alloc] init];
//    _lineView = lonelineV;
    lonelineV.frame = CGRectMake(0, self.titleScrollView.frame.size.height - 1, EDScreenW, 1);
    lonelineV.backgroundColor = HEX_COLOR(JA_Line);
    
    [self.titleScrollView addSubview:lonelineV];
}

#pragma mark - 添加内容滚动视图
- (void)setupContentScrollView
{
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    contentScrollView.backgroundColor = [UIColor clearColor];
    
    CGFloat y = CGRectGetMaxY(_titleScrollView.frame);
    
    contentScrollView.frame = CGRectMake(0, y, EDScreenW, EDScreenH - y);
    contentScrollView.bounces = NO;
    contentScrollView.scrollEnabled = self.content_scroll;
    
    [self.view addSubview:contentScrollView];
    _contentScrollView = contentScrollView;
    
    // 设置代理
    contentScrollView.delegate = self;
}


- (UIView *)lineView
{
    if (_lineView == nil) {
        
        UIView *lineV = [[UIView alloc] init];
        _lineView = lineV;
        lineV.backgroundColor = HEX_COLOR(JA_Green);
        
        [self.titleScrollView addSubview:lineV];
    }
    
    return _lineView;
}

- (void)setChildViewControlArray:(NSArray *)childViewControlArray
{
    _childViewControlArray = childViewControlArray;
    
    for (UIViewController *vc in childViewControlArray) {
        
        [self addChildViewController:vc];
    }
    
}

@end
