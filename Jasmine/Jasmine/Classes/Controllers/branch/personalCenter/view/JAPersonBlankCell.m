//
//  JAPersonBlankCell.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonBlankCell.h"

@interface JAPersonBlankCell ()
@property (nonatomic, weak) UIImageView *image_view;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *aginButton;
@property (nonatomic, weak) UIButton *publishButton;
@end

@implementation JAPersonBlankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupBlankUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupBlankUI
{
    UIImageView *image_view = [[UIImageView alloc] init];
    _image_view = image_view;
    image_view.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:image_view];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    [self.contentView addSubview:nameLabel];
    
    UIButton *aginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _aginButton = aginButton;
    [aginButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR_ALPHA(0x000000, 0.2)] forState:UIControlStateHighlighted];
    [aginButton addTarget:self action:@selector(aginRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:aginButton];
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton = publishButton;
    publishButton.backgroundColor = HEX_COLOR(0xDDF9EA);
    [publishButton setTitle:@"去发帖" forState:UIControlStateNormal];
    [publishButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
    publishButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [publishButton addTarget:self action:@selector(gotoPublishVoice:) forControlEvents:UIControlEventTouchUpInside];
    publishButton.hidden = YES;
    publishButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
    publishButton.layer.borderWidth = 1;
    [self.contentView addSubview:publishButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.image_view.width = 100;
    self.image_view.height = 80;
    self.image_view.centerX = self.width * 0.5;
    self.image_view.centerY = self.height * 0.5 - 55;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.centerX = self.image_view.centerX;
    self.nameLabel.y = self.image_view.bottom + 15;
    
//    self.aginButton.width = self.contentView.width;
//    self.aginButton.height = self.nameLabel.bottom - self.image_view.y;
//    self.aginButton.y = self.image_view.y;
    self.aginButton.frame = self.contentView.bounds;
    
    self.publishButton.width = 100;
    self.publishButton.height = 24;
    self.publishButton.layer.cornerRadius = self.publishButton.height * 0.5;
    self.publishButton.layer.masksToBounds = YES;
    self.publishButton.centerX = self.contentView.width * 0.5;
    self.publishButton.y = self.nameLabel.bottom + 15;
}

- (void)setSex:(NSString *)sex
{
    _sex = sex;
    
    self.image_view.image = [UIImage imageNamed:@"blank_norelease"];
    
    BOOL isSelf = [self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]];

    if (isSelf && self.type == 1) {   // 是自己
        self.nameLabel.text = @"你还没有主帖，快去发帖吧！";
        self.publishButton.hidden = NO;
    }else{
        self.publishButton.hidden = YES;
        NSString *str = @"";
        if (isSelf) {
            str = @"你";
        } else {
            if (sex.integerValue == 2) {
                str = @"她";
            }else{
                str = @"他";
            }
        }
        NSString *str1 = @"";
        if (self.type == 1) {
            str1 = @"主帖";
        } else if (self.type == 2) {
            str1 = @"回复";
        } else if (self.type == 3) {
            str1 = @"收藏";
            self.image_view.image = [UIImage imageNamed:@"blank_collect"];
        }
        if (str.length && str1.length) {
            self.nameLabel.text = [NSString stringWithFormat:@"%@还没有%@",str,str1];
        }
    }
    
    self.aginButton.hidden = YES;
    
    [self.nameLabel sizeToFit];
}

// 去发帖
- (void)gotoPublishVoice:(UIButton *)btn
{
    if (self.goToPublishVoice) {
        self.goToPublishVoice();
    }
}

- (void)setTopicNoDataName:(NSString *)topicNoDataName
{
    _topicNoDataName = topicNoDataName;
    self.image_view.image = [UIImage imageNamed:@"blank_norelease"];
    self.nameLabel.text = topicNoDataName;
}


- (void)setRequestStatus:(NSInteger)requestStatus
{
    _requestStatus = requestStatus;
    
    if (requestStatus == 1) {   // 请求成功表示没有数据
        
        self.aginButton.hidden = YES;
        self.image_view.image = [UIImage imageNamed:@"blank_norelease"];
        self.nameLabel.text = @"暂无回复，快来抢沙发吧！";
        [self.nameLabel sizeToFit];
    }else if(requestStatus == 2){   // 请求失败
        
        self.aginButton.hidden = NO;
        self.image_view.image = [UIImage imageNamed:@"blank_fail"];
        self.nameLabel.text = @"网络异常，点击重试";
        [self.nameLabel sizeToFit];
    }
}

- (void)aginRequest
{
    if (self.requestAginBlock) {
        self.requestAginBlock();
    }
}
@end
