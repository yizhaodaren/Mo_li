//
//  JARuleView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARuleView.h"

@interface JARuleView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, assign) JARuleViewCellType viewType;
@end

@implementation JARuleView

- (instancetype)ruleViewWithType:(JARuleViewCellType)type
{
    JARuleView *ruleV = [[JARuleView alloc] init];
    ruleV.viewType = type;
    return ruleV;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRuleView];
    }
    return self;
}

- (void)setupRuleView
{
    UITableView *tabelView = [[UITableView alloc] init];
    _tableView = tabelView;
    tabelView.delegate = self;
    tabelView.dataSource = self;
    tabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tabelView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView];
    
    self.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
    self.layer.borderWidth = 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.myheight = self.tableView.contentSize.height;
    self.tableView.frame = self.bounds;
    
    self.lineView.width = 1;
    self.lineView.height = self.height;
    
    if (self.viewType == JARuleViewCellTypeLeft) {
        self.lineView.x = 104;
    }else{
        self.lineView.x = self.width - 104;
    }
    
    if (self.refreshHeight) {
        self.refreshHeight(self.myheight);
    }
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNeedsLayout];

    });
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JARuleViewCell *cell = [[JARuleViewCell alloc] ruleViewCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil type:self.viewType];
    
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JARuleViewCell *sectionView = [[JARuleViewCell alloc] ruleViewCellWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil type:self.viewType];
    sectionView.backgroundColor = HEX_COLOR_ALPHA(0x54C7FC, 0.1);
    
    UIView *sectionV = [[UIView alloc] init];
    sectionV.height = 36;
    sectionV.width = self.width;
    sectionV.backgroundColor = HEX_COLOR_ALPHA(0x54C7FC, 0.1);
    
    UILabel *leftL = [[UILabel alloc] init];
    leftL.text = @" ";
    leftL.textColor = HEX_COLOR(0x4A4A4A);
    leftL.font = JA_MEDIUM_FONT(16);
    [sectionV addSubview:leftL];
    
    UILabel *rightL = [[UILabel alloc] init];
    rightL.text = @" ";
    rightL.textColor = HEX_COLOR(0x4A4A4A);
    rightL.font = JA_MEDIUM_FONT(16);
    [sectionV addSubview:rightL];
    
    UILabel *smallL = [[UILabel alloc] init];
    smallL.text = @"（每项每天只能完成1次）";
    smallL.textColor = HEX_COLOR(0x4A4A4A);
    smallL.font = JA_REGULAR_FONT(12);
    [sectionV addSubview:smallL];
    
    // 获取数据
    JARuleModel *model = self.dataArray[section];
    
    if (model.type.integerValue == 3) {
        sectionV.hidden = NO;
        smallL.hidden = YES;
        leftL.text = @"信用分";
        leftL.width = 104;
        leftL.height = sectionV.height;
        leftL.textAlignment = NSTextAlignmentCenter;
        
        rightL.text = @"权限";
        rightL.width = sectionV.width - leftL.width - 40;
        rightL.height = sectionV.height;
        rightL.x = leftL.right + 20;
        rightL.textAlignment = NSTextAlignmentLeft;
        
    }else if (model.type.integerValue == 1) {
        sectionV.hidden = NO;
        leftL.text = @"加分项";
        leftL.width = sectionV.width - 104 - 40;
        leftL.height = sectionV.height;
        leftL.x = 20;
        leftL.textAlignment = NSTextAlignmentLeft;
        
        rightL.text = @"分数";
        rightL.width = 104;
        rightL.height = sectionV.height;
        rightL.x = leftL.right + 20;
        rightL.textAlignment = NSTextAlignmentCenter;
        
    }else if (model.type.integerValue == 2) {
        sectionV.hidden = NO;
        leftL.text = @"减分项";
        leftL.width = sectionV.width - 104 - 40;
        leftL.height = sectionV.height;
        leftL.x = 20;
        leftL.textAlignment = NSTextAlignmentLeft;
        
        rightL.text = @"分数";
        rightL.width = 104;
        rightL.height = sectionV.height;
        rightL.x = leftL.right + 20;
        rightL.textAlignment = NSTextAlignmentCenter;
        
    }else{
        sectionV.hidden = YES;
        
    }
    
    return sectionV;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JARuleModel *model = self.dataArray[indexPath.row];
    self.myheight = tableView.contentSize.height;
    return model.cellHeight;
}
@end
