//
//  JANewCommentModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewCommentModel.h"

@implementation JANewCommentModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"replyList" : [JANewReplyModel class]};
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0 || self.refreshModelHeight) {
        
        if (self.refreshModelHeight) {
            self.refreshModelHeight = NO;
        }
        
        JANewReplyModel *reply = self.replyList.firstObject;
        
        if (self.needActionButton) {
            _goBackButtonFrame = CGRectMake(0, 0, JA_SCREEN_WIDTH, 40);
        }else{
            _goBackButtonFrame = CGRectZero;
        }
        
        // 神回复
        if (self.sort.integerValue == 1) {     // 2.3.0 版本改的 =1 的判断
            _leftImageFrame = CGRectMake(0, _goBackButtonFrame.size.height, 20, 20);
        }else{
            _leftImageFrame = CGRectZero;
        }
        
        // 头像
        _iconFrame = CGRectMake(12, 15 + _goBackButtonFrame.size.height, 35, 35);
        
        // 姓名
        CGSize size = CGSizeZero;
        size = [self.user.userName sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont)}];
        
        CGFloat nameX = CGRectGetMaxX(_iconFrame) + 10;
        CGFloat nameY = 15 + _goBackButtonFrame.size.height;
        CGFloat nameW = size.width;
        if ((nameX + nameW) > JA_SCREEN_WIDTH * 0.5) {
            nameW = JA_SCREEN_WIDTH * 0.5 - nameX;
        }
        _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
        
        // 箭头
        _arrowFrame = CGRectZero;
        
        // 被回复者姓名
        _beReplyNameFrame = CGRectZero;
        
        BOOL hasNameTag = NO;
        BOOL hasCircleTag = NO;
        // 2 判断是否有帖主标签
        if ([self.user.userId isEqualToString:self.storyUserId]) {
            hasNameTag = YES;
        }else{
            hasNameTag = NO;
        }
        
        // 3 判断是否有圈主标签
        if (self.user.isCircleAdmin) {
            hasCircleTag = YES;
        }else{
            hasCircleTag = NO;
        }
        
        if (hasNameTag || hasCircleTag) {
            // 帖主标签
            if (hasNameTag && hasCircleTag) {
                _nameTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 26, 14);
                _circleTagFrame = CGRectMake(CGRectGetMaxX(_nameTagFrame) + 5, _nameTagFrame.origin.y, 26, 14);
            }else if (hasNameTag){
                _nameTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 26, 14);
                _circleTagFrame = CGRectZero;
            }else if (hasCircleTag) {
                _nameTagFrame = CGRectZero;
                _circleTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 26, 14);
            }else{
                _nameTagFrame = CGRectZero;
                _circleTagFrame = CGRectZero;
            }
        }else{
            _nameTagFrame = CGRectZero;
            _circleTagFrame = CGRectZero;
        }
        
        
        // floorFrame
        if (self.floorNum.integerValue > 0) {
            NSString *floorStr = [NSString stringWithFormat:@"第%@楼 |",self.floorNum];
            size = [floorStr sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(12)}];
            _floorFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_nameFrame) + 1, size.width, 14);
        }else{
            _floorFrame = CGRectZero;
        }
        
        // 时间
        NSString *voicetime = [NSString distanceTimeWithBeforeTime:self.createTime.doubleValue];
        size = [voicetime sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(12)}];
        if (_floorFrame.size.width) {
            
            _timeFrame = CGRectMake(CGRectGetMaxX(_floorFrame) + 3, CGRectGetMaxY(_nameFrame) + 1, size.width + 10, 14);
        }else{
            _timeFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_nameFrame) + 1, size.width + 10, 14);

        }
        
        // 点赞
        _agreeFrame = CGRectMake(JA_SCREEN_WIDTH - 60, _iconFrame.origin.y, 60, 35);
        
        // 三个点
        _pointFrame = CGRectZero;
        
        if (self.audioUrl.length) {   // 表示有音频
       
            _annimateFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_iconFrame) + 15, 210, 35);
            
            // 标题
            CGFloat titleFrameX = _nameFrame.origin.x;
            CGFloat titleFrameY = CGRectGetMaxY(_annimateFrame) + 12;
            CGFloat titleFrameW = JA_SCREEN_WIDTH - titleFrameX - 15;
            CGSize max = CGSizeMake(titleFrameW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil];
            
            _titleFrame = CGRectMake(titleFrameX, titleFrameY, titleFrameW, rect.size.height);
            
        }else{   // 表示没有音频
           
            _annimateFrame = CGRectZero;
            
            // 标题
            CGFloat titleFrameX = _nameFrame.origin.x;
            CGFloat titleFrameY = CGRectGetMaxY(_timeFrame) + 10;
            CGFloat titleFrameW = JA_SCREEN_WIDTH - titleFrameX - 15;
            CGSize max = CGSizeMake(titleFrameW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil];
            
            _titleFrame = CGRectMake(titleFrameX, titleFrameY, titleFrameW, rect.size.height);
        }
        
        if (reply) {   // 有回复
            
            // 底部被回复
            _bottomBeReplyFrame = CGRectMake(54, CGRectGetMaxY(_titleFrame) + 10, JA_SCREEN_WIDTH - 54 - 15, 70);
            
            // 回复内容的播放按钮
            if (reply.audioUrl.length) {   // 回复有音频
                _replyPlayFrame = CGRectMake(10, 10, 20, 20);
            }else{
                _replyPlayFrame = CGRectZero;
            }
            
            // 回复内容的作者
            CGSize replyNameSize = CGSizeZero;
            replyNameSize = [reply.user.userName sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_replyPersonalFont)}];
            CGFloat replyNameFrameX = CGRectGetMaxX(_replyPlayFrame) == 0 ? 10 : CGRectGetMaxX(_replyPlayFrame) + 7;
            
            _replyNameFrame = CGRectMake(replyNameFrameX, 10, replyNameSize.width, 20);
            
            // 回复者是作者的标签
            if ([reply.user.userId isEqualToString:self.storyUserId]) { //  && !self.s2cReplyMsg.isAnonymous
                _replyNameTagFrame = CGRectMake(CGRectGetMaxX(_replyNameFrame) + 3, _replyNameFrame.origin.y + 2, 26, 14);
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

- (CGFloat)personCenterCellHeight
{
    if (_personCenterCellHeight == 0) {
        
        if (self.audioUrl.length) {
            
            _personCenterCellHeight = 178;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 72, MAXFLOAT);
            CGFloat height = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _personCenterCellHeight = 178 + height;
        }else{
            
            _personCenterCellHeight = 128;
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 72, MAXFLOAT);
            CGFloat height = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil].size.height;
            
            _personCenterCellHeight = 128 + height;
            
        }
        
    }
    
    return _personCenterCellHeight;
}

//- (NSString *)sourceName
//{
//    if (!_sourceName.length) {
//        return @"无法获取该属性";
//    }
//    return _sourceName;
//}
//
//- (NSString *)recommendType {
//    if (!_recommendType.length) {
//        return @"无法获取该属性";
//    }
//    return _recommendType;
//}
@end
