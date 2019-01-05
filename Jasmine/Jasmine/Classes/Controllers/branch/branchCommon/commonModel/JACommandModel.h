//
//  JACommandModel.h
//  Jasmine
//
//  Created by xujin on 2018/4/10.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JACommandModel : NSObject

@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSString *commandType;
@property (nonatomic, copy) NSString *inviteUuid;
@property (nonatomic, copy) NSString *moneyCount;
@property (nonatomic, assign) NSInteger moneyType;
@property (nonatomic, copy) NSString *openType;
@property (nonatomic, copy) NSString *showType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *titleContent;

@end
