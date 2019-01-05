//
//  JAJSBridgeHelper.h
//  Jasmine
//
//  Created by xujin on 09/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface JAJSBridgeHelper : NSObject

@property (nonatomic, strong) WKWebView *webView;

- (void)activityGotoVoiceDetail:(NSString *)voiceId;  // 获取js 给的故事id 跳转帖子详情
- (void)shareWithInfo:(NSString *)jsonString; // 新版web页面需要调起分享的js方法
- (void)shareWithCopyWord:(NSString *)jsonString; // 复制文字
- (void)shareWithStorePicture:(NSString *)jsonString; // 存储图片到本地
- (void)shareWithOpenWx; // 打开微信
- (void)shareImageToPlatformWithImage:(NSString *)jsonString; // 分享图片到三方

- (void)moliH5Action:(NSString *)jsonString; // 2.4.0 h5跳转app界面

- (void)playToPause; // 2.5.0 关闭音频

// v2.5.5
- (void)getAppStarts; // js调用原生，然后再掉js

// 2.6.4 新版分享（all）
- (void)shareActive:(NSString *)jsonString;

// v3.0.0
- (void)getHttpHeader;

@end
