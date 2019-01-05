//
//  JAHorizonalTableView.m
//  Jasmine
//
//  Created by xujin on 18/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAHorizonalTableView.h"

@interface JAHorizonalTableView ()

@property (nonatomic, assign) CGFloat itemWidth;

@end

@implementation JAHorizonalTableView



- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubviews:frame];
        self.itemWidth = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame itemWidth:(CGFloat)itemWidth {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubviews:frame];
        self.itemWidth = itemWidth;
    }
    return self;
}

- (void)setupSubviews:(CGRect)frame
{
    self.pagingEnabled = YES;
    self.userInteractionEnabled = YES;
    self.bounces = NO;
    if (!IS_LOGIN) {
        self.scrollEnabled = NO;
    }else{
        self.scrollEnabled = YES;
    }
    
    self.scrollEnabled = YES;
    //逆时针旋转90度
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //旋转之后宽、高互换了,所以重新设置frame
    self.frame = frame;
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉垂直方向的滚动条
    self.showsVerticalScrollIndicator = NO;
    
    self.delegate = self;
    self.dataSource = self;
    
    //设置减速的方式， UIScrollViewDecelerationRateFast 为快速减速
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.directionalLockEnabled = YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemWidth > 10) {
        return self.itemWidth;
    }
    return self.frame.size.width * 1.0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([self.horizonalDelegate respondsToSelector:@selector(horizontalTableDidEndDecelerating:)]) {
        
        [self.horizonalDelegate horizontalTableDidEndDecelerating:scrollView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.horizonaldataSource numberOfRowsInSectionWithHorizonalableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.horizonaldataSource horizonalableView:tableView
                                                  cellForRowAtIndexPath:indexPath];
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

#pragma mark - setter
- (void)setSelectedInex:(NSInteger)selectedInex {
    
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedInex
                                                    inSection:0]
                atScrollPosition:UITableViewScrollPositionTop
                        animated:YES];
    
    _selectedInex = selectedInex;
}

//当前选中的单元格Index
- (void)setSelectedInex:(NSInteger)selectedInex animated:(BOOL)animated
{
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedInex
                                                    inSection:0]
                atScrollPosition:UITableViewScrollPositionTop
                        animated:animated];
    
    _selectedInex = selectedInex;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
