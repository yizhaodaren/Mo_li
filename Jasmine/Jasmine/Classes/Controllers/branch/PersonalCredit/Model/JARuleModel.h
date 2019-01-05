//
//  JARuleModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JARuleModel : NSObject
@property (nonatomic, strong) NSString *actionType;
@property (nonatomic, strong) NSString *conditionBasic;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *num;

@property (nonatomic, assign) CGFloat cellHeight;

@end
