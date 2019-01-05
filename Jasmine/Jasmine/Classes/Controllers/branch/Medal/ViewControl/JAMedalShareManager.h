//
//  JAMedalShareManager.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/20.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>


//勋章分享用的

@interface JAMedalShareManager : NSObject
+(instancetype)instance;

-(void)shareWith:(JAMedalShareModel *)shareModel domainType:(NSInteger)domainType;
@end
