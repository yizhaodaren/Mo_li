//
//  JASearchPostsCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/4.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JANewVoiceModel;
@interface JASearchPostsCell : UITableViewCell

@property (nonatomic, strong) JANewVoiceModel *model;
//@property (nonatomic, strong) NSString *keyWord;

@property (nonatomic, strong) NSArray *keyWordArr;
@end
