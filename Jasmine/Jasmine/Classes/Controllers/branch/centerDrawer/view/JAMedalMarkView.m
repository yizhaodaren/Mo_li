//
//  JAMedalMarkView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalMarkView.h"

@interface JAMedalMarkView ()
@property (nonatomic, weak) UIImageView *markImageView;  // 头衔
@property (nonatomic, weak) UIImageView *medalImageView; // 勋章
@end

@implementation JAMedalMarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMedalMarkViewUI];
        [self setUpMedalMarkViewRestrain];
    }
    return self;
}

- (void)setMarkString:(NSString *)markString
{
    _markString = markString;
    [self.markImageView ja_setImageWithURLStr:markString];
    if (markString.length) {
        [self.markImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(15);
        }];
    }else{
        [self.markImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
    }
    
    if (self.medalString.length) {
        [self.medalImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(20);
            make.left.equalTo(self.markImageView.mas_right).offset(!markString.length?0:5);
        }];
    }else{
        [self.medalImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.markImageView.mas_right).offset(0);
        }];
    }
}

- (void)setMedalString:(NSString *)medalString
{
    _medalString = medalString;
    [self.medalImageView ja_setImageWithURLStr:medalString];
    
    if (self.markString.length) {
        [self.markImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(15);
        }];
    }else{
        [self.markImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
    }
    
    if (medalString.length) {
        [self.medalImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(20);
            make.left.equalTo(self.markImageView.mas_right).offset(!self.markString.length?0:5);
        }];
    }else{
        [self.medalImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.markImageView.mas_right).offset(0);
        }];
    }
}

- (void)setupMedalMarkViewUI
{
    UIImageView *markImageView = [[UIImageView alloc] init];
    _markImageView = markImageView;
    markImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:markImageView];
    
    UIImageView *medalImageView = [[UIImageView alloc] init];
    _medalImageView = medalImageView;
    medalImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:medalImageView];
}

- (void)setUpMedalMarkViewRestrain
{
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(2.5);
        make.left.equalTo(self.mas_left).offset(0);
        make.width.offset(0);
        make.height.offset(15);
        make.right.equalTo(self.mas_right).offset(0).priority(300);
        make.bottom.equalTo(self.mas_bottom).offset(0).priority(300);

    }];
    
    [self.medalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.markImageView.mas_right).offset(self.markImageView.width?5:0);
        make.width.offset(0);
        make.height.offset(20);
        make.right.equalTo(self.mas_right).offset(0).priority(500);
        make.bottom.equalTo(self.mas_bottom).offset(0).priority(500);
    }];
}
@end
