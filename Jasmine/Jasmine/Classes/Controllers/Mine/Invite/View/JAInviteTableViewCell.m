//
//  JAInviteTableViewCell.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteTableViewCell.h"





@interface JAInviteTableViewCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;  // 个性签名
@property (nonatomic, strong) UIButton *addButton;   // 邀请

@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UIImageView *authIV;
@property (nonatomic, strong) UIImageView *vipIV;
@property (nonatomic, strong) UIImageView *genderAndAgeIV;
@property (nonatomic, strong) UIImageView *levelIV;


@end


@implementation JAInviteTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = HEX_COLOR(JA_Background);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews
{
    self.imgView = [UIImageView new];
    //        self.headImageView.backgroundColor = [UIColor redColor];
    self.imgView.layer.cornerRadius = 45 * 0.5;
    self.imgView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(14);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.offset(45);
        make.height.equalTo(self.imgView.mas_width);
    }];
    
    self.nameLabel = [UILabel new];
    //        self.nameLabel.backgroundColor = [UIColor greenColor];
    self.nameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.nameLabel.font = JA_LIGHT_FONT(16);
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_top);
        make.left.equalTo(self.imgView.mas_right).offset(14);
        make.height.offset(22);
    }];
    
    self.contentLabel = [UILabel new];
    //        self.introduceLabel.backgroundColor = [UIColor redColor];
    self.contentLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.contentLabel.font = JA_REGULAR_FONT(13);
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgView.mas_right).offset(14);
        make.bottom.equalTo(self.imgView.mas_bottom);
        make.height.offset(self.contentLabel.font.lineHeight);
    }];
    
    UIView *identifierView = [UIView new];
    //        identifierView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:identifierView];
    [identifierView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        
        make.height.offset(34);
    }];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //        self.focusButton.backgroundColor = [UIColor redColor];
    self.addButton.titleLabel.font = JA_REGULAR_FONT(12);
    self.addButton.layer.cornerRadius = 12.50;
    self.addButton.layer.masksToBounds = YES;
    self.addButton.layer.borderColor = [HEX_COLOR(JA_Green) CGColor];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-14);
        make.centerY.equalTo(self.imgView.mas_centerY);
        //            if (isFriend) {
        //            } else {
        //                make.size.mas_equalTo(CGSizeMake(55, 25));
        //            }
        make.size.mas_equalTo(CGSizeMake(60, 25));
        
        make.left.greaterThanOrEqualTo(self.contentLabel.mas_right).offset(10);
        make.left.greaterThanOrEqualTo(identifierView.mas_right).offset(10);
    }];
    [self.addButton addTarget:self action:@selector(buttonResponse:) forControlEvents:UIControlEventTouchUpInside];
    
    self.authIV = [UIImageView new];
    self.authIV.image = [UIImage imageNamed:@"person_auth"];
    [identifierView addSubview:self.authIV];
    [self.authIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(identifierView.mas_left).offset(0);
        //            make.left.equalTo(self.nameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.width.offset(0);
    }];
    [self.authIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.vipIV = [UIImageView new];
    self.vipIV.image = [UIImage imageNamed:@"person_vip"];
    [identifierView addSubview:self.vipIV];
    [self.vipIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.authIV.mas_right).offset(0);
        //            make.left.equalTo(self.authIV.mas_right).offset(5);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.width.offset(0);
    }];
    [self.vipIV setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.genderAndAgeIV = [UIImageView new];
    [identifierView addSubview:self.genderAndAgeIV];
    [self.genderAndAgeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.vipIV.mas_right).offset(5);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
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
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.right.equalTo(identifierView.mas_right).offset(0);
        make.height.offset(0);
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
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.bottom.offset(0);
        make.height.offset(1);
    }];

}

- (void)setData:(JAConsumer *)data
{
    _data = data;
    
    self.ageLabel.text = data.age;
    if([data.sex integerValue] == 1)
    {
        NSString *url = data.image.length ? data.image : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
        [self.imgView ja_setImageWithURLStr:url];
        
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_man"];
        
    }else{
        NSString *url = data.image.length ? data.image : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/usergirl_01.png";
        [self.imgView ja_setImageWithURLStr:url];
        
        self.genderAndAgeIV.image = [UIImage imageNamed:@"person_woman"];
    }
    
    if (data.name)
    {
        self.nameLabel.text = data.name;
    }
    
//    NSString *str1 = data.storyCount.length ? data.storyCount : @"0";
//    NSString *str2 = data.agreeCount.length ? data.agreeCount : @"0";
//    self.contentLabel.text = [NSString stringWithFormat:@"发帖%@  获赞%@",str1,str2];
    
    NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:data.userId] ? @"你还没有个性签名" : @"他还没有个性签名";
    
    NSString *str1 = data.introduce.length ? data.introduce : introductionStr;
    self.contentLabel.text = [NSString stringWithFormat:@"%@",str1];
   
    if (data.inviteStatus.length && [data.inviteStatus integerValue] > 0) {
        self.addButton.backgroundColor = HEX_COLOR(0xf4f4f4);
        [self.addButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        [self.addButton setTitle:@"已邀请" forState:UIControlStateNormal];
        self.addButton.layer.borderWidth = 0;
    } else{
        self.addButton.backgroundColor = HEX_COLOR(JA_Branch_Green);
        [self.addButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
        [self.addButton setTitle:@"邀请" forState:UIControlStateNormal];
        self.addButton.layer.borderWidth = 1;
    }
}

- (void)buttonResponse:(UIButton *)button
{
    if (self.controlBlock)
    {
        self.controlBlock(self);
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
