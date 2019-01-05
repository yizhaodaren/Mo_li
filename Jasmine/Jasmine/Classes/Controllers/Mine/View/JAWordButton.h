//
//  JAWordButton.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAWordButton : UIView
@property (nonatomic, strong) NSString *countString;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) void(^clickButton)();
@end
