//
//  JARefreshToastView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JARefreshToastView.h"

@interface JARefreshToastView ()

@property (nonatomic, strong) UILabel *textlabel;

@end

@implementation JARefreshToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupToastViewUI];
    }
    return self;
}

- (void)setupToastViewUI
{
    self.width = JA_SCREEN_WIDTH;
    self.height = 28;
    self.y = - self.height;
    self.backgroundColor = HEX_COLOR_ALPHA(0x31C27C, 0.9);
    self.textlabel = [[UILabel alloc] init];
    self.textlabel.text = @"暂无更新，看看其他频道吧";
    self.textlabel.textColor = HEX_COLOR(0xffffff);
    self.textlabel.font = JA_REGULAR_FONT(12);
    self.textlabel.frame = self.bounds;
    self.textlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.textlabel];
}


/*

 1 关注    更新了xx条新内容
 2 推荐    为你推荐了xx条新内容
 3 发现    为你推荐了xx条新内容
 4 最新    更新了xx条新内容
 */
- (void)refreshContentWithCount:(NSInteger)count type:(NSInteger)typeChannel
{
    if (typeChannel == 1 || typeChannel == 4){
        if (count == 0) {
            self.textlabel.text = @"暂无更新，看看其他频道吧";
        }else{
            self.textlabel.text = [NSString stringWithFormat:@"更新了%ld条新内容",count];
        }
    }else if (typeChannel == 2 || typeChannel == 3){
        if (count == 0) {
            self.textlabel.text = @"暂无更新，看看其他频道吧";
        }else{
            self.textlabel.text = [NSString stringWithFormat:@"为你推荐了%ld条新内容",count];
        }
    }
    
    self.y = - self.height;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.y = 0;
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                self.y = - self.height;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        });
    }];
    
}


@end
