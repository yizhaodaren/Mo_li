//
//  JACircleAllStoryListViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JACircleAllStoryListViewController : JABaseViewController
@property (nonatomic, assign) NSInteger currentSortType;
@property (nonatomic, strong) NSString *circleId;
@property (nonatomic, strong) JACircleModel *infoModel;

- (void)listStory_refreshAllStory;
@end
