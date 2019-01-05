//
//  JATopRuleCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JATopRuleCell.h"

@interface JATopRuleCell ()

@property (nonatomic, weak) UILabel *label;
@end

@implementation JATopRuleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTopRuleCellUI];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupTopRuleCellUI
{
    UILabel *label = [[UILabel alloc] init];
    _label = label;
    label.text = @" ";
    label.textColor = HEX_COLOR(0x54C7FC);
    label.font = JA_REGULAR_FONT(13);
    label.numberOfLines = 0;
    [self.contentView addSubview:label];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = self.contentView.bounds;
}

- (void)setRuleWordText:(NSString *)ruleWordText
{
    _ruleWordText = ruleWordText;
    
    self.label.text = ruleWordText;
}
@end
