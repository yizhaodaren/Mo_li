//
//  JAHorizonalTableView.h
//  Jasmine
//
//  Created by xujin on 18/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

/**
 *  横向的tableView
 *  1.请不要轻易指定tableView.delegate
 *  2.请不要轻易指定tableView.datasource
 *  3.通过horizonaldataSource达到一般的tableView的datasource效果
 *  4.如果有需要用到的delegate，请逐一复写并听见到PTVHorizonalTableViewDelegate中
 */
#import <UIKit/UIKit.h>

@protocol JAHorizonalTableViewDelegate <NSObject>

@optional
- (void)horizontalTableDidEndDecelerating:(UIScrollView *)scrollView;

@end

@protocol JAHorizonalTableViewDataSources <NSObject>

/**
 *  @return 页数
 */
- (NSInteger)numberOfRowsInSectionWithHorizonalableView:(UITableView *)tableView;

- (UITableViewCell *)horizonalableView:(UITableView *)tableView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface JAHorizonalTableView : UITableView <UITableViewDelegate,UITableViewDataSource>

//当前选中的单元格Index
@property (nonatomic)NSInteger selectedInex;

@property (nonatomic, weak) id<JAHorizonalTableViewDataSources> horizonaldataSource;

@property (nonatomic, weak) id<JAHorizonalTableViewDelegate>    horizonalDelegate;

- (instancetype)initWithFrame:(CGRect)frame itemWidth:(CGFloat)itemWidth;

//当前选中的单元格Index
- (void)setSelectedInex:(NSInteger)selectedInex animated:(BOOL)animated;

@end
