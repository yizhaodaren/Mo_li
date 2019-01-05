//
//  JAMarkTaskTableViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/18.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkTaskTableViewCell.h"

@interface JAMarkTaskTableViewCell ()
@property (nonatomic, weak) UIImageView *taskTagImageView;
@property (nonatomic, weak) UILabel *taskNameLabel;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIImageView *finishImageView;
@end

@implementation JAMarkTaskTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupMarkTaskTableViewCellUI];
    }
    return self;
}

- (void)setTaskModel:(JAMarkTaskModel *)taskModel
{
    _taskModel = taskModel;
    self.taskNameLabel.text = taskModel.taskName;
    if (taskModel.taskStatus.integerValue == 0) {
        self.finishImageView.hidden = YES;
        self.lineView.hidden = YES;
        NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.taskNameLabel.text]];
        self.taskNameLabel.attributedText = newPrice;
    }else{
        self.finishImageView.hidden = NO;
        self.lineView.hidden = YES;
        NSMutableAttributedString *newPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.taskNameLabel.text]];
        [newPrice addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, newPrice.length)];
        self.taskNameLabel.attributedText = newPrice;
    }
    
}

#pragma mark - UI
- (void)setupMarkTaskTableViewCellUI
{
    UIImageView *taskTagImageView = [[UIImageView alloc] init];
    _taskTagImageView = taskTagImageView;
    taskTagImageView.image = [UIImage imageNamed:@"barnch_mark_task"];
    [self.contentView addSubview:taskTagImageView];
    
    UILabel *taskNameLabel = [[UILabel alloc] init];
    _taskNameLabel = taskNameLabel;
    taskNameLabel.text = @"给喜欢的内容评论互动一次";
    taskNameLabel.textColor = HEX_COLOR(0x9B9B9B);
    taskNameLabel.font = JA_REGULAR_FONT(13);
    taskNameLabel.numberOfLines = 0;
    [self.contentView addSubview:taskNameLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0x9B9B9B);
    [self.contentView addSubview:lineView];
    
    UIImageView *finishImageView = [[UIImageView alloc] init];
    _finishImageView = finishImageView;
    finishImageView.image = [UIImage imageNamed:@"barnch_mark_taskFinish"];
    [self.contentView addSubview:finishImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMarkTaskTableViewCellFrame];
}

- (void)calculatorMarkTaskTableViewCellFrame
{
    self.taskNameLabel.width = WIDTH_ADAPTER(180);// - WIDTH_ADAPTER(64) - 12 - 16 - 20;
    [self.taskNameLabel sizeToFit];
    if (self.taskNameLabel.width > WIDTH_ADAPTER(180)) {
        self.taskNameLabel.width = WIDTH_ADAPTER(180);
    }
    self.taskNameLabel.y = self.contentView.height - self.taskNameLabel.height;
    
    self.taskTagImageView.width = 12;
    self.taskTagImageView.height = 12;
    self.taskTagImageView.centerY = self.taskNameLabel.y + 9;
    
    self.taskNameLabel.x = self.taskTagImageView.right + 10;
    
    self.lineView.width = self.taskNameLabel.width;
    self.lineView.height = 1;
    self.lineView.centerY = self.taskTagImageView.centerY;
    self.lineView.x = self.taskNameLabel.x;
    
    self.finishImageView.width = 16;
    self.finishImageView.height =12;
    self.finishImageView.x = self.taskNameLabel.right + 10;
    self.finishImageView.centerY = self.taskTagImageView.centerY;
}
@end
