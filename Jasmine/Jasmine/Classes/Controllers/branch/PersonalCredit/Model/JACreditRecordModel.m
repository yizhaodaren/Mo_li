//
//  JACreditRecordModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACreditRecordModel.h"

@implementation JACreditRecordModel

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
//        NSDictionary *dic = @{
//                              @"story_comment_add" : @"每日发帖",
//                              @"login" : @"每日签到",
//                              @"story_or_comment_sort" : @"帖子被加为精华",
//                              @"god_comment" : @"评论被加为神回复",
//                              @"share_platform" : @"分享帖子到社交平台",
//                              
//                              @"del_story_comment_content_not" : @"内容因「内容表意不明」」被删除",
//                              @"del_story_comment_noise" : @"内容因「内容噪音过大」被删除",
//                              @"del_story_comment_pornographic" : @"内容因「含垃圾广告信息」、「含政治敏感信息」、「含低俗色情内容」、「含侮辱性词汇」被删除",
//                              @"del_story_comment_day" : @"一天内发布违规内容被删除过2次，再次发布违规内容被删除 信用分减分提升4倍",
//                              @"del_story_comment_week" : @"一周内发布违规内容被删除过10次，再次发布违规内容被删除 信用分减分提升8倍",
//                              @"del_story_comment_month" : @"三个月内发布违规内容被删除过50次，再次发布违规内容被删除 信用分扣0",
//                              };
//        
        
        NSString *str = self.content;
        
        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 100 - 14, MAXFLOAT);
        CGFloat height = [str boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_MEDIUM_FONT(14)} context:nil].size.height;
        
        _cellHeight = height + 30;
    }
    
    return _cellHeight;
}
@end
