//
//  JAMessageTopView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAOfficCustomerModel;
@interface JAMessageTopView : UIView
@property (weak, nonatomic) IBOutlet UIButton *officButton;
@property (weak, nonatomic) IBOutlet UIButton *customerButton;
@property (weak, nonatomic) IBOutlet UIButton *noticeButton;

@property (weak, nonatomic) IBOutlet UIImageView *moliJunImageView;
@property (weak, nonatomic) IBOutlet UILabel *moliJunName;

//@property (nonatomic, strong) JAOfficCustomerModel *cusModel;
//@property (nonatomic, strong) JAOfficCustomerModel *officModel;

// 茉莉客服
@property (nonatomic, assign) NSInteger keFucount;
@property (nonatomic, strong) NSString *keFuMessage;


// 茉莉客服
@property (nonatomic, assign) NSInteger moliJunCount;
@property (nonatomic, strong) NSString *moliJunMessage;

/// 茉莉官方聊天数据
@property (nonatomic, strong) NIMRecentSession *recentSession;
@end
