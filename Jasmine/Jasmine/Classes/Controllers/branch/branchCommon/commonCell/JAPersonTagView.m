//
//  JAPersonTagView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonTagView.h"
#import "JANewCommentModel.h"
#import "JANewReplyModel.h"

@interface JAPersonTagView ()
@property (nonatomic, weak) UIView *levelBackView;
@property (nonatomic, weak) UIImageView *levelImageView;
@property (nonatomic, weak) UILabel *levelLabel;

@property (nonatomic, weak) UIView *floorBackView;
@property (nonatomic, weak) UILabel *floorLabel;

@property (nonatomic, weak) UIView *circleBackView;
@property (nonatomic, weak) UILabel *circleLabel;
@end

@implementation JAPersonTagView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPersonTagViewUI];
        [self setUpPersonTagViewRestrain];
    }
    return self;
}

- (void)setType:(NSInteger)type
{
    _type = type;
    if (type == 1) {
        [self.floorBackView removeFromSuperview];
        self.floorBackView = nil;
    }
}

- (void)setLevel:(NSString *)level
{
    _level = level;
    self.levelLabel.text = [NSString stringWithFormat:@"%@",level];
    
    if (self.level.integerValue == 0) {  // 有等级
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
    }else{
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
        }];
    }
    
    if (!self.isCircle) {
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.levelBackView.mas_right).offset(0);
        }];
    }else{
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
            make.left.equalTo(self.levelBackView.mas_right).offset(self.level.integerValue == 0?0:5);
        }];
    }
    
    if (!self.isFloor) {
        [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.circleBackView.mas_right).offset(0);
        }];
    }else{
        [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
            make.left.equalTo(self.circleBackView.mas_right).offset(self.isCircle || self.level.integerValue > 0?5:0);
        }];
    }
}

- (void)setIsFloor:(BOOL)isFloor
{
    _isFloor = isFloor;
    
    if (self.level.integerValue == 0) {  // 有等级
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
    }else{
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
        }];
    }
    
    if (!self.isCircle) {
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.levelBackView.mas_right).offset(0);
        }];
    }else{
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
            make.left.equalTo(self.levelBackView.mas_right).offset(self.level.integerValue == 0?0:5);
        }];
    }
    
    if (!self.isFloor) {
        [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.circleBackView.mas_right).offset(0);
        }];
    }else{
        [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
            make.left.equalTo(self.circleBackView.mas_right).offset(self.isCircle || self.level.integerValue > 0?5:0);
        }];
    }
    
}

- (void)setIsCircle:(BOOL)isCircle
{
    _isCircle = isCircle;
    if (self.level.integerValue == 0) {  // 有等级
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
    }else{
        [self.levelBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
        }];
    }
    if (!self.isCircle) {
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
            make.left.equalTo(self.levelBackView.mas_right).offset(0);
        }];
    }else{
        [self.circleBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(26);
            make.left.equalTo(self.levelBackView.mas_right).offset(self.level.integerValue == 0?0:5);
        }];
    }
    
    if (self.floorBackView) {
        if (!self.isFloor) {
            [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.offset(0);
                make.left.equalTo(self.circleBackView.mas_right).offset(0);
            }];
        }else{
            [self.floorBackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.offset(26);
                make.left.equalTo(self.circleBackView.mas_right).offset(self.isCircle || self.level.integerValue > 0?5:0);
            }];
        }
    }
}

- (void)setupPersonTagViewUI
{
    UIView *levelBackView = [[UIView alloc] init];
    _levelBackView = levelBackView;
    levelBackView.backgroundColor = HEX_COLOR(0x6BD379);
    levelBackView.layer.cornerRadius = 2;
    levelBackView.layer.masksToBounds = YES;
    [self addSubview:levelBackView];
    
    UIImageView *levelImageView = [[UIImageView alloc] init];
    _levelImageView = levelImageView;
    levelImageView.image = [UIImage imageNamed:@"branch_circle_level"];
    [levelBackView addSubview:levelImageView];
    
    UILabel *levelLabel = [[UILabel alloc] init];
    _levelLabel = levelLabel;
    levelLabel.text = @"1";
    levelLabel.textColor = HEX_COLOR(0xffffff);
    levelLabel.font = JA_REGULAR_FONT(10);
    [levelBackView addSubview:levelLabel];
    
    UIView *floorBackView = [[UIView alloc] init];
    _floorBackView = floorBackView;
    floorBackView.backgroundColor = HEX_COLOR(0x3B90F1);
    floorBackView.layer.cornerRadius = 2;
    floorBackView.layer.masksToBounds = YES;
    [self addSubview:floorBackView];
    
    UILabel *floorLabel = [[UILabel alloc] init];
    _floorLabel = floorLabel;
    floorLabel.text = @"楼主";
    floorLabel.textColor = HEX_COLOR(0xffffff);
    floorLabel.font = JA_REGULAR_FONT(10);
    [floorBackView addSubview:floorLabel];
    
    UIView *circleBackView = [[UIView alloc] init];
    _circleBackView = circleBackView;
    circleBackView.backgroundColor = HEX_COLOR(0xF83162);
    circleBackView.layer.cornerRadius = 2;
    circleBackView.layer.masksToBounds = YES;
    [self addSubview:circleBackView];
    
    UILabel *circleLabel = [[UILabel alloc] init];
    _circleLabel = circleLabel;
    circleLabel.text = @"圈主";
    circleLabel.textColor = HEX_COLOR(0xffffff);
    circleLabel.font = JA_REGULAR_FONT(10);
    [circleBackView addSubview:circleLabel];
}

- (void)setUpPersonTagViewRestrain
{
    
    [self.levelBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
        make.height.offset(14);
    }];
    
    [self.levelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.levelBackView.mas_left).offset(3);
        make.top.equalTo(self.levelBackView.mas_top).offset(3);
        make.width.offset(10);
        make.height.offset(8);
    }];
    
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.levelImageView.mas_right).offset(3);
        make.centerY.equalTo(self.levelImageView.mas_centerY).offset(0);
        make.height.offset(8);
//        make.right.equalTo(self.levelBackView.mas_right).offset(3);
//        make.bottom.equalTo(self.levelBackView.mas_bottom).offset(-3);
    }];
    
    
    [self.circleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.levelBackView.mas_right).offset(5);
        make.width.offset(26);
        make.height.offset(14);
        make.right.equalTo(self.mas_right).offset(0).priority(500);
        make.bottom.equalTo(self.mas_bottom).offset(0).priority(500);
        
    }];
    
    [self.circleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.circleBackView.mas_centerX).offset(0);
        make.centerY.equalTo(self.circleBackView.mas_centerY).offset(0);
    }];
    
    [self.floorBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.circleBackView.mas_right).offset(5);
        make.width.offset(26);
        make.height.offset(14);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    [self.floorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.floorBackView.mas_centerX).offset(0);
        make.centerY.equalTo(self.floorBackView.mas_centerY).offset(0);
    }];
}
@end
