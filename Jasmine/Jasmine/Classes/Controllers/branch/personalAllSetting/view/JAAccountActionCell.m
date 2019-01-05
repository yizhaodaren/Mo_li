//
//  JAAccountActionCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAccountActionCell.h"
#import "JALoginManager.h"
#import "JAUserApiRequest.h"

@interface JAAccountActionCell ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *button;
@property (nonatomic, weak) UIView *lineView;
@end

@implementation JAAccountActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupActionCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupActionCellUI
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    [self.contentView addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x4A4A4A);
    nameLabel.font = JA_REGULAR_FONT(15);
    [self.contentView addSubview:nameLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button = button;
    [button setTitle:@"绑定" forState:UIControlStateNormal];
    [button setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    button.titleLabel.font = JA_REGULAR_FONT(14);
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button setBackgroundColor:HEX_COLOR(JA_Green)];
    [self.contentView addSubview:button];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

// 按钮的点击
- (void)clickButton:(UIButton *)btn
{
    if ([self.dictionary[@"type"] isEqualToString:@"phone"]) {
        
        if (!btn.selected) {
            
            [self bindingPhone];
        }
    }else if ([self.dictionary[@"type"] isEqualToString:@"wx"]) {
        if (!btn.selected) {
            // 绑定微信
            [self bindingPlatform:JALoginType_Wechat];
        }else{
            [self unbindingPlatform:JALoginType_Wechat];
        }
    }else if ([self.dictionary[@"type"] isEqualToString:@"wb"]) {
        if (!btn.selected) {
            // 绑定微博
            [self bindingPlatform:JALoginType_Weibo];
        }else{
            [self unbindingPlatform:JALoginType_Weibo];
        }
    }else if ([self.dictionary[@"type"] isEqualToString:@"qq"]) {
        if (!btn.selected) {
            // 绑定QQ
            [self bindingPlatform:JALoginType_QQ];
        }else{
            [self unbindingPlatform:JALoginType_QQ];
        }
    }
}

// 网络请求
- (void)bindingPhone   // 绑定手机
{
    
    if (self.bindingPhoneBlock) {
        self.bindingPhoneBlock();
    }
}

- (void)bindingPlatform:(JALoginType)type    // 绑定三方
{
    if (type == JALoginType_QQ) {
        [self sensorsAnalyticsWithMothod:@"绑定" type:@"qq"];
    }else if (type == JALoginType_Weibo){
        [self sensorsAnalyticsWithMothod:@"绑定" type:@"微博"];
    }else if (type == JALoginType_Wechat){
        [self sensorsAnalyticsWithMothod:@"绑定" type:@"微信"];
    }
    
    // 去绑定三方
    [[JALoginManager shareInstance] loginWithType:type];
}

- (void)unbindingPlatform:(JALoginType)type   // 解绑三方
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解绑后将无法使用此账号登录，仍然解绑？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showMessage:nil];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        
        if (type == JALoginType_QQ) {
            [self sensorsAnalyticsWithMothod:@"解绑" type:@"qq"];
            dic[@"type"] = @"1";
        }else if (type == JALoginType_Weibo){
            [self sensorsAnalyticsWithMothod:@"解绑" type:@"微博"];
            dic[@"type"] = @"3";
        }else if (type == JALoginType_Wechat){
            [self sensorsAnalyticsWithMothod:@"解绑" type:@"微信"];
            dic[@"type"] = @"2";
        }
        
        [[JAUserApiRequest shareInstance] userWithDrawUnbindingPlatform:dic success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"解绑成功"];
            if (type == JALoginType_QQ) {
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"qq" success:YES];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformQQUid];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformQQName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"unbindingPlatform" object:nil];
            }else if (type == JALoginType_Weibo){
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"微博" success:YES];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWBUid];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWBName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"unbindingPlatform" object:nil];
            }else if (type == JALoginType_Wechat){
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"微信" success:YES];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWXUid];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWXName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"unbindingPlatform" object:nil];
            }
        } failure:^(NSError *error) {
            
            if (type == JALoginType_QQ) {
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"QQ" success:NO];
            }else if (type == JALoginType_Weibo){
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"微博" success:NO];
            }else if (type == JALoginType_Wechat){
                [self sensorsAnalyticsWithMothod:@"解绑" type:@"微信" success:NO];
            }
            
            [MBProgressHUD hideHUD];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解绑失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alert addAction:action];
            
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
            
        }];
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
    
   
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorActionCellFrame];
}

- (void)caculatorActionCellFrame
{
    self.iconImageView.width = 35;
    self.iconImageView.height = 35;
    self.iconImageView.x = 15;
    self.iconImageView.centerY = self.contentView.height * 0.5;
    
    self.nameLabel.width = 100;
    self.nameLabel.height = self.contentView.height;
    self.nameLabel.x = self.iconImageView.right  + 15;
    
    self.button.width = 65;
    self.button.height = 25;
    self.button.x = self.contentView.width - 10 - self.button.width;
    self.button.centerY = self.contentView.height * 0.5;
    self.button.layer.cornerRadius = self.button.height * 0.5;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
    _dictionary = dictionary;
    
    self.iconImageView.image = [UIImage imageNamed:dictionary[@"image"]];
    self.nameLabel.text = dictionary[@"title"];
    BOOL stateStr = [dictionary[@"select"] boolValue];
    self.button.selected = stateStr;
    if ([dictionary[@"type"] isEqualToString:@"phone"]) {
        [self.button setTitle:@"已绑定" forState:UIControlStateSelected];
        [self.button setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateSelected];
        if (self.button.selected) {
            self.button.userInteractionEnabled = NO;
            [self.button setBackgroundColor:HEX_COLOR(0xF1F1F1)];
        }else{
            self.button.userInteractionEnabled = YES;
            [self.button setBackgroundColor:HEX_COLOR(JA_Green)];
        }
        self.button.layer.borderWidth = 0;
    }else{
        
        if (self.button.selected) {
            self.nameLabel.text = dictionary[@"name"];
            self.button.layer.borderWidth = 1;
            self.button.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
            self.button.backgroundColor = HEX_COLOR(0xffffff);
            
        }else{
            self.nameLabel.text = dictionary[@"title"];
            self.button.layer.borderWidth = 0;
            self.button.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
            self.button.backgroundColor = HEX_COLOR(JA_Green);
        }
        
        [self.button setTitle:@"解绑" forState:UIControlStateSelected];
//        [self.button setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
        [self.button setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateSelected];
        self.button.userInteractionEnabled = YES;

    }
}

// 神策数据
- (void)sensorsAnalyticsWithMothod:(NSString *)mothod type:(NSString *)type success:(BOOL)result
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//    senDic[JA_Property_BindingType] = mothod;
//    senDic[JA_Property_AccountType] = type;
    senDic[JA_Property_BindingSucceed] = @(result);
    [JASensorsAnalyticsManager sensorsAnalytics_bindingOrunBinding:senDic];
}

- (void)sensorsAnalyticsWithMothod:(NSString *)mothod type:(NSString *)type
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_BindingType] = mothod;
        senDic[JA_Property_AccountType] = type;
    [JASensorsAnalyticsManager sensorsAnalytics_ClickBindingOrunBinding:senDic];
}
@end
