//
//  JASearchPictureTextCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASearchPictureTextCell.h"
#import "JAConsumer.h"
#import "JAVoicePersonApi.h"

@interface JASearchPictureTextCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UIImageView *jumpImageView;

@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *lervelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lervelButtonLayout;


@property (nonatomic, weak) UIView *lineView;

@end
@implementation JASearchPictureTextCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle =UITableViewCellSelectionStyleNone;
    
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    self.contentView.backgroundColor = HEX_COLOR(JA_Background); 
    self.nameLabel.textColor = HEX_COLOR(0x525252);
    self.nameLabel.font = JA_MEDIUM_FONT(14);
    self.subTitleLabel.textColor = HEX_COLOR(0x4a4a4a);
    self.subTitleLabel.font = JA_LIGHT_FONT(13);
    self.describeLabel.textColor = HEX_COLOR(0x9b9b9b);
    self.describeLabel.font = JA_REGULAR_FONT(11);
    
    self.focusButton.titleLabel.font = JA_REGULAR_FONT(12);
    [self.focusButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    self.focusButton.layer.cornerRadius = 12.5;
    self.focusButton.clipsToBounds = YES;
    self.focusButton.layer.borderWidth = 1;
    self.focusButton.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
    self.focusButton.backgroundColor = HEX_COLOR(0x6BD379);
    
    [self.focusButton setTitle:@"关注" forState:UIControlStateNormal];
    self.focusButton.hidden = YES;
    [self.focusButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateSelected];
    
    self.jumpImageView.hidden = YES;
    
    [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
    [self.lervelButton setBackgroundImage:[[UIImage imageNamed:@"person_lervel"] stretchableImageWithLeftCapWidth:16 topCapHeight:6] forState:UIControlStateNormal];
    [self.ageButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [self.lervelButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    self.ageButton.titleLabel.font = JA_REGULAR_FONT(10);
    self.lervelButton.titleLabel.font = JA_REGULAR_FONT(10);
    self.ageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
    self.lervelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];
}

- (void)refreshFocusStatusTrue:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.consumerModel.consumerId.length ? self.consumerModel.consumerId : self.consumerModel.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.consumerModel.friendType = dic[@"status"];
        self.focusButton.hidden = YES;
        self.jumpImageView.hidden = NO;
    }
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.consumerModel.consumerId.length ? self.consumerModel.consumerId : self.consumerModel.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.consumerModel.friendType = dic[@"status"];
        self.focusButton.hidden = NO;
        self.jumpImageView.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lineView.x = 14;
    self.lineView.width = self.contentView.width - 14;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



- (void)setConsumerModel:(JAConsumer *)consumerModel
{
    _consumerModel = consumerModel;
//    consumerModel.levelId = @"1000";
    self.ageButton.hidden = NO;
    self.lervelButton.hidden = YES;
    if (consumerModel.sex.integerValue == 1) {
        [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_man"] forState:UIControlStateNormal];
    }else{
        [self.ageButton setBackgroundImage:[UIImage imageNamed:@"person_woman"] forState:UIControlStateNormal];
    }
    
    [self.lervelButton setTitle:consumerModel.levelId forState:UIControlStateNormal];
    self.lervelButtonLayout.constant = [consumerModel.levelId sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(10)}].width + 15;
    
    int h = 35;
    int w = 35;
    NSString *imageurl = [consumerModel.image ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:imageurl];
    
//    self.nameLabel.text = consumerModel.name;
    [self.nameLabel setAttributedText:[self attributedString:consumerModel.name word:self.keyWord]];
    self.subTitleLabel.text = [NSString stringWithFormat:@"ID:%@ 粉丝:%@",consumerModel.uuid,consumerModel.concernUserCount];
    NSString *idString = [NSString stringWithFormat:@"ID:%@",consumerModel.uuid];
    NSString *fansString = [NSString stringWithFormat:@" 粉丝:%@",consumerModel.concernUserCount];
    NSMutableAttributedString *str = [self attributedString:idString word:self.keyWord];
    NSMutableAttributedString *fansStr = [[NSMutableAttributedString alloc] initWithString:fansString];
    [str appendAttributedString:fansStr];
    [self.subTitleLabel setAttributedText:str];
    
    NSString *introductionStr = [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:consumerModel.userId] ? @"你还没有个性签名" : @"他还没有个性签名";
    self.describeLabel.text = consumerModel.introduce.length ? consumerModel.introduce : introductionStr;
    
    [self.ageButton setTitle:consumerModel.age forState:UIControlStateNormal];
  
    
    // 如果有关注的 改变按钮的状态
    if ([consumerModel.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        self.focusButton.hidden = YES;
        self.jumpImageView.hidden = NO;
    }else{
        
        if (consumerModel.friendType.integerValue == 0 || consumerModel.friendType.integerValue == 1) {
            self.focusButton.hidden = YES;
            self.jumpImageView.hidden = NO;
            
        }else{
            self.focusButton.hidden = NO;
            self.jumpImageView.hidden = YES;
        }
    }
}

- (IBAction)clickFocusButton:(UIButton *)sender
{
    // 关注
    [self focusCustomer:sender];
}


// 关注人
- (void)focusCustomer:(UIButton *)btn
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    btn.userInteractionEnabled = NO;
//    if (btn.selected) {
//
//        // 取消关注
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//
//        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        dic[@"concernId"] = self.consumerModel.userId;
//
//        // 神策数据
//        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//        senDic[JA_Property_BindingType] = @"取消关注";
//        senDic[JA_Property_PostId] = self.consumerModel.userId;
//        senDic[JA_Property_PostName] = self.consumerModel.name;
//        senDic[JA_Property_FollowMethod] = @"搜索结果页";
//        [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
//
//        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
//
//            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
//            self.consumerModel.friendType = type;
//            btn.userInteractionEnabled = YES;
////            btn.selected = NO;
////            [btn setImage:[UIImage imageNamed:@"answerDetail_+"] forState:UIControlStateNormal];
////            btn.backgroundColor = [UIColor clearColor];
////            btn.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
////            btn.layer.borderWidth = 1;
//
//        } failure:^(NSError *error) {
//           btn.userInteractionEnabled = YES;
//            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
//        }];
//
//        return;
//    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.consumerModel.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = self.consumerModel.userId;
    senDic[JA_Property_PostName] = self.consumerModel.name;
    senDic[JA_Property_FollowMethod] = @"搜索结果页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        self.consumerModel.friendType = type;
        btn.userInteractionEnabled = YES;
        self.focusButton.hidden = YES;
        self.jumpImageView.hidden = NO;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.consumerModel.consumerId.length ? self.consumerModel.consumerId : self.consumerModel.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];


}

//- (NSMutableAttributedString *)attributedString:(NSString *)text wordArray:(NSArray *)keyWordArr
//{
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
//    
//    for (NSInteger i = 0; i < keyWordArr.count; i++) {
//        
//        NSString *keyWord = keyWordArr[i];
//        // 获取关键字的位置
//        NSRange rang = [text rangeOfString:keyWord];
//        
//        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
//    }
//    
//    return attr;
//}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
    
    return attr;
}
@end
