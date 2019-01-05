//
//  JAVoiceCommentModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceCommentModel.h"

@implementation JAVoiceCommentModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"voiceCommendId" : @"id"};
}

// 计算评论中的cell的高度
- (CGFloat)cellHeight
{
    if (_cellHeight == 0 || self.refreshModel) {
        
        if (self.refreshModel) {
            self.refreshModel = NO;
        }
        
        // 神回复
        if (self.sort.integerValue == 1) {     // 2.3.0 版本改的 =1 的判断
            _leftImageFrame = CGRectMake(0, 0, 20, 20);
        }else{
            _leftImageFrame = CGRectZero;
        }
        
        // 头像
        _iconFrame = CGRectMake(12, 15, 35, 35);
        
        // 姓名
        CGSize size = CGSizeZero;
        if (self.isAnonymous) {  // 是匿名用户
            NSString *n = self.anonymousName.length ? self.anonymousName : @"匿名用户";
            size = [n sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont)}];
        }else{
            size = [self.userName sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont)}];
            
        }
        CGFloat nameX = CGRectGetMaxX(_iconFrame) + 10;
        CGFloat nameY = 15;
        CGFloat nameW = size.width;
        if ((nameX + nameW) > JA_SCREEN_WIDTH * 0.5) {
            nameW = JA_SCREEN_WIDTH * 0.5 - nameX;
        }
        _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
        
        // 箭头
        _arrowFrame = CGRectZero;
        
        // 被回复者姓名
        _beReplyNameFrame = CGRectZero;
        
        if ([self.userId isEqualToString:self.voiceStoryUserId]) {  //  && !self.isAnonymous
            
            // 帖主标签
            _nameTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 34, 16);
        }else{
            // 帖主标签
            _nameTagFrame = CGRectZero;
        }
        
        // floorFrame
        NSString *floorStr = [NSString stringWithFormat:@"第%ld楼 |",self.floorCount];
        size = [floorStr sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(12)}];
        _floorFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_nameFrame) + 1, size.width, 14);
        
        // 时间
        NSString *voicetime = [NSString distanceTimeWithBeforeTime:self.createTime.doubleValue];
        size = [voicetime sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(12)}];
        _timeFrame = CGRectMake(CGRectGetMaxX(_floorFrame) + 3, CGRectGetMaxY(_nameFrame) + 1, size.width + 10, 14);
        
        // 点赞
        _agreeFrame = CGRectMake(JA_SCREEN_WIDTH - 60, _iconFrame.origin.y, 60, 35);
        
        // 三个点
//        _pointFrame = CGRectMake(CGRectGetMaxX(_agreeFrame), _agreeFrame.origin.y, 50, 35);
        _pointFrame = CGRectZero;
        
        if (self.audioUrl.length) {   // 表示有音频
//            // 播放按钮
//            _playFrame = CGRectMake(12, CGRectGetMaxY(_iconFrame) + 15, 35, 35);
//
//            // 波形图
//            CGFloat voiceWaveFrameX = CGRectGetMaxX(_playFrame) + 7;
//            CGFloat voiceWaveFrameY = _playFrame.origin.y - (40 - _playFrame.size.height) * 0.5;
//            CGFloat voiceWaveFrameW = JA_SCREEN_WIDTH - voiceWaveFrameX - 15;
//            _voiceWaveFrame = CGRectMake(CGRectGetMaxX(_playFrame) + 7, voiceWaveFrameY, voiceWaveFrameW, 40);
//
//            // 时长
//            _durationFrame = CGRectMake(_playFrame.origin.x, CGRectGetMaxY(_playFrame) + 10, 35, 18);
            
            _annimateFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_iconFrame) + 15, 210, 35);
            
            // 标题
            CGFloat titleFrameX = _nameFrame.origin.x;
            CGFloat titleFrameY = CGRectGetMaxY(_annimateFrame) + 12;
            CGFloat titleFrameW = JA_SCREEN_WIDTH - titleFrameX - 15;
            CGSize max = CGSizeMake(titleFrameW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil];
            
            _titleFrame = CGRectMake(titleFrameX, titleFrameY, titleFrameW, rect.size.height);
            
        }else{   // 表示没有音频
//            // 播放按钮
//            _playFrame = CGRectZero;
//
//            // 波形图
//            _voiceWaveFrame = CGRectZero;
//
//            // 时长
//            _durationFrame = CGRectZero;
            
            _annimateFrame = CGRectZero;
            
            // 标题
            CGFloat titleFrameX = _nameFrame.origin.x;
            CGFloat titleFrameY = CGRectGetMaxY(_timeFrame) + 10;
            CGFloat titleFrameW = JA_SCREEN_WIDTH - titleFrameX - 15;
            CGSize max = CGSizeMake(titleFrameW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil];
            
            _titleFrame = CGRectMake(titleFrameX, titleFrameY, titleFrameW, rect.size.height);
        }
        
        if (self.s2cReplyMsg) {   // 有回复
            
            // 底部被回复
            _bottomBeReplyFrame = CGRectMake(54, CGRectGetMaxY(_titleFrame) + 10, JA_SCREEN_WIDTH - 54 - 15, 70);
            
            // 回复内容的播放按钮
            if (self.s2cReplyMsg.audioUrl.length) {   // 回复有音频
                _replyPlayFrame = CGRectMake(10, 10, 20, 20);
            }else{
                _replyPlayFrame = CGRectZero;
            }
            
            // 回复内容的作者
            CGSize replyNameSize = CGSizeZero;
            if (self.s2cReplyMsg.isAnonymous) {  // 是匿名用户
                NSString *n = self.s2cReplyMsg.userAnonymousName.length ? self.s2cReplyMsg.userAnonymousName : @"匿名用户";
                replyNameSize = [n sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_replyPersonalFont)}];
            }else{
                replyNameSize = [self.s2cReplyMsg.userName sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_replyPersonalFont)}];
            }
            
            CGFloat replyNameFrameX = CGRectGetMaxX(_replyPlayFrame) == 0 ? 10 : CGRectGetMaxX(_replyPlayFrame) + 7;
            
            _replyNameFrame = CGRectMake(replyNameFrameX, 10, replyNameSize.width, 20);
            
            // 回复者是作者的标签
            if ([self.s2cReplyMsg.userId isEqualToString:self.voiceStoryUserId]) { //  && !self.s2cReplyMsg.isAnonymous
                _replyNameTagFrame = CGRectMake(CGRectGetMaxX(_replyNameFrame) + 3, _replyNameFrame.origin.y + 2, 34, 16);
            }else{
                _replyNameTagFrame = CGRectZero;
            }
            
            // 回复内容的标题
            CGFloat replyTitleFrameX = _replyNameTagFrame.size.width == 0 ? CGRectGetMaxX(_replyNameFrame) : CGRectGetMaxX(_replyNameTagFrame);
            CGFloat replyTitleFrameY = _replyNameFrame.origin.y;
            CGFloat replyTitleFrameW = _bottomBeReplyFrame.size.width - replyTitleFrameX - 5;
            
            _replyTitleFrame = CGRectMake(replyTitleFrameX, replyTitleFrameY, replyTitleFrameW, 20);
            
            // 全部回复按钮
            _allReplyFrame = CGRectMake(10, CGRectGetMaxY(_replyNameFrame) + 10, _bottomBeReplyFrame.size.width - 20, 20);
            
            // 线
            _lineFrame = CGRectMake(0, CGRectGetMaxY(_bottomBeReplyFrame) + 15, JA_SCREEN_WIDTH, 1);
            
        }else{         // 没有回复
            
            // 底部被回复
            _bottomBeReplyFrame = CGRectZero;
            
            // 回复内容的播放按钮
            _replyPlayFrame = CGRectZero;
            
            // 回复内容的作者
            _replyNameFrame = CGRectZero;
            
            // 回复者是作者的标签
            _replyNameTagFrame = CGRectZero;
            
            // 回复内容的标题
            _replyTitleFrame = CGRectZero;
            
            // 全部回复按钮
            _allReplyFrame = CGRectZero;
            
            // 线
            _lineFrame = CGRectMake(0, CGRectGetMaxY(_titleFrame) + 15, JA_SCREEN_WIDTH, 1);
        }
        
        _cellHeight = CGRectGetMaxY(_lineFrame);
        
    }
    
    return _cellHeight;
}


- (CGFloat)replyPosetsCellHeight
{
    if (_replyPosetsCellHeight == 0) {
        
        if (self.audioUrl.length) {
            
            _replyPosetsCellHeight = 178;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 72, MAXFLOAT);
            CGFloat height = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _replyPosetsCellHeight = 178 + height;
        }else{
           
            _replyPosetsCellHeight = 128;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 72, MAXFLOAT);
            CGFloat height = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _replyPosetsCellHeight = 128 + height;
            
        }
        
    }
    
    return _replyPosetsCellHeight;
}

- (NSString *)sourceName
{
    if (!_sourceName.length) {
        return @"无法获取该属性";
    }
    return _sourceName;
}

- (NSString *)recommendType {
    if (!_recommendType.length) {
        return @"无法获取该属性";
    }
    return _recommendType;
}
@end
