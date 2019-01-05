//
//  JASearchHistoryCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASearchHistoryCell;
@protocol JASearchHistoryCellDelegate <NSObject>
    
@optional
- (void)searchHistory:(JASearchHistoryCell *)cell;

@end
@interface JASearchHistoryCell : UITableViewCell
@property (nonatomic, assign) BOOL firstRow;

@property (nonatomic, strong) NSString *model;

@property (weak, nonatomic) IBOutlet UIButton *deleteLabel;
@end
