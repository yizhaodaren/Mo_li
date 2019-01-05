//
//  JASignTaskView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASignTaskView : UIView

@property (nonatomic, strong) NSString *flowerString;
@property (nonatomic, strong) NSString *moneyString;

- (void)invalidateTime;
@end
