//
//  JABaseViewController+QiYuSDK.m
//  Jasmine
//
//  Created by xujin on 30/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController+QiYuSDK.h"

@implementation JABaseViewController (QiYuSDK)


/// 获取客服聊天未读数量
- (void)getKeFuMessage:(void(^)(NSString *lastMsg,NSInteger count))finish
{
    
    //    NSArray *arr = [[[QYSDK sharedSDK] conversationManager] getSessionList];
    
    QYSessionInfo *message =  [[[QYSDK sharedSDK] conversationManager] getSessionList].firstObject;
    
    finish(message.lastMessageText,message.unreadCount);
    
}

- (void)setupQiYuViewController
{
    QYSource *source = [[QYSource alloc] init];
    source.title =  @"茉莉";
    source.urlString = @"https://8.163.com/";
    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = @"客服";
    sessionViewController.source = source;
    sessionViewController.hidesBottomBarWhenPushed = YES;
    
    [[[QYSDK sharedSDK] conversationManager] clearUnreadCount];
    
    // 一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeMessage];
    
    /**
     *  访客文本消息字体颜色
     */
    [[QYSDK sharedSDK] customUIConfig].customMessageTextColor = HEX_COLOR(0x454C57);
    /**
     *  访客文本消息字体大小
     */
    [[QYSDK sharedSDK] customUIConfig].customMessageTextFontSize = 15;
    /**
     *  客服文本消息字体颜色
     */
    [[QYSDK sharedSDK] customUIConfig].serviceMessageTextColor = HEX_COLOR(0x454C57);
    /**
     *  客服文本消息字体大小
     */
    [[QYSDK sharedSDK] customUIConfig].serviceMessageTextFontSize = 15;
    /**
     *  背景
     */
    [[QYSDK sharedSDK] customUIConfig].sessionBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:HEX_COLOR(JA_Background)]];
    /**
     *  输入框文本消息字体颜色
     */
    [[QYSDK sharedSDK] customUIConfig].inputTextColor = HEX_COLOR(0x9c9ca4);
    /**
     *  输入框文本消息字体大小
     */
    [[QYSDK sharedSDK] customUIConfig].inputTextFontSize = 15;
    /**
     *  访客头像url
     */
    [[QYSDK sharedSDK] customUIConfig].customerHeadImageUrl = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    
    //客服头像
    /**
     *  客服头像
     */
    [[QYSDK sharedSDK] customUIConfig].serviceHeadImage = [UIImage imageNamed:@"kefu"];
    /**
     *  客服头像url
     */
//    [[QYSDK sharedSDK] customUIConfig].serviceHeadImageUrl = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/msg_img_001.png";
    
    // floorf(right.size.width-30)
    UIImage *right = [UIImage imageNamed:@"message_green"];
    right = [right stretchableImageWithLeftCapWidth:floorf(right.size.width-30) topCapHeight:floorf(right.size.height-10)];
    
    UIImage *left = [UIImage imageNamed:@"message_white"];
    left = [left stretchableImageWithLeftCapWidth:floorf(left.size.width-10) topCapHeight:floorf(left.size.height-10)];
    /**
     *  访客消息气泡normal图片
     */
    [[QYSDK sharedSDK] customUIConfig].customerMessageBubbleNormalImage = right;
    [[QYSDK sharedSDK] customUIConfig].customerMessageBubblePressedImage = right;
    //    [[QYSDK sharedSDK] customUIConfig].customerMessageBubbleNormalImage =
    //    [right resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,20,15)];
    /**
     *  客服消息气泡normal图片
     */
    [[QYSDK sharedSDK] customUIConfig].serviceMessageBubbleNormalImage = left;
    [[QYSDK sharedSDK] customUIConfig].serviceMessageBubblePressedImage = left;
    //    [[QYSDK sharedSDK] customUIConfig].serviceMessageBubbleNormalImage =
    //    [left
    //     resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,15,15)
    //     resizingMode:UIImageResizingModeStretch];
    //    [[QYSDK sharedSDK] customUIConfig].serviceMessageBubblePressedImage =
    //    [left
    //     resizableImageWithCapInsets:UIEdgeInsetsMake(15,15,15,15)
    //     resizingMode:UIImageResizingModeStretch];
    /**
     *  默认是YES,默认显示发送语音入口，设置为NO，可以修改为隐藏
     */
    [QYCustomUIConfig sharedInstance].showAudioEntry = NO;
    [QYCustomUIConfig sharedInstance].showEmoticonEntry = NO;
    [QYCustomUIConfig sharedInstance].autoShowKeyboard = NO;
    
    [[QYSDK sharedSDK] customUIConfig].bottomMargin = 0;
    
    UIImage *image = [UIImage imageNamed:@"circle_back_black"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(qiyuBack)];
    item.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    sessionViewController.navigationItem.leftBarButtonItem = item;
    
    [self qx_userInfo:[JAUserInfo userInfo_getUserImfoWithKey:User_Name] phone:[JAUserInfo userInfo_getUserImfoWithKey:User_Phone] image:[JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl]];
    
    [self.navigationController pushViewController:sessionViewController animated:YES];
    
}

- (void)qx_userInfo:(NSString *)name phone:(NSString *)phone image:(NSString *)url
{
    QYUserInfo *userInfo = [[QYUserInfo alloc] init];
    userInfo.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSMutableArray *array = [NSMutableArray new];
    NSMutableDictionary *dictRealName = [NSMutableDictionary new];
    [dictRealName setObject:@"real_name" forKey:@"key"];
    [dictRealName setObject:name forKey:@"value"];
    [array addObject:dictRealName];
    NSMutableDictionary *dictMobilePhone = [NSMutableDictionary new];
    [dictMobilePhone setObject:@"mobile_phone" forKey:@"key"];
    [dictMobilePhone setObject:phone forKey:@"value"];
    [dictMobilePhone setObject:@(NO) forKey:@"hidden"];
    [array addObject:dictMobilePhone];
    NSMutableDictionary *dictMobileImage = [NSMutableDictionary new];
    [dictMobileImage setObject:@"avatar" forKey:@"key"];
    [dictMobileImage setObject:url forKey:@"value"];
    [array addObject:dictMobileImage];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                   options:0
                                                     error:nil];
    if (data)
    {
        userInfo.data = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    }
    
    [[QYSDK sharedSDK] setUserInfo:userInfo];
}

- (void)qiyuBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
