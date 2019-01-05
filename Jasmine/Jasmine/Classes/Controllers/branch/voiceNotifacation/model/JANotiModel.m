//
//  JANotiModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANotiModel.h"

@implementation JANotiModel

- (CGFloat)cellHeight
{
    if (_cellHeight == 0 || self.cellHeightVersion == 0) {  // 兼容老版本 刷新高度
        
        self.cellHeightVersion = 1; // 兼容老版本 刷新高度
        
        if ([self.operation isEqualToString:@"reply"]) {
            
            // 计算
            CGFloat h = 0;
            if (self.content.audioUrl.length) {
                h = 158;
            }else{
                h = 112;
            }
            _cellHeight = h;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 75, MAXFLOAT);
            CGFloat height = [self.content.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _cellHeight = h + height;
            
        }else if ([self.operation isEqualToString:@"action"]){
            
            _cellHeight = 103;
            
        }else if ([self.operation isEqualToString:@"invite"]){
            
            _cellHeight = 116;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 75, MAXFLOAT);
            CGFloat height = [self.content.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _cellHeight = 116 + height;
            
        }else if ([self.operation isEqualToString:@"friend"]){
            
            _cellHeight = 65;
        }else if ([self.operation isEqualToString:@"atuser"]){
            
            if ([self.content.type isEqualToString:@"story"]) {
//                _cellHeight = 116;
                CGFloat h = 0;
                if (self.content.audioUrl.length) {
                    h = 116;
                }else{
                    h = 70;
                }
                
                CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 75, MAXFLOAT);
                CGFloat height = [self.content.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
                
                _cellHeight = h + height;
            }else{
                // 计算
                CGFloat h = 0;
                if (self.content.audioUrl.length) {
                    h = 118;
                }else{
                    h = 72;
                }
                _cellHeight = h;
                
                CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 75, MAXFLOAT);
                CGFloat height = [self.content.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
                
                _cellHeight = h + height;
            }
        }
    }
    
    return _cellHeight;
}

// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"notiTable_%@",name_uid];
}
@end
