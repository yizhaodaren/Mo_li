//
//  JASubRelationshipViewController.h
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JASubRelationshipViewController : JABaseViewController

@property (nonatomic, assign) NSInteger dataCount;
@property (nonatomic, assign) NSInteger type;//0好友1关注2粉丝
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;

- (void)getData:(void(^)(NSInteger dataCount))updateCount;

@end
