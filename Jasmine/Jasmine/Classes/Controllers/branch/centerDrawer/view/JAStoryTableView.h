//
//  JAStoryTableView.h
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JAChannelModel.h"
#import "JAStoryTopicView.h"

@protocol JAStoryTableViewDelegate <NSObject>

@optional
- (void)ja_scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface JAStoryTableView : UITableView

@property (nonatomic, weak) id<JAStoryTableViewDelegate> ja_scrollDelegate;
@property (nonatomic, strong) NSMutableArray *voices;
@property (nonatomic, strong) JAChannelModel *model;
// v3.1.0
@property (nonatomic, strong) JAStoryTopicView *topicView;

- (instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)vc sectionHeaderView:(UIView *)sectionHeaderView;

@end
