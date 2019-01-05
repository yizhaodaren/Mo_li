//
//  JASearchTopView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASearchTopView.h"

@interface JASearchTopView ()
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
@implementation JASearchTopView

+ (instancetype)searchTopView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JASearchTopView class]) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.width = JA_SCREEN_WIDTH;
    self.textF.borderStyle = UITextBorderStyleNone;
    self.textF.font = JA_LIGHT_FONT(15);
    self.textF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    self.backView.layer.cornerRadius = 15;
    self.backView.clipsToBounds = YES;
    

    self.searchCancleButton.titleLabel.font = JA_REGULAR_FONT(15);
    [self.searchCancleButton setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
    [self.searchCancleButton setTitleColor:HEX_COLOR(0x02BFA6) forState:UIControlStateDisabled];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
@end
