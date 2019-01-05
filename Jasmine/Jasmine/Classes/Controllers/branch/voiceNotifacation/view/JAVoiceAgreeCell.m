//
//  JAVoiceReplyCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceAgreeCell.h"

@interface JAVoiceAgreeCell ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *operationLbel;
@property (nonatomic, weak) UIImageView *unreadImageView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *replyPlayButton;
@property (nonatomic, weak) UILabel *replyTitleLabel;

@property (nonatomic, weak) UIView *lineView;

@end

@implementation JAVoiceAgreeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVoiceAgreeCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupVoiceAgreeCell
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    iconImageView.userInteractionEnabled = YES;
    [iconImageView addGestureRecognizer:tap1];
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    [self.contentView addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"小茉莉";
    nameLabel.textColor = HEX_COLOR(JA_Title);
    nameLabel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenterVC)];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap2];
    [self.contentView addSubview:nameLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"刚刚";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
    timeLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    UILabel *operationLbel = [[UILabel alloc] init];
    _operationLbel = operationLbel;
    operationLbel.text = @"喜欢了你的帖子";
    operationLbel.textColor = HEX_COLOR(JA_BlackSubTitle);
    operationLbel.font = JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont);
    [self.contentView addSubview:operationLbel];
    
    UIImageView *unreadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_noti_unread"]];
    _unreadImageView = unreadImageView;
    [self.contentView addSubview:unreadImageView];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(0xF5F5F5);
    [self.contentView addSubview:bottomView];
    
    UIButton *replyPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replyPlayButton = replyPlayButton;
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateNormal];
    [replyPlayButton setImage:[UIImage imageNamed:@"branch_voice_smallPlay"] forState:UIControlStateSelected];
    [bottomView addSubview:replyPlayButton];
    
    
    UILabel *replyTitleLabel = [[UILabel alloc] init];
    _replyTitleLabel = replyTitleLabel;
    replyTitleLabel.text = @"测试回复标题";
    replyTitleLabel.textColor = HEX_COLOR(0x4A4A4A);
    replyTitleLabel.font = JA_REGULAR_FONT(JA_CommentDetail_commentFont);
    [bottomView addSubview:replyTitleLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCommonCommentCell];
}

- (void)caculatorCommonCommentCell
{
    self.iconImageView.height = 35;
    self.iconImageView.width = self.iconImageView.height;
    self.iconImageView.x = 15;
    self.iconImageView.y = 15;
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.x = self.iconImageView.right + 10;
    self.nameLabel.y = 14;
    self.nameLabel.height = 20;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.nameLabel.x;
    self.timeLabel.y = self.nameLabel.bottom;
    self.timeLabel.height = 14;
    self.timeLabel.width = 150;
    
    [self.operationLbel sizeToFit];
    self.operationLbel.height = 18;
    self.operationLbel.x = self.nameLabel.right + 10;
    self.operationLbel.y = self.nameLabel.y;
    
    self.unreadImageView.x = self.operationLbel.right + 3;
    self.unreadImageView.centerY = self.operationLbel.centerY;
    
    self.bottomView.x = self.timeLabel.x;
    self.bottomView.y = self.timeLabel.bottom + 9;
    self.bottomView.width = JA_SCREEN_WIDTH - self.timeLabel.x - 15;
    self.bottomView.height = 30;
    
    self.replyPlayButton.width = 20;
    self.replyPlayButton.height = self.replyPlayButton.width;
    self.replyPlayButton.x = 8;
    self.replyPlayButton.y = 5;
    
    [self.replyTitleLabel sizeToFit];
    self.replyTitleLabel.x = self.replyPlayButton.right + 5;
    self.replyTitleLabel.width = self.bottomView.width - self.replyTitleLabel.x;
    self.replyTitleLabel.centerY = self.replyPlayButton.centerY;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JANotiModel *)model
{
    _model = model;
    
    int h = 35;
    int w = h;
    NSString *url = [model.user.img ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:url];
    
    self.nameLabel.text = model.user.nick;
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:model.time.doubleValue];
    
    self.operationLbel.text = @"喜欢了你"; //model.msgContent;
    
    NSString *str = ![model.content.type isEqualToString:@"story"] ? @"我的回复：" : @"我的主帖：";
    
    self.replyTitleLabel.text = [NSString stringWithFormat:@"%@%@",str,model.content.content];
//    self.replyTitleLabel.text = model.content.content;
    
    if (model.readState) {  // 0 未读  1 已读
        
        //        self.contentView.backgroundColor = [UIColor whiteColor];
        self.unreadImageView.hidden = YES;
    }else{
        //        self.contentView.backgroundColor = HEX_COLOR_ALPHA(JA_Green, 0.05);
        self.unreadImageView.hidden = NO;
    }
}


- (void)jumpPersonCenterVC
{
    if (self.jumpPersonalCenterBlock) {
        self.jumpPersonalCenterBlock(self);
    }
}

@end

