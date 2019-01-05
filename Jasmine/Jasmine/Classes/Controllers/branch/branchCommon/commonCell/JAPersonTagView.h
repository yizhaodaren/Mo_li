//
//  JAPersonTagView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JANewCommentModel,JANewReplyModel;
@interface JAPersonTagView : UIView
@property (nonatomic, assign) NSInteger type; // 0 是回复详情页面（等级 楼主 圈主）  1 帖子列表（等级 圈主）

@property (nonatomic, assign) BOOL isFloor;
@property (nonatomic, assign) BOOL isCircle;
@property (nonatomic, strong) NSString *level;
@end
