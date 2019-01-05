//
//  JAFunctionToolV.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/12.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAFunctionToolV.h"
@interface JAFuncShareBtn : UIButton


@end

@implementation JAFuncShareBtn
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

@interface JAFuncToolBtn : UIButton

@property (nonatomic, strong) UIImageView *btnImg;

@end

@implementation JAFuncToolBtn
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        UIView *bgV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
//        bgV.userInteractionEnabled = NO;
//        bgV.backgroundColor = HEX_COLOR(JA_BoardLineColor);
//        bgV.layer.cornerRadius = (frame.size.width)*.5;
//        [self addSubview:bgV];
//        self.btnImg = [[UIImageView alloc] initWithFrame:bgV.bounds];
//        self.btnImg.userInteractionEnabled = NO;
//        
//        self.btnImg.center = bgV.center;
//        [self addSubview:self.btnImg];
        
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


static CGFloat const kTransitionDuration = 0.3;
static CGFloat const kLeadingGap = 22;
@interface JAFunctionToolV ()

@property (nonatomic, strong) UIButton *backgroundView;

@end

@implementation JAFunctionToolV

- (void) show{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (!window){
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    _backgroundView = [UIButton buttonWithType:UIButtonTypeCustom];
    _backgroundView.frame = window.bounds;
    [_backgroundView addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [window addSubview:_backgroundView];
    
    [_backgroundView addSubview:self];
}

- (void) close{
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
}

- (void)support{
    [self close];
}

- (void)slander{
    [self close];
}

- (void) onBackButton{
    [self close];
}

- (void)shareWith:(JAFuncShareBtn *)btn{
    if (self.shareWitnIndex!=NULL) {
        self.shareWitnIndex(btn.tag-200);
    }
    [self close];
    
}

- (void)funcWith:(JAFuncShareBtn *)btn{
    if (self.funcWitnIndex!=NULL) {
        self.funcWitnIndex(btn.tag-200,btn.selected);
    }
    [self close];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}


- (instancetype)functionToolV:(JAParticularsReportType)type
{
    CGRect frame = CGRectMake(0, JA_SCREEN_HEIGHT-290, JA_SCREEN_WIDTH, 290);
    
    return [self initWithFrame:frame functionToolV:type];
}

- (instancetype)initWithFrame:(CGRect)frame functionToolV:(JAParticularsReportType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = HEX_COLOR(JA_Background);
        
        NSArray *shareArr = @[
                              @{@"img":@"tool_share_timeline", @"title":@"微信朋友圈"},
                              @{@"img":@"tool_share_wechat", @"title":@"微信好友"},
                              @{@"img":@"tool_share_qq", @"title":@"手机QQ"},
                              @{@"img":@"tool_share_zone", @"title":@"QQ空间"},
                              @{@"img":@"tool_share_weibo", @"title":@"新浪微博"}
                              ];
        CGFloat buttonW = 59;
        CGFloat buttonH = 80;
        UIScrollView *scroll1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 126)];
        scroll1.showsHorizontalScrollIndicator = NO;
        scroll1.contentSize = CGSizeMake((kLeadingGap+buttonW)*shareArr.count+kLeadingGap, 0);
        [self addSubview:scroll1];
        for (int i=0; i<shareArr.count; i++) {
            JAFuncShareBtn *toolBtn = [[JAFuncShareBtn alloc] initWithFrame:CGRectMake(kLeadingGap+(buttonW+kLeadingGap)*i, 0, buttonW, buttonH)];
            [toolBtn setImage:[UIImage imageNamed:[shareArr[i] objectForKey:@"img"]] forState:UIControlStateNormal];
            toolBtn.tag = 200+i;
            [toolBtn addTarget:self action:@selector(shareWith:) forControlEvents:UIControlEventTouchUpInside];
            [toolBtn setTitle:[shareArr[i] objectForKey:@"title"] forState:UIControlStateNormal];
            [scroll1 addSubview:toolBtn];
            toolBtn.centerY = scroll1.height/2.0;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 126, JA_SCREEN_WIDTH, 1)];
        line.backgroundColor = HEX_COLOR(JA_Line);
        [self addSubview:line];
        
        NSArray *funcArr = nil;
        if(type == JAParticularsReportCollect){
            funcArr = @[@{@"img":@"branch_voice_collect",@"selImg":@"branch_voice_collectd", @"title":@"收藏", @"selTitle":@"取消收藏"},@{@"img":@"branch_voice_report",@"selImg":@"branch_voice_report", @"title":@"举报", @"selTitle":@"举报"}];
        }else if (type == JAParticularsCollectDelete){
            funcArr = @[@{@"img":@"branch_voice_collect",@"selImg":@"branch_voice_collectd", @"title":@"收藏", @"selTitle":@"取消收藏"},@{@"img":@"tool_share_delete",@"selImg":@"tool_share_delete", @"title":@"删除", @"selTitle":@"删除"}];
        }
        UIScrollView *scroll2 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, line.bottom, JA_SCREEN_WIDTH, 115)];
        scroll2.showsHorizontalScrollIndicator = NO;
        scroll2.contentSize = CGSizeMake(82*funcArr.count+kLeadingGap, 0);
        [self addSubview:scroll2];
        for (int i=0; i<funcArr.count; i++) {
            JAFuncShareBtn *toolBtn = [[JAFuncShareBtn alloc] initWithFrame:CGRectMake(kLeadingGap+(buttonW+kLeadingGap)*i, 11, buttonW, buttonH)];
            [toolBtn setImage:[UIImage imageNamed:[funcArr[i] objectForKey:@"img"]] forState:UIControlStateNormal];
            [toolBtn setImage:[UIImage imageNamed:[funcArr[i] objectForKey:@"selImg"]] forState:UIControlStateSelected];
            toolBtn.tag = 200+i;
            [toolBtn addTarget:self action:@selector(funcWith:) forControlEvents:UIControlEventTouchUpInside];
            [toolBtn setTitle:[funcArr[i] objectForKey:@"title"] forState:UIControlStateNormal];
            [toolBtn setTitle:[funcArr[i] objectForKey:@"selTitle"] forState:UIControlStateSelected];
            if (i == 0) {
                self.collectButton = toolBtn;
            }
            [scroll2 addSubview:toolBtn];
        }
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, scroll2.bottom, JA_SCREEN_WIDTH, 1)];
        line1.backgroundColor = HEX_COLOR(0xdfdfdf);
        [self addSubview:line1];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line1.bottom, JA_SCREEN_WIDTH, 49)];
        cancelBtn.backgroundColor = [UIColor clearColor];
        cancelBtn.titleLabel.font = JA_MEDIUM_FONT(16);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
    }
    return self;
}



+ (instancetype)shareToolV{
    JAFunctionToolV *view = [[JAFunctionToolV alloc] initWithFrame:CGRectMake(0, JA_SCREEN_HEIGHT-175, JA_SCREEN_WIDTH, 175)];
    view.backgroundColor = HEX_COLOR(JA_Background);
    
    NSArray *shareArr = @[
                          @{@"img":@"tool_share_timeline", @"title":@"微信朋友圈"},
                          @{@"img":@"tool_share_wechat", @"title":@"微信好友"},
                          @{@"img":@"tool_share_qq", @"title":@"手机QQ"},
                          @{@"img":@"tool_share_zone", @"title":@"QQ空间"},
                          @{@"img":@"tool_share_weibo", @"title":@"新浪微博"}
                          ];
    CGFloat buttonW = 59;
    CGFloat buttonH = 80;
    UIScrollView *scroll1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 126)];
    scroll1.showsHorizontalScrollIndicator = NO;
    scroll1.contentSize = CGSizeMake((kLeadingGap+buttonW)*shareArr.count+kLeadingGap, 0);
    [view addSubview:scroll1];
    for (int i=0; i<shareArr.count; i++) {
        JAFuncShareBtn *toolBtn = [[JAFuncShareBtn alloc] initWithFrame:CGRectMake(kLeadingGap+(buttonW+kLeadingGap)*i, 0, buttonW, buttonH)];
        [toolBtn setImage:[UIImage imageNamed:[shareArr[i] objectForKey:@"img"]] forState:UIControlStateNormal];
        toolBtn.tag = 200+i;
        [toolBtn addTarget:view action:@selector(shareWith:) forControlEvents:UIControlEventTouchUpInside];
        [toolBtn setTitle:[shareArr[i] objectForKey:@"title"] forState:UIControlStateNormal];
        [scroll1 addSubview:toolBtn];
        toolBtn.centerY = scroll1.height/2.0;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 126, JA_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    [view addSubview:line];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line.bottom, JA_SCREEN_WIDTH, 49)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = JA_MEDIUM_FONT(16);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
    [cancelBtn addTarget:view action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    
    return view;
}

+ (instancetype)webshareToolV
{
    JAFunctionToolV *view = [[JAFunctionToolV alloc] initWithFrame:CGRectMake(0, JA_SCREEN_HEIGHT-175, JA_SCREEN_WIDTH, 175)];
    view.backgroundColor = HEX_COLOR(JA_Background);
    
    NSArray *shareArr = @[
                          @{@"img":@"tool_share_timeline", @"title":@"微信朋友圈"},
                          @{@"img":@"tool_share_wechat", @"title":@"微信好友"},
                          @{@"img":@"tool_share_qq", @"title":@"手机QQ"},
                          @{@"img":@"tool_share_weibo", @"title":@"新浪微博"}
                          ];
    CGFloat buttonW = 59;
    CGFloat buttonH = 80;
    UIScrollView *scroll1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 126)];
    scroll1.showsHorizontalScrollIndicator = NO;
    scroll1.contentSize = CGSizeMake((30+buttonW)*shareArr.count+30, 0);
    [view addSubview:scroll1];
    for (int i=0; i<shareArr.count; i++) {
        JAFuncShareBtn *toolBtn = [[JAFuncShareBtn alloc] initWithFrame:CGRectMake(30+(buttonW+30)*i, 0, buttonW, buttonH)];
        [toolBtn setImage:[UIImage imageNamed:[shareArr[i] objectForKey:@"img"]] forState:UIControlStateNormal];
        toolBtn.tag = 200+i;
        [toolBtn addTarget:view action:@selector(shareWith:) forControlEvents:UIControlEventTouchUpInside];
        [toolBtn setTitle:[shareArr[i] objectForKey:@"title"] forState:UIControlStateNormal];
        [scroll1 addSubview:toolBtn];
        toolBtn.centerY = scroll1.height/2.0;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 126, JA_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    [view addSubview:line];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line.bottom, JA_SCREEN_WIDTH, 49)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = JA_MEDIUM_FONT(16);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
    [cancelBtn addTarget:view action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    
    return view;
}

- (void)bounceAnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView commitAnimations];
}

@end
