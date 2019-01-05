//
//  JAWithDrawRecordCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawRecordCell.h"

@interface JAWithDrawRecordCell ()

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *middleLabel;
@property (nonatomic, weak) UILabel *rightLabel;

@property (nonatomic, strong) NSDictionary *approveDic;
@end

@implementation JAWithDrawRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupWithDrawRecordCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

//        self.approveDic = @{
//                            @"approve_not" : @"待审核\n需3-5工作日",
//                            @"approve_success" : @"处理中\n红包在路上",
//                            @"approve_fail" : @"审核未通过\n收入来源异常",
//                            @"approve_deposit_success" : @"提现成功\n红包已到账",
//                            @"approve_deposit_fail" : @"转账失败\n零钱已退回"
//                            };
    }
    return self;
}

- (void)setupWithDrawRecordCell
{
    UILabel *label1 = [[UILabel alloc] init];
    _leftLabel = label1;
    label1.text = @"微信提现";
    label1.textColor = HEX_COLOR(JA_ListTitle);
    label1.font = JA_REGULAR_FONT(14);
    label1.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label1];
    
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
    label3.textColor = HEX_COLOR(JA_Green);
    label3.font = JA_REGULAR_FONT(14);
    label3.textAlignment = NSTextAlignmentCenter;
    label3.numberOfLines = 0;
    [self.contentView addSubview:label3];
}

- (void)setModel:(JAWithDrawRecordModel *)model
{
    _model = model;
    
    self.leftLabel.text = [NSString stringWithFormat:@"微信提现%@元",model.money];
    NSString *timeS = [NSString timeAndDateToString:model.createTime];
    NSString *timeStr = [timeS stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    self.middleLabel.text = timeStr;
    
//    self.rightLabel.text = self.approveDic[model.isApprove];
    self.rightLabel.text = model.desc;
    
    if ([model.isApprove isEqualToString:@"approve_fail"]) {
        self.rightLabel.textColor = HEX_COLOR(0xFF4D4D);
    }else{
        self.rightLabel.textColor = HEX_COLOR(JA_Green);
    }
    [self.rightLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorWithDrawRecordCell];
}

- (void)caculatorWithDrawRecordCell
{
    [self.leftLabel sizeToFit];
    self.leftLabel.height = self.contentView.height;
    self.leftLabel.centerY = self.contentView.height * 0.5;
    self.leftLabel.x = 14;
    
    [self.middleLabel sizeToFit];
    self.middleLabel.height = self.leftLabel.height;
    self.middleLabel.centerY = self.contentView.height * 0.5;
    self.middleLabel.centerX = self.contentView.width * 0.5;
    
    [self.rightLabel sizeToFit];
    self.rightLabel.height = self.leftLabel.height;
    self.rightLabel.centerY = self.contentView.height * 0.5;
    self.rightLabel.x = JA_SCREEN_WIDTH - 14 - self.rightLabel.width;
}
@end
