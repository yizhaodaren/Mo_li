//
//  JAMyMedalHeaderView.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMyMedalHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *totalMedalLable;
@property (nonatomic,assign)NSInteger medalNum;
@end
