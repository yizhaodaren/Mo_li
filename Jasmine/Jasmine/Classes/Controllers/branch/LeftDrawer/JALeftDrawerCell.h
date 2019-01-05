//
//  JALeftDrawerCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALeftDrawerCell : UITableViewCell
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *typeString;

@property (nonatomic, strong) NSDictionary *cellDic;

@property (nonatomic, weak) UILabel *nameLabel;
@end
