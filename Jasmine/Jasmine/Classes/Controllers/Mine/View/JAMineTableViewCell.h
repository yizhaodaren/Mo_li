//
//  JAMineTableViewCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMineTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *cellDic;
- (void)setBottomLineHidden:(BOOL)hidden;

@end

