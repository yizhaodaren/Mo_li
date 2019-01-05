//
//  JAAccountActionCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAAccountActionCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, strong) void(^bindingPhoneBlock)();
@end
