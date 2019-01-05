//
//  JAMarkCollectionViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/18.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkCollectionViewCell.h"
#import "JAMarkTaskTableViewCell.h"

@interface JAMarkCollectionViewCell ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UIView *pointView1;  // 点1
@property (nonatomic, weak) UILabel *nameLabel;  // 升级任务label
@property (nonatomic, weak) UIView *pointView2;  // 点2

@property (nonatomic, weak) UITableView *tableView;  // tableview
@end

@implementation JAMarkCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMarkCollectionViewCellUI];
    }
    return self;
}

#pragma mark - 赋值
- (void)setModel:(JAMarkModel *)model
{
    _model = model;
    [self.tableView reloadData];
}

#pragma mark - 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.tasks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 计算高度
    JAMarkTaskModel *taskM = self.model.tasks[indexPath.row];
    NSString *title = taskM.taskName;
    
    CGFloat width = WIDTH_ADAPTER(180);
    CGSize maxS = CGSizeMake(width, MAXFLOAT);
    CGFloat h = [title boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(13)} context:nil].size.height;
    if (h > 18) {
        return h + 14;
    }
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAMarkTaskModel *taskM = self.model.tasks[indexPath.row];
    JAMarkTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAMarkTaskTableViewCell _id"];
    cell.taskModel = taskM;
    return cell;
}

#pragma mark - UI
- (void)setupMarkCollectionViewCellUI
{
    UIImageView *backImageView = [[UIImageView alloc] init];
    _backImageView = backImageView;
    backImageView.image = [UIImage imageNamed:@"barnch_mark_back"];
    [self.contentView addSubview:backImageView];
    
    UIView *pointView1 = [[UIView alloc] init];
    _pointView1 = pointView1;
    pointView1.backgroundColor = HEX_COLOR(0xD8D8D8);
    pointView1.layer.cornerRadius = 3;
    pointView1.layer.masksToBounds = YES;
    [self.backImageView addSubview:pointView1];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"升级任务";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_MEDIUM_FONT(18);
    [self.backImageView addSubview:nameLabel];
    
    UIView *pointView2 = [[UIView alloc] init];
    _pointView2 = pointView2;
    pointView2.backgroundColor = HEX_COLOR(0xD8D8D8);
    pointView2.layer.cornerRadius = 3;
    pointView2.layer.masksToBounds = YES;
    [self.backImageView addSubview:pointView2];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[JAMarkTaskTableViewCell class] forCellReuseIdentifier:@"JAMarkTaskTableViewCell _id"];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    [self.backImageView addSubview:tableView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMarkCollectionViewCellFrame];
}

- (void)calculatorMarkCollectionViewCellFrame
{
    self.backImageView.width = WIDTH_ADAPTER(334);
    self.backImageView.height = WIDTH_ADAPTER(274);
    self.backImageView.centerX = self.contentView.width * 0.5;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.centerX = self.backImageView.width * 0.5;
    self.nameLabel.y = WIDTH_ADAPTER(47);
    
    self.pointView1.width = 6;
    self.pointView1.height = 6;
    self.pointView1.x = self.nameLabel.x - 15 - self.pointView1.width;
    self.pointView1.centerY = self.nameLabel.centerY;
    
    self.pointView2.width = 6;
    self.pointView2.height = 6;
    self.pointView2.x = self.nameLabel.right + 15;
    self.pointView2.centerY = self.nameLabel.centerY;
    
    self.tableView.width = self.backImageView.width - WIDTH_ADAPTER(64);
    self.tableView.height = self.backImageView.height - self.nameLabel.bottom - 14;
    self.tableView.x = WIDTH_ADAPTER(64) - 5;
    self.tableView.y = self.nameLabel.bottom;
}

@end
