//
//  JACreditRecordModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JACreditRecordModel : NSObject
@property (nonatomic, strong) NSString *actionType;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *operationType;
@property (nonatomic, strong) NSString *creditId;
@property (nonatomic, strong) NSString *integralNum;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) CGFloat cellHeight;
@end
