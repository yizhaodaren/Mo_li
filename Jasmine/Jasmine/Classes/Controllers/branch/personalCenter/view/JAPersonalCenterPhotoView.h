//
//  JAPersonalCenterPhotoView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPersonalCenterPhotoView : UIView
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSArray *photoArray;
//@property (nonatomic, strong) void(^clickSignPhotoBlock)(NSArray *imageArr, NSInteger index);
@end
