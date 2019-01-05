//
//  JARelationshipTableViewCell.m
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABlackPersonCell.h"

@interface JABlackPersonCell ()

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

@implementation JABlackPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = HEX_COLOR(JA_Background);
    
    self.headImageView = [UIImageView new];
    //        self.headImageView.backgroundColor = [UIColor redColor];
    self.headImageView.layer.cornerRadius = 4;
    self.headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(14);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.offset(45);
        make.height.equalTo(self.headImageView.mas_width);
    }];
    
    self.nicknameLabel = [UILabel new];
    //        self.nicknameLabel.backgroundColor = [UIColor greenColor];
    self.nicknameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.nicknameLabel.font = JA_LIGHT_FONT(16);
    [self.contentView addSubview:self.nicknameLabel];
    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_top);
        make.left.equalTo(self.headImageView.mas_right).offset(14);
        make.height.offset(22);
    }];
    
    self.introduceLabel = [UILabel new];
    //        self.introduceLabel.backgroundColor = [UIColor redColor];
    self.introduceLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.introduceLabel.font = JA_REGULAR_FONT(13);
    [self.contentView addSubview:self.introduceLabel];
    [self.introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(14);
        make.bottom.equalTo(self.headImageView.mas_bottom);
        make.height.offset(self.introduceLabel.font.lineHeight);
        make.right.equalTo(self.contentView.mas_right).offset(-14);
    }];
    
    UIView *identifierView = [UIView new];
    //        identifierView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:identifierView];
    [identifierView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nicknameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        
        make.height.offset(34);
    }];
    
    self.authIV = [UIImageView new];
    self.authIV.image = [UIImage imageNamed:@"person_auth"];
    [identifierView addSubview:self.authIV];
    [self.authIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(identifierView.mas_left).offset(0);
        //            make.left.equalTo(self.nicknameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        make.width.offset(0);
    }];
    [self.authIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.vipIV = [UIImageView new];
    self.vipIV.image = [UIImage imageNamed:@"person_vip"];
    [identifierView addSubview:self.vipIV];
    [self.vipIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.authIV.mas_right).offset(0);
        //            make.left.equalTo(self.authIV.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        make.width.offset(0);
    }];
    [self.vipIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.genderAndAgeIV = [UIImageView new];
    [identifierView addSubview:self.genderAndAgeIV];
    [self.genderAndAgeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.vipIV.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        make.height.offset(12);
    }];
    [self.genderAndAgeIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.ageLabel = [UILabel new];
    self.ageLabel.textColor = HEX_COLOR(0xffffff);
    self.ageLabel.font = JA_REGULAR_FONT(10);
    [self.genderAndAgeIV addSubview:self.ageLabel];
    [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderAndAgeIV.mas_top);
        make.left.equalTo(self.genderAndAgeIV.mas_left).offset(13);
        make.bottom.equalTo(self.genderAndAgeIV.mas_bottom);
        make.right.equalTo(self.genderAndAgeIV.mas_right).offset(-2);
    }];
    [self.ageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    self.levelIV = [UIImageView new];
    self.levelIV.image = [[UIImage imageNamed:@"person_lervel"] stretchableImageWithLeftCapWidth:16 topCapHeight:6];
    [identifierView addSubview:self.levelIV];
    [self.levelIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.genderAndAgeIV.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY);
        make.right.equalTo(identifierView.mas_right).offset(0);
        make.height.offset(12);
    }];
    [self.levelIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.levelLabel = [UILabel new];
    self.levelLabel.textColor = HEX_COLOR(0xffffff);
    self.levelLabel.font = JA_REGULAR_FONT(10);
    [self.levelIV addSubview:self.levelLabel];
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.levelIV.mas_top);
        make.left.equalTo(self.levelIV.mas_left).offset(16);
        make.bottom.equalTo(self.levelIV.mas_bottom);
        make.right.equalTo(self.levelIV.mas_right).offset(-2);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEX_COLOR(JA_Line);;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nicknameLabel.mas_left);
        make.right.bottom.offset(0);
        make.height.offset(1);
    }];
 
}

- (void)setData:(JAConsumer *)data {
    _data = data;
    self.ageLabel.text = data.age.length ? data.age : @"--";
    self.levelIV.hidden = YES;
    self.levelLabel.hidden = YES;
    if([data.sex integerValue] == 1)
    {
        self.genderAndAgeIV.hidden = NO;
        self.ageLabel.hidden = NO;
        NSString *url = data.image.length ? data.image : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
        [self.headImageView ja_setImageWithURLStr:url];
        
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_man"];
        
    }else if([data.sex integerValue] == 2){
        self.genderAndAgeIV.hidden = NO;
        self.ageLabel.hidden = NO;
        NSString *url = data.image.length ? data.image : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/usergirl_01.png";
        [self.headImageView ja_setImageWithURLStr:url];
        
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_woman"];
    }else{
        NSString *url = data.image.length ? data.image : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
        [self.headImageView ja_setImageWithURLStr:url];
        self.genderAndAgeIV.hidden = YES;
        self.ageLabel.hidden = YES;
    }
    self.nicknameLabel.text = data.name;
    
    NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:data.userId] ? @"你还没有个性签名" : @"他还没有个性签名";
    
    self.introduceLabel.text = data.introduce.length ? data.introduce : introductionStr;
   
}


@end
