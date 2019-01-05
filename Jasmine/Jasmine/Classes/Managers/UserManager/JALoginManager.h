//
//  JALoginManager.h
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    JALoginType_QQ,
    JALoginType_Wechat,
    JALoginType_Weibo,
    JALoginType_Phone
} JALoginType;

@interface JALoginManager : NSObject

@property (nonatomic, weak) UIViewController *vc;

+ (JALoginManager *)shareInstance;

- (void)loginWithType:(JALoginType)type;

- (void)loginWithPhone:(NSString *)phone code:(NSString *)code completeBlock:(void(^)(void))completeBlock;

- (void)getVerfiyCodeWithPhone:(NSString *)phone;

@property (copy) void(^thirdPartLoginCompleteBlock)(void);

@end
