//
//  JAMedalShareManager.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/20.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalShareManager.h"
#import "JABottomShareView.h"
#import "JAPlatformShareManager.h"

@interface JAMedalShareManager()<PlatformShareDelegate>

@end


@implementation JAMedalShareManager
+(instancetype)instance{
    static JAMedalShareManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[JAMedalShareManager alloc] init];
        
    });
    return instance;
}


-(void)shareWith:(JAMedalShareModel *)shareModel domainType:(NSInteger)domainType{
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    
    JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:JABottomShareOneContentTypeNormal twoContentType:JABottomShareTwoContentTypeNormal];
    shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
        
        if (clickType == JABottomShareClickTypeWX) {
            
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareModel.shareWxContent;
            model.descripe = shareModel.shareTitle;
            model.shareUrl = shareModel.shareUrl;
            model.image = shareModel.shareImg;
            
            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:domainType];
        }else if (clickType == JABottomShareClickTypeWXSession){
            
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareModel.shareWxContent;
            model.shareUrl = shareModel.shareUrl;
            model.image = shareModel.shareImg;
            
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:domainType];
        }else if (clickType == JABottomShareClickTypeQQ){
            
            JAShareModel *model = [JAShareModel new];
            model.title = shareModel.shareWxContent;
            model.descripe = shareModel.shareTitle;
            model.shareUrl = shareModel.shareUrl;
            model.image = shareModel.shareImg;
            
            [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:domainType];
            
        }else if (clickType == JABottomShareClickTypeQQZone){
            
            JAShareModel *model = [JAShareModel new];
            model.title = shareModel.shareWxContent;
            model.descripe = shareModel.shareTitle;
            model.shareUrl = shareModel.shareUrl;
            model.image = shareModel.shareImg;
            
            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:domainType];
            
        }else if (clickType == JABottomShareClickTypeWB){
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareModel.shareWxContent;
            model.shareUrl = shareModel.shareUrl;
            model.image = shareModel.shareImg;
            [JAPlatformShareManager wbShareWithshareContent:model domainType:domainType];
        }
        
    };
    [shareView showBottomShareView];
}
#pragma mark - 分享回调
- (void)wxShare:(int)code
{
    if (code == 0) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
    }else if (code == -2) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -3) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -4) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -5) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)qqShare:(NSString *)error
{
    if (error == nil) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wbShare:(int)code
{
    if (code == 0) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -2){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -3){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -8){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }else if (code == -99){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请求无效"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

@end
