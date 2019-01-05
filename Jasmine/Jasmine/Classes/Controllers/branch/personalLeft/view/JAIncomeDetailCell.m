//
//  JAIncomeDetailCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAIncomeDetailCell.h"
#import "JATaskRowModel.h"

@interface JAIncomeDetailCell ()

@property (nonatomic, weak) UILabel *title_label;
@property (nonatomic, weak) UILabel *subtitle_label;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) NSMutableDictionary *flowerTypeDic;
@property (nonatomic, strong) NSMutableDictionary *moneyTypeDic;
@end

@implementation JAIncomeDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupIncomeCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        
    }
    return self;
}

- (void)setupIncomeCellUI
{
    
    UILabel *title_label = [[UILabel alloc] init];
    _title_label = title_label;
    title_label.text = @"注册获得红包";
    title_label.textColor = HEX_COLOR(0x252A34);
    title_label.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:title_label];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    timeLabel.font =  JA_LIGHT_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    UILabel *subtitle_label = [[UILabel alloc] init];
    _subtitle_label = subtitle_label;
    subtitle_label.text = @"+1元";
    subtitle_label.textColor = HEX_COLOR(JA_ListTitle);
    subtitle_label.font = JA_MEDIUM_FONT(14);
    [self.contentView addSubview:subtitle_label];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    [self.title_label sizeToFit];
    self.title_label.height = 20;
    self.title_label.x = 14;
    self.title_label.y = self.contentView.height * 0.5 - 20;
    
    self.timeLabel.height = 20;
    self.timeLabel.x = 14;
    self.timeLabel.y = self.contentView.height * 0.5;
    
    [self.subtitle_label sizeToFit];
    self.subtitle_label.height = 20;
    self.subtitle_label.x = self.contentView.width - self.subtitle_label.width - 14;
    self.subtitle_label.centerY = self.contentView.height * 0.5;
    
    self.lineView.y = self.contentView.height - 1;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
}

- (void)setFlowerModel:(JAWithDrawFlowerModel *)flowerModel
{
    _flowerModel = flowerModel;
    
//    self.title_label.text = self.flowerTypeDic[flowerModel.operationType];
    self.title_label.text = flowerModel.desc;
    
    if ([flowerModel.dataType isEqualToString:@"increase"]) {  //+
        
        self.subtitle_label.text = [NSString stringWithFormat:@"+%ld朵",[flowerModel.changeCount integerValue]];
        self.subtitle_label.textColor = HEX_COLOR(0x6BD379);
    }else{
        self.subtitle_label.text = [NSString stringWithFormat:@"-%ld朵",[flowerModel.changeCount integerValue]];
        self.subtitle_label.textColor = HEX_COLOR(0xFF7054);
    }
    
    self.timeLabel.text = [NSString timeAndDateToString:flowerModel.createTime];
    [self.timeLabel sizeToFit];
}

- (void)setMoneyModel:(JAWithDrawMoneyModel *)moneyModel
{
    _moneyModel = moneyModel;
    
//    self.title_label.text = self.moneyTypeDic[moneyModel.operationType];
    self.title_label.text = moneyModel.desc;
    
    if ([moneyModel.dataType isEqualToString:@"increase"]) {  // +
        self.subtitle_label.text = [NSString stringWithFormat:@"+%@元",[self decimalNumberWithDouble:moneyModel.changeMoney]];
        self.subtitle_label.textColor = HEX_COLOR(0x6BD379);
    }else{
        self.subtitle_label.text = [NSString stringWithFormat:@"-%@元",[self decimalNumberWithDouble:moneyModel.changeMoney]];
        self.subtitle_label.textColor = HEX_COLOR(0xFF7054);
    }
    
    self.timeLabel.text = [NSString timeAndDateToString:moneyModel.createTime];
    [self.timeLabel sizeToFit];
}


/** 直接传入精度丢失有问题的Double类型*/
- (NSString *)decimalNumberWithDouble:(double)conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

@end
