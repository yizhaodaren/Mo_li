//
//  JAOtherPersonMedalCollectionViewCell.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAOtherPersonMedalCollectionViewCell.h"

@implementation JAOtherPersonMedalCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.detailLable.textColor = HEX_COLOR(0x9b9b9b);
    self.showingTagLable.layer.cornerRadius = 8;
    self.showingTagLable.clipsToBounds = YES;
    self.showingTagLable.textColor =  HEX_COLOR(0x2CB294);
    self.showingTagLable.backgroundColor = HEX_COLOR(0xE8F9F3);
    
    self.detailLable.textColor = HEX_COLOR(0x9b9b9b);
    self.timeLable.textColor = HEX_COLOR(0x9b9b9b);
    self.backgroundColor = [UIColor whiteColor];
    
}
-(void)setMedalModel:(JAMedalModel *)medalModel{
    _medalModel = medalModel;
    self.titleLable.text = medalModel.medalName;
   [self.medalImageView sd_setImageWithURL:[NSURL URLWithString:medalModel.getImgUrl] placeholderImage:nil];
    //0没有阅览 1已阅读  2佩戴中 3未获得
    if ([medalModel.status isEqualToString:@"2"]) {
        self.showingTagLable.hidden = NO;
    }else{
        self.showingTagLable.hidden = YES;
    }
    //勋章获得条件
    if ([medalModel.medalType isEqualToString:@"1"]) {
        self.detailLable.text = [NSString stringWithFormat:@"连续登录%@天",medalModel.conditionNum];
    }else if([medalModel.medalType isEqualToString:@"2"]){
        self.detailLable.text = [NSString stringWithFormat:@"邀请%@个用户",medalModel.conditionNum];
    }else if([medalModel.medalType isEqualToString:@"3"]){
        self.detailLable.text = [NSString stringWithFormat:@"发布%@个主贴",medalModel.conditionNum];
    }
    self.timeLable.text = [NSString MedalgetDatefromString:medalModel.createTime];
    
}
@end
