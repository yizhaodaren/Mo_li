//
//  JAPlatformLoginViewController.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

typedef NS_ENUM(NSUInteger, JARecordLoginType) {
    JARecordLoginTypePhoneLogin,
    JARecordLoginTypeWbLogin,
    JARecordLoginTypeWxLogin,
    JARecordLoginTypeQqLogin,
};

@interface JAPlatformLoginViewController : JABaseViewController

@property (nonatomic, assign) JARecordLoginType loginType;
@end
