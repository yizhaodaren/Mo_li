//
//  JASearchPictureTextCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JASearchPictureTextCell : UITableViewCell

@property (nonatomic, strong) JAConsumer *consumerModel;

//@property (nonatomic, strong) void(^focusBlock)(JASearchPictureTextCell *cell);

@property (nonatomic, strong) NSString *keyWord;

//@property (nonatomic, strong) NSArray *keyWordArr;
@end
