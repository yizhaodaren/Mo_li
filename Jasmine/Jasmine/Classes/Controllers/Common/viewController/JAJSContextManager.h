//
//  JAJSContextManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjcDelegate <JSExport>

- (void)shareInviteJasmine;  // 老版web页面 界面调用分享的js方法
- (void)activityGotoVoiceDetail:(NSString *)voiceId;  // 获取js 给的故事id 跳转帖子详情
- (NSString *)activityGetUserInfo;  // 获取用户信息
- (void)shareWithInfo:(NSString *)jsonString; // 新版web页面需要调起分享的js方法
- (void)shareWithCopyWord:(NSString *)jsonString; // 复制文字
- (void)shareWithStorePicture:(NSString *)jsonString; // 存储图片到本地
- (void)shareWithOpenWx; // 打开微信
- (void)shareImageToPlatformWithImage:(NSString *)jsonString; // 分享图片到三方

- (void)moliH5Action:(NSString *)jsonString; // 2.4.0 h5跳转app界面

- (void)playToPause; // 2.5.0 关闭音频
@end

@interface JAJSContextManager : JABaseViewController
@property (nonatomic, strong) NSDictionary *modelDic;
//@property (nonatomic, weak) id <JSObjcDelegate> delegate;

@end
