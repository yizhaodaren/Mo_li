//
//  EDRequestUrlManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/21.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDRequestUrlManager : NSObject

/*
 http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/interface/list/ffff-1500554685393-1722617555-0002
 */

/// 获取评论的回复Url
+ (NSString *)url_reply;

/// 删除回复url
+ (NSString *)url_replyDelete;

/// 添加回复url
+ (NSString *)url_replyInsert;

@end
