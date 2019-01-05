//
//  JARuleViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARuleViewCell.h"

@interface JARuleViewCell ()

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *rightLabel;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, assign) JARuleViewCellType cellType;
@end

@implementation JARuleViewCell

- (instancetype)ruleViewCellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(JARuleViewCellType)type
{
    JARuleViewCell *cell = [[JARuleViewCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    cell.cellType = type;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCellUI];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupCellUI
{
    UILabel *leftLabel = [[UILabel alloc] init];
    _leftLabel = leftLabel;
    leftLabel.text = @" ";
    leftLabel.textColor = HEX_COLOR(0x4A4A4A);
    leftLabel.font = JA_REGULAR_FONT(14);
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.numberOfLines = 0;
    [self.contentView addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    _rightLabel = rightLabel;
    rightLabel.text = @" ";
    rightLabel.textColor = HEX_COLOR(0x4A4A4A);
    rightLabel.font = JA_REGULAR_FONT(14);
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.numberOfLines = 0;
    [self.contentView addSubview:rightLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCellFrame];
}

- (void)caculatorCellFrame
{
    if (self.cellType == JARuleViewCellTypeLeft) {
        
        self.leftLabel.width = 104;
        self.leftLabel.height = self.contentView.height;
        
        self.rightLabel.width = self.contentView.width - self.leftLabel.width - 40;
        self.rightLabel.height = self.contentView.height;
        self.rightLabel.x = self.leftLabel.right + 20;
    }else{
        self.rightLabel.width = 104;
        self.rightLabel.height = self.contentView.height;
        
        self.leftLabel.width = self.contentView.width - self.rightLabel.width - 40;
        self.leftLabel.height = self.contentView.height;
        self.leftLabel.x = 20;
        
        self.rightLabel.x = self.leftLabel.right + 20;
    }
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JARuleModel *)model
{
    _model = model;
    
    self.leftLabel.text = model.actionType;
    self.rightLabel.text = model.conditionBasic;
    if (model.type.integerValue == 3) {
        self.leftLabel.textAlignment = NSTextAlignmentCenter;
        self.rightLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        self.leftLabel.textAlignment = NSTextAlignmentLeft;
        self.rightLabel.textAlignment = NSTextAlignmentCenter;
    }
}
@end
