//
//  JAMineHeaderView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/4.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMineHeaderView.h"
#import <NSButton+WebCache.h>

@interface JAMineHeaderView ()

@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIImageView *bgImageView;
@property (nonatomic, weak) UIView *levelBackView;
@property (nonatomic, weak) UIImageView *levelArrowImageView;

@end

@implementation JAMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMineHeadView];
    }
    return self;
}

- (void)setupMineHeadView
{
    UIImageView *bgImageView = [[UIImageView alloc] init];
    _bgImageView = bgImageView;
    bgImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bgImageView];
    self.bgImageView.width = self.width;
    self.bgImageView.height = self.height;
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    [self addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"----";
    nameLabel.textColor = HEX_COLOR(0x454C57);
    nameLabel.font = JA_MEDIUM_FONT(23);
    [self addSubview:nameLabel];
    
    UIView *levelBackView = [[UIView alloc] init];
    _levelBackView = levelBackView;
    levelBackView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self addSubview:levelBackView];
    
    UIButton *levelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _levelButton = levelButton;
//    [levelButton setTitle:@"茉莉奶瓶" forState:UIControlStateNormal];
//    [levelButton setImage:[UIImage imageNamed:@"lvOne"] forState:UIControlStateNormal];
    [levelButton setTitleColor:HEX_COLOR(0x9b9b9b) forState:UIControlStateNormal];
    levelButton.titleLabel.font = JA_MEDIUM_FONT(12);
    [levelBackView addSubview:levelButton];
    
    UIImageView *levelArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _levelArrowImageView = levelArrowImageView;
    [levelBackView addSubview:levelArrowImageView];
    
    UIButton *personCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _personCenterButton = personCenterButton;
    [personCenterButton setTitle:@"个人主页" forState:UIControlStateNormal];
    [personCenterButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    personCenterButton.titleLabel.font = JA_MEDIUM_FONT(15);
    [self addSubview:personCenterButton];
    
    UIImageView *arrowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowV;
    [self addSubview:arrowV];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView];
    
    JAMineWordView *publishView = [[JAMineWordView alloc] init];
    _publishView = publishView;
    publishView.bottomWord = @"发表";
    publishView.topWord = @"0";
    [self addSubview:publishView];
    
    JAMineWordView *collectView = [[JAMineWordView alloc] init];
    _collectView = collectView;
    collectView.bottomWord = @"收藏";
    collectView.topWord = @"0";
    [self addSubview:collectView];
    
    JAMineWordView *focusView = [[JAMineWordView alloc] init];
    _focusView = focusView;
    focusView.bottomWord = @"关注";
    focusView.topWord = @"0";
    [self addSubview:focusView];
    
    JAMineWordView *fansView = [[JAMineWordView alloc] init];
    _fansView = fansView;
    fansView.bottomWord = @"粉丝";
    fansView.topWord = @"0";
    [self addSubview:fansView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self caculatorMineHeadView];
}

- (void)caculatorMineHeadView
{
    self.iconImageView.height = 65;
    self.iconImageView.width = self.iconImageView.height;
    self.iconImageView.x = 20;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.clipsToBounds = YES;
    
    self.nameLabel.x = self.iconImageView.right + 15;
    self.nameLabel.width = JA_SCREEN_WIDTH - 15 - self.nameLabel.x;
    self.nameLabel.height = 25;
    self.nameLabel.y = self.iconImageView.top + 3;
    
    self.levelBackView.width = 100;
    self.levelBackView.height = 24;
    self.levelBackView.x = self.nameLabel.x;
    self.levelBackView.y = self.nameLabel.bottom + 6;
    self.levelBackView.layer.cornerRadius = self.levelBackView.height * 0.5;
    self.levelBackView.layer.masksToBounds = YES;
    
    self.levelArrowImageView.centerY = self.levelBackView.height * 0.5;
    self.levelArrowImageView.x = self.levelBackView.width - 7 - self.levelArrowImageView.width;
    
    self.levelButton.width = self.levelBackView.width-5;
    self.levelButton.height = self.levelBackView.height;
    [self.levelButton setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
    
    self.personCenterButton.width = 65;
    self.personCenterButton.height = 30;
    self.personCenterButton.x = JA_SCREEN_WIDTH - 20 - self.personCenterButton.width-8;
    self.personCenterButton.centerY = self.levelBackView.centerY;
    
    self.arrowImageView.width = 6;
    self.arrowImageView.height = 10;
    self.arrowImageView.centerY = self.personCenterButton.centerY;
    self.arrowImageView.x = self.personCenterButton.right+3;
    
    self.lineView.width = JA_SCREEN_WIDTH - 30;
    self.lineView.height = 1;
    self.lineView.x = 15;
    self.lineView.y = self.iconImageView.bottom + 25;
    
    self.publishView.width = JA_SCREEN_WIDTH / 4;
    self.publishView.height = 75;
    self.publishView.y = self.lineView.bottom;
    self.publishView.x = 0;
    
    self.collectView.width = self.publishView.width;
    self.collectView.height = self.publishView.height;
    self.collectView.y = self.lineView.bottom;
    self.collectView.x = self.publishView.right;
    
    self.focusView.width = self.publishView.width;
    self.focusView.height = self.publishView.height;
    self.focusView.y = self.lineView.bottom;
    self.focusView.x = self.collectView.right;
    
    self.fansView.width = self.publishView.width;
    self.fansView.height = self.publishView.height;
    self.fansView.y = self.lineView.bottom;
    self.fansView.x = self.focusView.right;
}

- (void)setInfoDictionary:(NSDictionary *)infoDictionary
{
    _infoDictionary = infoDictionary;
    
    NSString *imageName = [infoDictionary[@"image"] length] ? infoDictionary[@"image"] : @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
    NSString *name = [infoDictionary[@"name"] length] ? infoDictionary[@"name"] : @"昵称加载中";
//    NSString *level = [infoDictionary[@"level"] length] ? infoDictionary[@"level"] : @"1";
    NSString *publishString = [infoDictionary[@"publish"] integerValue] ? infoDictionary[@"publish"] : @"0";
    NSString *collectString = [infoDictionary[@"collect"] integerValue] ? infoDictionary[@"collect"] : @"0";
    NSString *focusString = [infoDictionary[@"focus"] integerValue] ? infoDictionary[@"focus"] : @"0";
    NSString *fansString = [infoDictionary[@"fans"] integerValue] ? infoDictionary[@"fans"] : @"0";
    NSString *markN = [infoDictionary[@"markName"] length] ? infoDictionary[@"markName"] : @"社区头衔";
    NSString *markI = [infoDictionary[@"markImage"] ja_getFitImageStringWidth:6 height:8];
    
    [self.iconImageView ja_setImageWithURLStr:imageName placeholder:[UIImage imageNamed:@"moren_nan"]];
    self.nameLabel.text = name;
    self.levelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.levelButton setTitle:[NSString stringWithFormat:@"%@",markN] forState:UIControlStateNormal];
    [self.levelButton sd_setImageWithURL:[NSURL URLWithString:markI] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"lvOne"]];
    self.publishView.topWord = publishString;
    self.collectView.topWord = collectString;
    self.focusView.topWord = focusString;
    self.fansView.topWord = fansString;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTopOffY:(CGFloat)topOffY
{
    _topOffY = topOffY;
    
    if (topOffY <= 0) {
        self.bgImageView.frame = CGRectMake(0, topOffY, JA_SCREEN_WIDTH, self.height - topOffY);
    }else{
        
    }
}

@end
