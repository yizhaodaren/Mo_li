//
//  JACircleNewPublishHeadView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleNewPublishHeadView.h"
#import "JACircleTopVoiceCell.h"

@interface JACircleNewPublishHeadView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;  // 置顶帖子
@property (nonatomic, weak) UIView *lineView;
@end

@implementation JACircleNewPublishHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleNewPublishHeadViewUI];
    }
    return self;
}

- (void)setupCircleNewPublishHeadViewUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    [tableView registerClass:[JACircleTopVoiceCell class] forCellReuseIdentifier:@"JACircleTopVoiceCell_id"];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    
    [self addSubview:tableView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleNewPublishHeadViewFrame];
}

- (void)calculatorCircleNewPublishHeadViewFrame
{
    self.tableView.frame = self.bounds;
    self.tableView.height = self.height - 10;
    self.lineView.width = self.width;
    self.lineView.height = 10;
    self.lineView.y = self.tableView.bottom;
}

- (void)setTopVoiceArray:(NSArray *)topVoiceArray
{
    _topVoiceArray = topVoiceArray;
    [self.tableView reloadData];
}

#pragma mark - tableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.topVoiceArray.count == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(circleNewPublishHeadView_didSelectWithRow:headView:)]) {
        [self.delegate circleNewPublishHeadView_didSelectWithRow:indexPath.row headView:self];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topVoiceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANewVoiceModel *model = self.topVoiceArray[indexPath.row];
    model.sourcePage = @"圈子详情";
    model.sourcePageName = self.circleName;
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANewVoiceModel *model = self.topVoiceArray[indexPath.row];
    JACircleTopVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACircleTopVoiceCell_id"];
    cell.voiceModel = model;
    if (indexPath.row == 0) {
        cell.lineView.hidden = YES;
    }else{
        cell.lineView.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0.01;
}
@end
