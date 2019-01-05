//
//  JASearchHistoryCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASearchHistoryCell.h"

@interface JASearchHistoryCell ()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) UIView *lineView;
@end

@implementation JASearchHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = HEX_COLOR(JA_Background);
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lineView.x = 14;
    self.lineView.width = self.contentView.width - 14;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFirstRow:(BOOL)firstRow
{
    _firstRow = firstRow;
    
    if (firstRow) {
        
        self.iconButton.selected = YES;
        self.titleLabel.text = @"最近浏览";
        self.deleteLabel.hidden = YES;
    }else{
        self.iconButton.selected = NO;
        self.deleteLabel.hidden = NO;
    }
}

- (void)setModel:(NSString *)model
{
    _model = model;
   
    if (!self.firstRow) {
        
        self.titleLabel.text = model;
    }
}
@end
