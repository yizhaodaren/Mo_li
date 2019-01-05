//
//  JAMyMedalHeaderView.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMyMedalHeaderView.h"

@implementation JAMyMedalHeaderView


-(void)awakeFromNib{
    [super awakeFromNib];
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2;
    self.headerImageView.clipsToBounds = YES;
    
    self.totalMedalLable.layer.cornerRadius = self.totalMedalLable.size.height/2;
    self.totalMedalLable.clipsToBounds = YES;
    self.totalMedalLable.backgroundColor =  HEX_COLOR(0x6BD379);
    
}
-(void)setMedalNum:(NSInteger)medalNum{
    _medalNum = medalNum;
    //更新获得勋章数量
    
    self.totalMedalLable.text = [NSString stringWithFormat:@"已获得%ld枚",(long)_medalNum];
}

@end
