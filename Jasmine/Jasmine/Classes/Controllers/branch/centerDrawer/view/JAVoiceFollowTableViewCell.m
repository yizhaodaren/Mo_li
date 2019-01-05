//
//  JAVoiceFollowTableViewCell.m
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceFollowTableViewCell.h"

@interface JAVoiceFollowTableViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
//@property (nonatomic, strong) UIButton *ageButton;
//@property (nonatomic, strong) UIButton *levelButton;

@property (nonatomic, strong) UILabel *introduceLabel;
//@property (nonatomic, strong) UILabel *releaseLabel;
//@property (nonatomic, strong) UILabel *agreeLabel;
//@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIView *tapView;

@end

@implementation JAVoiceFollowTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = HEX_COLOR(JA_Background);
        
        UIImageView *headImageView = [UIImageView new];
        //        self.headImageView.backgroundColor = [UIColor redColor];
        headImageView.layer.cornerRadius = 40/2.0;
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
        headImageView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
        headImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:headImageView];
        self.headImageView = headImageView;
        
        UILabel *nicknameLabel = [UILabel new];
        //        self.nicknameLabel.backgroundColor = [UIColor greenColor];
        nicknameLabel.textColor = HEX_COLOR(0x576B95);
        nicknameLabel.font = JA_REGULAR_FONT(15);
        nicknameLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:nicknameLabel];
        self.nicknameLabel = nicknameLabel;
        
        // 年龄 - 性别
//        UIButton *ageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [ageButton setTitle:@" " forState:UIControlStateNormal];
//        [ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
//        [ageButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
//        ageButton.titleLabel.font = JA_REGULAR_FONT(10);
//        ageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//        ageButton.layer.cornerRadius = 2;
//        [self.contentView addSubview:ageButton];
//        self.ageButton = ageButton;
//
//        UIButton *levelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [levelButton setTitle:@"lv1" forState:UIControlStateNormal];
////        [levelButton setBackgroundImage:[UIImage imageNamed:@"person_lervel"] forState:UIControlStateNormal];
//        [levelButton setBackgroundImage:[[UIImage imageNamed:@"person_lervel"] stretchableImageWithLeftCapWidth:16 topCapHeight:6] forState:UIControlStateNormal];
//        [levelButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
//        levelButton.titleLabel.font = JA_REGULAR_FONT(10);
//        levelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
//        levelButton.layer.cornerRadius = 2;
////        [self.contentView addSubview:levelButton];
//        self.levelButton = levelButton;
        
        UILabel *introduceLabel = [UILabel new];
        introduceLabel.backgroundColor = [UIColor clearColor];
        introduceLabel.text = @"这家伙很懒什么也没有留下！";
        introduceLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        introduceLabel.font = JA_REGULAR_FONT(12);
        [self.contentView addSubview:introduceLabel];
        self.introduceLabel = introduceLabel;
        
//        UILabel *releaseLabel = [UILabel new];
//        releaseLabel.backgroundColor = [UIColor clearColor];
//        releaseLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
//        releaseLabel.font = JA_REGULAR_FONT(10);
//        releaseLabel.frame = CGRectMake(self.nicknameLabel.x, self.nicknameLabel.bottom, 100, 14);
////        [self.contentView addSubview:releaseLabel];
//        self.releaseLabel = releaseLabel;
//
//        UILabel *agreeLabel = [UILabel new];
//        agreeLabel.backgroundColor = [UIColor clearColor];
//        agreeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
//        agreeLabel.font = JA_REGULAR_FONT(10);
//        agreeLabel.frame = CGRectMake(0, self.releaseLabel.y, 100, 14);
////        [self.contentView addSubview:agreeLabel];
//        self.agreeLabel = agreeLabel;
        
        UIView *tapView = [UIView new];
        [self.contentView addSubview:tapView];
        self.tapView = tapView;
        [tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];

        UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _focusButton = focusButton;
        [focusButton setImage:[UIImage imageNamed:@"circle_unFocus"] forState:UIControlStateNormal];
        [focusButton setImage:[UIImage imageNamed:@"circle_unFocus"] forState:UIControlStateHighlighted];
        [focusButton setImage:[UIImage imageNamed:@"detail_followed"] forState:UIControlStateSelected];
        [focusButton setImage:[UIImage imageNamed:@"detail_followed"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [focusButton addTarget:self action:@selector(focusButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:focusButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 69, JA_SCREEN_WIDTH, 1)];
        lineView.backgroundColor = HEX_COLOR(JA_Line);
        [self.contentView addSubview:lineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];

    }
    return self;
}

#pragma mark - 刷新关注按钮
- (void)refreshFocusStatusTrue:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.data.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.focusButton.selected = YES;
        if (self.followCountBlock) {
            self.followCountBlock();
        }
    }
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.data.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.focusButton.selected = NO;
        if (self.followCountBlock) {
            self.followCountBlock();
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.headImageView.width = self.headImageView.height = 40;
    self.headImageView.x = 15;
    self.headImageView.centerY = self.contentView.height/2.0;

    self.nicknameLabel.height = 18;
    self.nicknameLabel.x = self.headImageView.right+10;
    self.nicknameLabel.y = self.headImageView.top;

    self.focusButton.width = 50;
    self.focusButton.height = 23;
    self.focusButton.centerY = self.headImageView.centerY;
    self.focusButton.right = self.contentView.right-10;
    
    self.introduceLabel.x = self.nicknameLabel.x;
    self.introduceLabel.width = self.focusButton.x - self.introduceLabel.x - 5;
    self.introduceLabel.height = 14;
    self.introduceLabel.bottom = self.headImageView.bottom;
    
    self.tapView.height = self.contentView.height;
    self.tapView.width = self.focusButton.x-10;
}

- (void)setData:(JAVoiceFollowModel *)data {
    _data = data;
//    data.levelId = @"1000";
    if (data) {
        int h = 35;
        int w = h;
        NSString *url = [data.image ja_getFitImageStringWidth:w height:h];
        [self.headImageView ja_setImageWithURLStr:url];
        self.nicknameLabel.text = data.name;
        [self.nicknameLabel sizeToFit];
        // 性别、年龄
//        if ([data.sex integerValue] == 1) {
//            [self.ageButton setTitle:data.age forState:UIControlStateNormal];
//            [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
//        }else{
//            [self.ageButton setTitle:data.age forState:UIControlStateNormal];
//            [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_woman"] forState:UIControlStateNormal];
//        }
//
//        [self.levelButton setTitle:data.levelId forState:UIControlStateNormal];
//        self.levelButton.width = [data.levelId sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(10)}].width + 15;
        
        NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:data.userId] ? @"你还没有个性签名" : @"他还没有个性签名";
        
        self.introduceLabel.text = data.introduce.length ? data.introduce : introductionStr;
        [self.introduceLabel sizeToFit];

        self.focusButton.selected = ([data.friendType integerValue] == 0 || [data.friendType integerValue] == 1)?YES:NO;

        
//        if (data.isSelected) {
//            self.selectedImageView.image = [UIImage imageNamed:@"voice_follow_sel"];
//        } else {
//            self.selectedImageView.image = [UIImage imageNamed:@"voice_follow"];
//        }
        
//        self.releaseLabel.text = [NSString stringWithFormat:@"发帖%@",self.data.storyCount];
//
//        NSString *str = [NSString stringWithFormat:@"%@",self.data.agreeCount];
//        if (self.data.agreeCount.integerValue > 10000) {
//            str = [NSString stringWithFormat:@"%.1fw",self.data.agreeCount.integerValue / 10000.0];
//        }
//        self.agreeLabel.text = [NSString stringWithFormat:@"获赞%@",str];
    }
}

- (void)userInfoAction {
    if (self.headActionBlock) {
        self.headActionBlock(self);
    }
}

- (void)focusButtonAction {
    if (self.followBlock) {
        self.followBlock(self);
    }
}

@end
