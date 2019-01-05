//
//  JACheckExchangeCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckExchangeCell.h"

@interface JACheckExchangeCell ()

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *leftLabel1;
@property (nonatomic, weak) UILabel *middleLabel;
@property (nonatomic, weak) UILabel *rightLabel;
@property (nonatomic, weak) UILabel *rightLabel1;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) NSDictionary *approveDic;
@end

@implementation JACheckExchangeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupWithCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.approveDic = @{
                            @"approve_not" : @"待审核",
                            @"approve_success" : @"处理中",
                            @"approve_fail" : @"审核未通过",
                            @"approve_deposit_success" : @"提现成功"
                            
                            };
    }
    return self;
}

- (void)setupWithCell
{
    UILabel *label1 = [[UILabel alloc] init];
    _leftLabel = label1;
    label1.text = @"每日发帖任务";
    label1.textColor = HEX_COLOR(JA_ListTitle);
    label1.font = JA_REGULAR_FONT(14);
    label1.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label1];
    
    UILabel *label11 = [[UILabel alloc] init];
    _leftLabel1 = label11;
    label11.text = @"+80朵";
    label11.textColor = HEX_COLOR(JA_BlackSubTitle);
    label11.font = JA_REGULAR_FONT(12);
    label11.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label11];
    
    UILabel *label2 = [[UILabel alloc] init];
    _middleLabel = label2;
    label2.text = @"2017.08.23\n13:13:13";
    label2.textColor = HEX_COLOR(JA_ListTitle);
    label2.font = JA_REGULAR_FONT(14);
    label2.numberOfLines = 0;
    label2.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] init];
    _rightLabel = label3;
    label3.text = @"待审核";
    label3.textColor = HEX_COLOR(0x525252);
    label3.font = JA_REGULAR_FONT(14);
    label3.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label3];
    
    UILabel *label33 = [[UILabel alloc] init];
    _rightLabel1 = label33;
    label33.text = @"收入审核中";
    label33.textColor = HEX_COLOR(JA_BlackSubTitle);
    label33.font = JA_REGULAR_FONT(12);
    label33.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label33];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)setModel:(JACheckExchangeModel *)model
{
    _model = model;
    
    if ([model.type isEqualToString:JA_STORY_TYPE]) {
        
        self.leftLabel.text = @"每日发帖任务";
    }else{
        
        self.leftLabel.text = @"每日回复任务";
    }
    
    self.leftLabel1.text = [NSString stringWithFormat:@"+%@",model.taskFlowerCount];
    
    NSString *timeS = [NSString timeAndDateToString:model.createTime];
    NSString *timeStr = [timeS stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    self.middleLabel.text = timeStr;
    
    if (model.deleted.integerValue == 1) {
        
        // 审核未通过
        self.rightLabel.text = @"审核未通过";
        self.rightLabel.textColor = HEX_COLOR(0xFE3824);
        
        self.rightLabel1.text = @"收入已扣除";
        self.rightLabel1.textColor = HEX_COLOR(0xFC7A56);
        
    }else{
        
        // 审核中 或者 审核通过
        if (model.isExamine.integerValue == 0) {
            self.rightLabel.text = @"待审核";
            self.rightLabel.textColor = HEX_COLOR(0x525252);
            
            self.rightLabel1.text = @"收入审核中";
            self.rightLabel1.textColor = HEX_COLOR(0x9B9B9B);
        }else{
            
            self.rightLabel.text = @"审核通过";
            self.rightLabel.textColor = HEX_COLOR(0x31C27C);
            
            self.rightLabel1.text = @"收入已获得";
            self.rightLabel1.textColor = HEX_COLOR(0x31C27C);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorWithDrawRecordCell];
}

- (void)caculatorWithDrawRecordCell
{
    [self.leftLabel sizeToFit];
    self.leftLabel.height = 20;
    self.leftLabel.y = 7;
    self.leftLabel.x = 14;
    
    [self.leftLabel1 sizeToFit];
    self.leftLabel1.height = 17;
    self.leftLabel1.y = self.leftLabel.bottom + 3;
    self.leftLabel1.centerX = self.leftLabel.centerX;
    
    [self.middleLabel sizeToFit];
    self.middleLabel.width = 200;
    self.middleLabel.height = self.contentView.height;
    self.middleLabel.centerY = self.contentView.height * 0.5;
    self.middleLabel.centerX = self.contentView.width * 0.5;
    
    [self.rightLabel sizeToFit];
    self.rightLabel.height = 20;
    self.rightLabel.y = 7;
    self.rightLabel.x = JA_SCREEN_WIDTH - 20 - self.rightLabel.width;
    
    [self.rightLabel1 sizeToFit];
    self.rightLabel1.height = 17;
    self.rightLabel1.y = self.rightLabel.bottom + 3;
    self.rightLabel1.centerX = self.rightLabel.centerX;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}
@end
