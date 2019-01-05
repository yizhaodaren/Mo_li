//
//  JAPlatformShareManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPlatformShareManager.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "JAVoiceCommonApi.h"
#import "JALoginManager.h"

@implementation JAPlatformShareManager

/*******************************************web分享图片************************************************/
// 微信 - web
+ (void)web_wxShareImage:(WeiXinShareType)type shareImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle
{
    if ([WXApi isWXAppInstalled]) {
        
        if (imageType == 1) {   // url
            
            [self web_loadImage:imageStr finishBlock:^(UIImage *shareImage) {
                
                WXMediaMessage *mes = [WXMediaMessage message];
                NSData *resizeData = [NSData reSizeImageData:shareImage maxImageSize:100 maxSizeWithKB:32];
                UIImage *smallImage = [[UIImage alloc] initWithData:resizeData];
                [mes setThumbImage:smallImage];
                
                WXImageObject *objImage = [WXImageObject object];
                objImage.imageData = UIImagePNGRepresentation(shareImage);
                mes.mediaObject = objImage;
                
                SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
                sendRequest.message = mes;
                sendRequest.bText = NO;
                sendRequest.scene = type;
                
                // 4. send request
                BOOL sendSuccess = [WXApi sendReq:sendRequest];
                NSLog(@"分享图片 - %d",sendSuccess);
                
            }];
            
        }else{
            
            NSURL *url  =[NSURL URLWithString:imageStr];
            NSData *data = [NSData dataWithContentsOfURL:url];
            // 将二进制转为图片并存到本地
            UIImage *image = [UIImage imageWithData:data];
            
            WXMediaMessage *mes = [WXMediaMessage message];
            NSData *resizeData = [NSData reSizeImageData:image maxImageSize:100 maxSizeWithKB:32];
            UIImage *smallImage = [[UIImage alloc] initWithData:resizeData];
            [mes setThumbImage:smallImage];
            
            WXImageObject *objImage = [WXImageObject object];
            objImage.imageData = UIImagePNGRepresentation(image);
            mes.mediaObject = objImage;
            
            SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
            sendRequest.message = mes;
            sendRequest.bText = NO;
            sendRequest.scene = type;
            
            // 4. send request
            BOOL sendSuccess = [WXApi sendReq:sendRequest];
            NSLog(@"分享图片 - %d",sendSuccess);
        }
        
        
    }else {
        [self wxLogin];
        
    }
}

// qq分享图片  -- web
+ (void)web_qqShareImage:(QQShareType)type shareImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle
{
    if (![QQApiInterface isQQInstalled]) {
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
        
    }else{
        
        if (imageType == 1) {
            [self web_loadImage:imageStr finishBlock:^(UIImage *shareImage) {
                //QQ 分享图片不超过 1M ，没有压缩的必要
                NSData *sharedata = UIImagePNGRepresentation(shareImage);
                QQApiImageObject *imgObj = [QQApiImageObject objectWithData:sharedata
                                                           previewImageData:sharedata
                                                                      title:title
                                                                description:subTitle];
                
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
                //因为分享的是联系人和空间的结合体，下面的判断其实多此一举
                if (type == 0){
                    //分享好友
                    [QQApiInterface sendReq:req];
                }else{
                    //分享空间
                    [QQApiInterface SendReqToQZone:req];
                }
            }];
        }else{
            NSURL *url  =[NSURL URLWithString:imageStr];
            NSData *data = [NSData dataWithContentsOfURL:url];
            // 将二进制转为图片并存到本地
            UIImage *image = [UIImage imageWithData:data];
            
            //QQ 分享图片不超过 1M ，没有压缩的必要
            NSData *sharedata = UIImagePNGRepresentation(image);
            QQApiImageObject *imgObj = [QQApiImageObject objectWithData:sharedata
                                                       previewImageData:sharedata
                                                                  title:title
                                                            description:subTitle];
            
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
            //因为分享的是联系人和空间的结合体，下面的判断其实多此一举
            if (type == 0){
                //分享好友
                [QQApiInterface sendReq:req];
            }else{
                //分享空间
                [QQApiInterface SendReqToQZone:req];
            }
        }
    
    }
}

// 微博分享图片 -- web
+ (void)web_wbShareImageWithImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle
{
    
    if (imageType == 1) {  // url
        
        [self web_loadImage:imageStr finishBlock:^(UIImage *shareImage) {
            
            WBMessageObject *message = [WBMessageObject message];
            
            message.text = [NSString stringWithFormat:@"%@ %@",title,subTitle];;
            
            WBImageObject *imageObj = [WBImageObject object];
            imageObj.imageData = UIImagePNGRepresentation(shareImage);
            message.imageObject = imageObj;
            
            WBSendMessageToWeiboRequest *sendReq;
            
            //share to sina blog app - if its installed
            if ([WeiboSDK isCanShareInWeiboAPP]) {
                // 3. use the message to instantiate a send request
                sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message];
                
            }else {
                //5. use webview to share - authorize first
                AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSString *weiboAccessToken = myAppDelegate.weiboAccessToken;
                
                WBAuthorizeRequest *authorReq = [WBAuthorizeRequest request];
                authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
                authorReq.scope = @"all";
                
                sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authorReq access_token:weiboAccessToken];
                sendReq.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
            }
            
            
            [WeiboSDK sendRequest:sendReq];
        }];
        
    }else{
        
        NSURL *url  =[NSURL URLWithString:imageStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        // 将二进制转为图片并存到本地
        UIImage *image = [UIImage imageWithData:data];
        
        WBMessageObject *message = [WBMessageObject message];
        
        message.text = [NSString stringWithFormat:@"%@ %@",title,subTitle];;
        
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData = UIImagePNGRepresentation(image);
        message.imageObject = imageObj;
        
        WBSendMessageToWeiboRequest *sendReq;
        
        //share to sina blog app - if its installed
        if ([WeiboSDK isCanShareInWeiboAPP]) {
            // 3. use the message to instantiate a send request
            sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message];
            
        }else {
            //5. use webview to share - authorize first
            AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *weiboAccessToken = myAppDelegate.weiboAccessToken;
            
            WBAuthorizeRequest *authorReq = [WBAuthorizeRequest request];
            authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
            authorReq.scope = @"all";
            
            sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authorReq access_token:weiboAccessToken];
            sendReq.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        }
        
        
        [WeiboSDK sendRequest:sendReq];
    }
}


// 下载图片   0 base64图片  1 url 图片
+ (void)web_loadImage:(NSString *)imageString finishBlock:(void(^)(UIImage *shareImage))finishBlock
{
    UIImageView *shareIV = [UIImageView new];
    [MBProgressHUD showMessage:nil];
    [shareIV ja_setImageWithURLStr:imageString placeholderImage:nil completed:^(UIImage *image, NSError *error) {
        UIImage *shareImage = image;
        [MBProgressHUD hideHUD];
        if (shareImage) {
//            shareImage = [UIImage OriginImage:image scaleToSize:CGSizeMake(60*JA_SCREEN_SCALE, 60*JA_SCREEN_SCALE)];
            finishBlock(shareImage);
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"获取图片失败，请重试"];
        }
    }];
}

/*******************************************web分享图片************************************************/


/*******************************************微信分享图片(晒收入)************************************************/
/// 微信分享图片(晒收入)
+ (void)wxShare:(WeiXinShareType)type shareImage:(UIImage *)image
{
    if ([WXApi isWXAppInstalled]) {
        WXMediaMessage *mes = [WXMediaMessage message];
        NSData *resizeData = [NSData reSizeImageData:image maxImageSize:100 maxSizeWithKB:32];
        UIImage *smallImage = [[UIImage alloc] initWithData:resizeData];
        [mes setThumbImage:smallImage];
        
        WXImageObject *objImage = [WXImageObject object];
        objImage.imageData = UIImagePNGRepresentation(image);
        mes.mediaObject = objImage;
        
        SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
        sendRequest.message = mes;
        sendRequest.bText = NO;
        sendRequest.scene = type;
        
        // 4. send request
        BOOL sendSuccess = [WXApi sendReq:sendRequest];
        NSLog(@"分享图片 - %d",sendSuccess);
    }else {
        
        [self wxLogin];
        
    }
}

/// 微信分享图片(url)
+ (void)wxShare:(WeiXinShareType)type shareImageWithUrlString:(NSString *)imageString
{
    if ([WXApi isWXAppInstalled]) {
        
        [self web_loadImage:imageString finishBlock:^(UIImage *shareImage) {
            
            WXMediaMessage *mes = [WXMediaMessage message];
            NSData *resizeData = [NSData reSizeImageData:shareImage maxImageSize:100 maxSizeWithKB:32];
            UIImage *smallImage = [[UIImage alloc] initWithData:resizeData];
            [mes setThumbImage:smallImage];
            
            WXImageObject *objImage = [WXImageObject object];
            objImage.imageData = UIImagePNGRepresentation(shareImage);
            mes.mediaObject = objImage;
            
            SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
            sendRequest.message = mes;
            sendRequest.bText = NO;
            sendRequest.scene = type;
            
            // 4. send request
            BOOL sendSuccess = [WXApi sendReq:sendRequest];
            NSLog(@"分享图片 - %d",sendSuccess);
            
        }];
    }else {
        
        [self wxLogin];
        
    }
}

// qq分享图片（晒收入）
+ (void)qqShare:(QQShareType)type shareImage:(UIImage *)image
{
    if (![QQApiInterface isQQInstalled]) {
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
        return;
    }
    NSData *sharedata = UIImagePNGRepresentation(image);
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:sharedata
                                               previewImageData:sharedata
                                                          title:@""
                                                    description:@""];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    
    [QQApiInterface SendReqToQZone:req];
}
/*******************************************微信分享图片(晒收入)************************************************/

/*******************************************三方分享************************************************/
/// QQ分享
+ (void)qqShare:(QQShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    if ([QQApiInterface isQQInstalled]) {
        [MBProgressHUD showMessage:nil];
        [self getRandomShareUrlWithType:domainType platformType:2 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeNews];
           
        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
//            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeNews];
        }];
        
    }else {
    
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
    }
}

// 原始的QQ分享
+ (void)orignQQshare:(QQShareType)type shareContent:(JAShareModel *)model apiURLTargetType:(QQApiURLTargetType)apiURLTargetType
{
    NSString *shareImage = nil;
    if (model.image) {
        NSMutableArray *images = [NSMutableArray arrayWithArray:[model.image componentsSeparatedByString:@"#"]];
        [images removeObject:@""];
        if (images.count) {
            shareImage = images.firstObject;
        } else {
            shareImage = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/20170701/logo.png";
        }
    } else {
        shareImage = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/20170701/logo.png";
    }
    //0 indicates qq friends; 1 means qq zone;// model.shareUrl  model.title  model.descripe
    QQApiURLObject *apiURLObject;
    switch (apiURLTargetType) {
        case QQApiURLTargetTypeAudio:
        {
            apiURLObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:model.shareUrl] title: model.title description:model.descripe previewImageURL:[NSURL URLWithString:shareImage]];
            ((QQApiAudioObject *)apiURLObject).flashURL = [NSURL URLWithString:model.music];
        }
            break;
        case QQApiURLTargetTypeVideo:
        {
            
        }
            break;
        case QQApiURLTargetTypeNews:
        {
            apiURLObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.shareUrl] title: model.title description:model.descripe previewImageURL:[NSURL URLWithString:shareImage]];
        }
            break;
            
        default:
            break;
    }
    if (apiURLObject) {
        apiURLObject.cflag = type;
        //2. request
        SendMessageToQQReq *sendReq = [SendMessageToQQReq reqWithContent:apiURLObject];
        //3. send request
        if (type == 0) {
            QQApiSendResultCode QQApiSendResult = [QQApiInterface sendReq:sendReq];
            NSLog(@"%d",QQApiSendResult);
            
        }else {
            QQApiSendResultCode qZoneResult = [QQApiInterface SendReqToQZone:sendReq];
            NSLog(@"%d",qZoneResult);
        }
    }
}

/// 微信分享
+ (void)wxShare:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    if ([WXApi isWXAppInstalled]) {
        
        [MBProgressHUD showMessage:nil];
        
        [self getRandomShareUrlWithType:domainType platformType:1 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeWebpage];
        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
//            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeWebpage];
        }];
    }else {
        
        [self wxLogin];
        
    }
}

// 原始的微信分享
+ (void)orignWXshare:(WeiXinShareType)type shareContent:(JAShareModel *)model mediaObjectType:(WeiXinMediaObjectType)mediaObjectType
{
    if (type == WXSceneTimeline) {
        // 友盟事件：分享至好友
    } else if (type == WXSceneSession) {
        // 友盟事件：分享至朋友圈
    }
    NSString *imageString = nil;
    NSMutableArray *images = [NSMutableArray arrayWithArray:[model.image componentsSeparatedByString:@"#"]];
    [images removeObject:@""];
    if (images.count) {
        imageString = images.firstObject;
    }
    UIImageView *shareIV = [UIImageView new];
    [shareIV ja_setImageWithURLStr:imageString placeholderImage:nil completed:^(UIImage *image, NSError *error) {
        UIImage *shareImage = nil;
        if (image) {
            
            shareImage = [UIImage OriginImage:image scaleToSize:CGSizeMake(60, 60)];
            NSData *resizeData = [NSData reSizeImageData:shareImage maxImageSize:60 maxSizeWithKB:30];
            shareImage = [[UIImage alloc] initWithData:resizeData];
            
        } else {
            shareImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"three_icon" ofType:@"jpg"]];
        }
        
        //share to wechat and return - 0 indicates weicat friends; 1 means timeline;
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = model.title;
        message.description = model.descripe;
        //        message.mediaTagName = [NSString stringWithFormat:@"seeyoutime_room_%lu", _liveSessionInfo.roomID];
        [message setThumbImage:shareImage];
        
        switch (mediaObjectType) {
            case WeiXinMediaObjectTypeImage:
            {
                
            }
                break;
            case WeiXinMediaObjectTypeMusic:
            {
                // 多媒体消息中包含的音乐数据对象
                WXMusicObject *ext = [WXMusicObject object];
                // 音乐网页的url地址
                ext.musicUrl = model.shareUrl;
                // 音乐数据url地址
                ext.musicDataUrl = model.music;
                message.mediaObject = ext;
            }
                break;
            case WeiXinMediaObjectTypeVideo:
            {
                
            }
                break;
            case WeiXinMediaObjectTypeWebpage:
            {
                WXWebpageObject *webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = model.shareUrl;
                message.mediaObject = webpageObject;
            }
                break;
                
            default:
                break;
        }
        
        // 3. encapsulate message in a request
        SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
        sendRequest.message = message;
        sendRequest.bText = NO;
        sendRequest.scene = type;
        
        // 4. send request
        BOOL sendSuccess = [WXApi sendReq:sendRequest];
        NSLog(@"分享 - %d",sendSuccess);
        
    }];
}

/// 微博分型
+ (void)wbShareWithshareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    [MBProgressHUD showMessage:nil];
    [self getRandomShareUrlWithType:domainType platformType:0 success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        NSString *shareNewUrl = result[@"domain"];
        
        if (shareNewUrl.length) {
            shareNewUrl = [self getRandomString:shareNewUrl];
        }
        
        
        if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
            NSRange range = [model.shareUrl rangeOfString:@".cn/"];
            if (shareNewUrl.length) {
                NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                
                model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
            }
        }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
            NSRange range = [model.shareUrl rangeOfString:@".com/"];
            if (shareNewUrl.length) {
                NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                
                model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
            }
        }
       
        [self orignWBshare:model];
    } faile:^(NSError *error) {
        [MBProgressHUD hideHUD];
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
        [self orignWBshare:model];
    }];
}

// 原始的微博分享
+ (void)orignWBshare:(JAShareModel *)model
{
    UIImageView *shareIV = [UIImageView new];
    [shareIV ja_setImageWithURLStr:model.image placeholderImage:nil completed:^(UIImage *image, NSError *error) {
        UIImage *shareImage = nil;
        if (image) {
            shareImage = image;
        } else {
            shareImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"three_icon" ofType:@"jpg"]];
        }
        // 1. share a url, image, or text; webpage object inherits from the WBMediaBaseObject;
        //            WBWebpageObject *webpage = [WBWebpageObject object];
        //            webpage.webpageUrl = @"http://www.urmoli.com";//model.shareUrl;
        //            webpage.title = @"茉莉";//model.title;
        //            webpage.objectID = @"moli_share_weibo";
        //            webpage.description = @"送君茉莉，劝君莫离";//model.descripe;
        
        // 2. encapsulate the object in a message
        WBMessageObject *message = [WBMessageObject message];
        NSString *title = nil;
        
        title = [NSString stringWithFormat:@"%@ %@",model.title,model.shareUrl];
        
        message.text = title;
        
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData = UIImagePNGRepresentation(shareImage);
        
        message.imageObject = imageObj;
        
        WBSendMessageToWeiboRequest *sendReq;
        
        //share to sina blog app - if its installed
        if ([WeiboSDK isCanShareInWeiboAPP]) {
            // 3. use the message to instantiate a send request
            sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message];
            
        }else {
            //5. use webview to share - authorize first
            AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *weiboAccessToken = myAppDelegate.weiboAccessToken;
            
            WBAuthorizeRequest *authorReq = [WBAuthorizeRequest request];
            authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
            authorReq.scope = @"all";
            
            sendReq = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authorReq access_token:weiboAccessToken];
            sendReq.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        }
        
        
        BOOL weiboRes = [WeiboSDK sendRequest:sendReq];
        NSLog(@"分享 - %d",weiboRes);
        
    }];
}

+ (NSString *)getRandomString:(NSString *)string
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *dataPoint = [NSMutableString stringWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        [dataPoint appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return [string stringByReplacingOccurrencesOfString:@"://www" withString:[NSString stringWithFormat:@"://%@",dataPoint]];
}

/*
 type (老)           域名使用类型  0 内容 1跳转  3 其他域名（召唤好友） 2注册活动页面 (老)
 type（新）           域名使用类型  0 内容中转 1注册跳转 2注册落地 3话题落地  4内容落地  5话题中转 6勋章中转 9备用 （新）
 platformType     使用平台类型  0 公用 1微信 2qq
 */
+ (void)getRandomShareUrlWithType:(NSInteger)type platformType:(NSInteger)platformType success:(void(^)(NSDictionary *result))success faile:(void(^)(NSError *error))faile
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @(type);
    dic[@"platformType"] = @(platformType);
    [[JAVoiceCommonApi shareInstance] voice_shareRandom:dic success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (faile) {
            faile(error);
        }
        
    }];
}
/*******************************************三方分享************************************************/

/*******************************************分享小程序************************************************/
/// 分享小程序
+ (void)wxShareMiniProgram:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    if ([WXApi isWXAppInstalled]) {
        
        [self orignWXshareMini:type shareContent:model];
    }else {
        
        [self wxLogin];
        
    }
    
}

// 原始的微信分享小程序
+ (void)orignWXshareMini:(WeiXinShareType)type shareContent:(JAShareModel *)model
{
    NSString *imageString = nil;
    NSMutableArray *images = [NSMutableArray arrayWithArray:[model.image componentsSeparatedByString:@"#"]];
    [images removeObject:@""];
    if (images.count) {
        imageString = images.firstObject;
    }
    imageString = @"http://file.xsawe.top//file/1526891257395d608c0c9-5b9c-42a2-a1f7-005ade80d39b.jpg";

    UIImageView *shareIV = [UIImageView new];
    [shareIV ja_setImageWithURLStr:imageString placeholderImage:nil completed:^(UIImage *image, NSError *error) {
        UIImage *shareImage = nil;
        if (image) {
            shareImage = [UIImage OriginImage:image scaleToSize:CGSizeMake(150, 120)];
            NSData *resizeData = [NSData reSizeImageData:shareImage maxImageSize:150 maxSizeWithKB:100];
            shareImage = [[UIImage alloc] initWithData:resizeData];
        } else {
            shareImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"three_icon" ofType:@"jpg"]];
        }
     
        NSData *data = UIImagePNGRepresentation(shareImage);
        double dataLength = [data length] * 1.0;
        NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
        NSInteger index = 0;
        while (dataLength > 1024) {
            dataLength /= 1024.0;
            index ++;
        }
        NSLog(@"image = %.3f %@",dataLength,typeArray[index]);
        
        WXMiniProgramObject *miniObj = [WXMiniProgramObject object];
        miniObj.webpageUrl = model.shareUrl;  // 网页链接
        miniObj.userName = model.miniProgramId;   // 小程序的原始id
        miniObj.path = model.miniProgramPath;       // 小程序的路径
//#ifdef JA_TEST_HOST
//        miniObj.miniProgramType = WXMiniProgramTypePreview; // 体验版本
//#endif
        miniObj.hdImageData = UIImagePNGRepresentation(shareImage); //小程序新版本的预览图 128k
        
        WXMediaMessage *mesg = [WXMediaMessage message];
        mesg.title = model.title;
        mesg.description = model.descripe;
        mesg.mediaObject = miniObj;
        UIImage *thumbImage = [UIImage imageNamed:@"three_icon"];
        mesg.thumbData = UIImagePNGRepresentation(thumbImage);
        
        SendMessageToWXReq *sendRequest = [[SendMessageToWXReq alloc] init];
        sendRequest.message = mesg;
        sendRequest.scene = type;
        
        // 4. send request
        BOOL sendSuccess = [WXApi sendReq:sendRequest];
        NSLog(@"分享 - %d",sendSuccess);
        
    }];
}

/*******************************************分享小程序************************************************/

/***************************************主帖以音乐形式分享***********************************/
/// QQ分享音乐
+ (void)qqShareMusic:(QQShareType)type shareContent:(JAShareModel *)model {
    if ([QQApiInterface isQQInstalled]) {
        [MBProgressHUD showMessage:nil];
        [self getRandomShareUrlWithType:0 platformType:2 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeAudio];

        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
            //            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeAudio];
        }];
        
    }else {
        
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
    }
}

/// 微信分享音乐
+ (void)wxShareMusic:(WeiXinShareType)type shareContent:(JAShareModel *)model {
    if ([WXApi isWXAppInstalled]) {
        
        [MBProgressHUD showMessage:nil];
        
        [self getRandomShareUrlWithType:0 platformType:1 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeMusic];
        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeMusic];
        }];
    }else {
        
        [self wxLogin];
        
    }
}

/// 微博分享音乐
+ (void)wbShareMusicWithshareContent:(JAShareModel *)model {
    [MBProgressHUD showMessage:nil];
    [self getRandomShareUrlWithType:0 platformType:0 success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        NSString *shareNewUrl = result[@"domain"];
        
        if (shareNewUrl.length) {
            shareNewUrl = [self getRandomString:shareNewUrl];
        }
        
        
        if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
            NSRange range = [model.shareUrl rangeOfString:@".cn/"];
            if (shareNewUrl.length) {
                NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                
                model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
            }
        }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
            NSRange range = [model.shareUrl rangeOfString:@".com/"];
            if (shareNewUrl.length) {
                NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                
                model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
            }
        }
        
        [self orignWBshare:model];
    } faile:^(NSError *error) {
        [MBProgressHUD hideHUD];
        //        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
        [self orignWBshare:model];
    }];
}


/// QQ分享音乐
+ (void)qqShareMusic:(QQShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    if ([QQApiInterface isQQInstalled]) {
        [MBProgressHUD showMessage:nil];
        [self getRandomShareUrlWithType:domainType platformType:2 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeAudio];
            
        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
            //            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败，请检查网络并重试"];
            [self orignQQshare:type shareContent:model apiURLTargetType:QQApiURLTargetTypeAudio];
        }];
        
    }else {
        
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
    }
}
/// 微信分享音乐
+ (void)wxShareMusic:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType
{
    if ([WXApi isWXAppInstalled]) {
        
        [MBProgressHUD showMessage:nil];
        
        [self getRandomShareUrlWithType:domainType platformType:1 success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
            NSString *shareNewUrl = result[@"domain"];
            
            if (shareNewUrl.length) {
                shareNewUrl = [self getRandomString:shareNewUrl];
            }
            
            if([model.shareUrl rangeOfString:@".cn/"].location !=NSNotFound){  // 域名是.cn
                NSRange range = [model.shareUrl rangeOfString:@".cn/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }else if ([model.shareUrl rangeOfString:@".com/"].location !=NSNotFound){ // 域名是.com
                NSRange range = [model.shareUrl rangeOfString:@".com/"];
                if (shareNewUrl.length) {
                    NSString *url = [model.shareUrl substringFromIndex:(range.location + range.length)];
                    
                    model.shareUrl = [NSString stringWithFormat:@"%@%@",shareNewUrl,url];
                }
            }
            
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeMusic];
        } faile:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [self orignWXshare:type shareContent:model mediaObjectType:WeiXinMediaObjectTypeMusic];
        }];
    }else {
        [self wxLogin];
    }
}


+ (void)wxLogin {
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    [WXApi sendAuthReq:req viewController:[AppDelegateModel getBaseNavigationViewControll] delegate:nil];
}


@end


// 分享的模型
@implementation JAShareModel



@end
