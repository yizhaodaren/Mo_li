//
//  JARelationshipTableViewCell.m
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JARelationshipTableViewCell.h"

@interface JARelationshipTableViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) UIImageView *authIV;
@property (nonatomic, strong) UIImageView *vipIV;
@property (nonatomic, strong) UIImageView *genderAndAgeIV;
@property (nonatomic, strong) UIImageView *levelIV;

@property (nonatomic, assign) BOOL isFriend;

@end

@implementation JARelationshipTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isFriend:(BOOL)isFriend {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isFriend = isFriend;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.backgroundColor = HEX_COLOR(JA_Background);
        
        self.headImageView = [UIImageView new];
        //        self.headImageView.backgroundColor = [UIColor redColor];
        self.headImageView.layer.cornerRadius = 45 * 0.5;
        self.headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        //        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.offset(14);
        //            make.centerY.equalTo(self.contentView.mas_centerY);
        //            make.width.offset(45);
        //            make.height.equalTo(self.headImageView.mas_width);
        //        }];
        self.headImageView.frame = CGRectMake(14, 0, 45, 45);
        self.headImageView.centerY = 35;
        
        self.nicknameLabel = [UILabel new];
        //        self.nicknameLabel.backgroundColor = [UIColor greenColor];
        self.nicknameLabel.textColor = HEX_COLOR(JA_BlackTitle);
        self.nicknameLabel.font = JA_LIGHT_FONT(16);
        [self.contentView addSubview:self.nicknameLabel];
        //        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.headImageView.mas_top);
        //            make.left.equalTo(self.headImageView.mas_right).offset(14);
        //            make.height.offset(22);
        //        }];
        //        self.nicknameLabel.frame = CGRectMake(self.headImageView.right+14, self.headImageView.y, 0, 22);
        
        self.genderAndAgeIV = [UIImageView new];
        [self.contentView addSubview:self.genderAndAgeIV];
        //        [self.genderAndAgeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.vipIV.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //            make.height.offset(12);
        //        }];
        //        self.genderAndAgeIV.frame = CGRectMake(self.nicknameLabel.right+5, 0, 26, 12);
        //        self.genderAndAgeIV.centerY = self.nicknameLabel.centerY;
        
        self.ageLabel = [UILabel new];
        self.ageLabel.textColor = HEX_COLOR(0xffffff);
        self.ageLabel.font = JA_REGULAR_FONT(10);
        [self.genderAndAgeIV addSubview:self.ageLabel];
        //        [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.genderAndAgeIV.mas_top);
        //            make.left.equalTo(self.genderAndAgeIV.mas_left).offset(13);
        //            make.bottom.equalTo(self.genderAndAgeIV.mas_bottom);
        //            make.right.equalTo(self.genderAndAgeIV.mas_right).offset(-2);
        //        }];
        
        self.introduceLabel = [UILabel new];
        //        self.introduceLabel.backgroundColor = [UIColor redColor];
        self.introduceLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        self.introduceLabel.font = JA_REGULAR_FONT(13);
        [self.contentView addSubview:self.introduceLabel];
        //        [self.introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.headImageView.mas_right).offset(14);
        //            make.bottom.equalTo(self.headImageView.mas_bottom);
        //            make.height.offset(self.introduceLabel.font.lineHeight);
        //        }];
        CGFloat introduceLeft = self.headImageView.right+14;
        self.introduceLabel.frame = CGRectMake(introduceLeft, 0, JA_SCREEN_WIDTH-introduceLeft-60-14-10, self.introduceLabel.font.lineHeight);
        self.introduceLabel.bottom = self.headImageView.bottom;
        
        //        UIView *identifierView = [UIView new];
        //        identifierView.backgroundColor = [UIColor greenColor];
        //        [self.contentView addSubview:identifierView];
        //        [identifierView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.nicknameLabel.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //
        //            make.height.offset(34);
        //        }];
        
        //        self.authIV = [UIImageView new];
        //        self.authIV.image = [UIImage imageNamed:@"person_auth"];
        //        [identifierView addSubview:self.authIV];
        //        [self.authIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(identifierView.mas_left).offset(0);
        ////            make.left.equalTo(self.nicknameLabel.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //            make.width.offset(0);
        //        }];
        //        [self.authIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        //        self.vipIV = [UIImageView new];
        //        self.vipIV.image = [UIImage imageNamed:@"person_vip"];
        //        [identifierView addSubview:self.vipIV];
        //        [self.vipIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.authIV.mas_right).offset(0);
        ////            make.left.equalTo(self.authIV.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //            make.width.offset(0);
        //        }];
        //        [self.vipIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        //        self.genderAndAgeIV = [UIImageView new];
        //        [identifierView addSubview:self.genderAndAgeIV];
        //        [self.genderAndAgeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.vipIV.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //            make.height.offset(12);
        //        }];
        //        [self.genderAndAgeIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        //
        //        self.ageLabel = [UILabel new];
        //        self.ageLabel.textColor = HEX_COLOR(0xffffff);
        //        self.ageLabel.font = JA_REGULAR_FONT(10);
        //        [self.genderAndAgeIV addSubview:self.ageLabel];
        //        [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.genderAndAgeIV.mas_top);
        //            make.left.equalTo(self.genderAndAgeIV.mas_left).offset(13);
        //            make.bottom.equalTo(self.genderAndAgeIV.mas_bottom);
        //            make.right.equalTo(self.genderAndAgeIV.mas_right).offset(-2);
        //        }];
        //        [self.ageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        //        self.levelIV = [UIImageView new];
        //        self.levelIV.image = [[UIImage imageNamed:@"person_lervel"] stretchableImageWithLeftCapWidth:16 topCapHeight:6];
        //        [identifierView addSubview:self.levelIV];
        //        [self.levelIV mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.genderAndAgeIV.mas_right).offset(5);
        //            make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        //            make.right.equalTo(identifierView.mas_right).offset(0);
        //            make.height.offset(0);
        //        }];
        //        [self.levelIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        //
        //        self.levelLabel = [UILabel new];
        //        self.levelLabel.textColor = HEX_COLOR(0xffffff);
        //        self.levelLabel.font = JA_REGULAR_FONT(10);
        //        [self.levelIV addSubview:self.levelLabel];
        //        [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.levelIV.mas_top);
        //            make.left.equalTo(self.levelIV.mas_left).offset(16);
        //            make.bottom.equalTo(self.levelIV.mas_bottom);
        //            make.right.equalTo(self.levelIV.mas_right).offset(-2);
        //        }];
        
        self.focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        self.focusButton.backgroundColor = [UIColor redColor];
        self.focusButton.titleLabel.font = JA_REGULAR_FONT(12);
        self.focusButton.layer.cornerRadius = 12.50;
        self.focusButton.layer.masksToBounds = YES;
        self.focusButton.layer.borderColor = [HEX_COLOR(JA_Green) CGColor];
        [self.focusButton addTarget:self action:@selector(focusAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.focusButton];
        //        [self.focusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.right.offset(-14);
        //            make.centerY.equalTo(self.headImageView.mas_centerY);
        ////            if (isFriend) {
        ////            } else {
        ////                make.size.mas_equalTo(CGSizeMake(55, 25));
        ////            }
        //            make.size.mas_equalTo(CGSizeMake(60, 25));
        //
        //            make.left.greaterThanOrEqualTo(self.introduceLabel.mas_right).offset(10);
        //            make.left.greaterThanOrEqualTo(identifierView.mas_right).offset(10);
        //        }];
        self.focusButton.frame = CGRectMake(0, 0, 60, 25);
        self.focusButton.right = JA_SCREEN_WIDTH-14;
        self.focusButton.centerY = self.headImageView.centerY;
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEX_COLOR(JA_Line);;
        [self.contentView addSubview:lineView];
        //        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.nicknameLabel.mas_left);
        //            make.right.bottom.offset(0);
        //            make.height.offset(1);
        //        }];
        lineView.frame = CGRectMake(self.nicknameLabel.left, 0, JA_SCREEN_WIDTH-self.nicknameLabel.left, 1);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nicknameLabel.x = self.headImageView.right+14;
    self.nicknameLabel.y = self.headImageView.y;
    self.nicknameLabel.height = 22;
    
    if (self.nicknameLabel.width > 180) {
        self.nicknameLabel.width = 180;
    }
    
    self.genderAndAgeIV.width = 26;
    self.genderAndAgeIV.height = 12;
    self.genderAndAgeIV.x = self.nicknameLabel.right+5;
    self.genderAndAgeIV.centerY = self.nicknameLabel.centerY;
    
    self.ageLabel.height = self.genderAndAgeIV.height;
    if ([self.ageLabel.text integerValue] >= 10) {
        self.ageLabel.x = 11;
    } else {
        self.ageLabel.x = 13;
    }
    self.ageLabel.y = 0;
    
    //    [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.genderAndAgeIV.mas_top);
    //        make.left.equalTo(self.genderAndAgeIV.mas_left).offset(13);
    //        make.bottom.equalTo(self.genderAndAgeIV.mas_bottom);
    //        make.right.equalTo(self.genderAndAgeIV.mas_right).offset(-2);
    //    }];
    
}

- (void)setData:(JAConsumer *)data {
    _data = data;
    self.ageLabel.text = data.age;
    [self.ageLabel sizeToFit];
    
    if (data.sex.integerValue == 1) {
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_man"];
    }else{
        
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_woman"];
    }
    //    self.levelLabel.text = data.levelId;
    
    int h = 25;
    int w = h;
    NSString *url = [data.image ja_getFitImageStringWidth:w height:h];
    
    [self.headImageView ja_setImageWithURLStr:url];
    
    
    self.nicknameLabel.text = data.name;
    [self.nicknameLabel sizeToFit];
    
    NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:data.userId] ? @"你还没有个性签名" : @"他还没有个性签名";
    
    self.introduceLabel.text = data.introduce.length ? data.introduce : introductionStr;
    
    if ([self.data.friendType integerValue] == 0) {
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
        
        //        self.focusButton.userInteractionEnabled = YES;
    } else if([self.data.friendType integerValue] == 1) {
        self.focusButton.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"相互关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 0;
        
        //        self.focusButton.userInteractionEnabled = NO;
    } else {
        self.focusButton.backgroundColor = [UIColor clearColor];
        [self.focusButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [self.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
        self.focusButton.layer.borderWidth = 1;
        
        //        self.focusButton.userInteractionEnabled = YES;
    }
    NSString *localID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    if ([localID isEqualToString:data.consumerId]) {
        self.focusButton.hidden = YES;
    } else {
        self.focusButton.hidden = NO;
    }
}

- (void)focusAction {
    if (self.focusActionBlock) {
        self.focusActionBlock(self);
    }
}

@end

