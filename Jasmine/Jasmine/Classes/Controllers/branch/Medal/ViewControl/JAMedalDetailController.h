//
//  JAMedalDetailController.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMedalModel.h"


//刷新代理
@protocol JAMedalDetailDelegate<NSObject>
@required
-(void)refreshMedalList;
@end

@interface JAMedalDetailController : UIViewController

@property(nonatomic,assign)id<JAMedalDetailDelegate> delegate;


@property(nonatomic,assign)UIStatusBarStyle statusBarStyle;//状态栏类型

@property(nonatomic,assign)BOOL isMySelfMedal;//是否从自己的页面
@property(nonatomic,copy)NSString *medalUserID;//useId 可能是的也可能是别人的
@property(nonatomic,copy)NSString *medalID;//勋章ID

@end
