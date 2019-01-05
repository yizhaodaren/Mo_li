//
//  JAVoiceReplyModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceReplyModel.h"

@implementation JAVoiceReplyModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"voiceReplyId" : @"id"};
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0 || self.refreshModel) {
        
        if (self.refreshModel) {
            self.refreshModel = NO;
        }
        
        // 神回复
        _leftImageFrame = CGRectZero;
        
        // 头像
        _iconFrame = CGRectMake(12, 15, 35, 35);
        
        BOOL hasArrow = NO;
        BOOL hasNameTag = NO;
        BOOL hasReplyNameTag = NO;
        
        // 1 判断是否有回复指向
        if (![self.replyUserId isEqualToString:self.voiceCommentUserId]) {
            hasArrow = YES;
        }else{
            hasArrow = NO;
        }
        
        // 2 判断是否有帖主标签
        if ([self.userId isEqualToString:self.voiceStoryUserId]) {  //  && !self.isAnonymous
            hasNameTag = YES;
        }else{
            hasNameTag = NO;
        }
        
        if ([self.replyUserId isEqualToString:self.voiceStoryUserId] && !self.replyIsAnonymous) {
            hasReplyNameTag = YES;
        }else{
            hasReplyNameTag = NO;
        }
        
        // 姓名
        CGSize size = CGSizeZero;
        if (self.isAnonymous) {  // 是匿名用户
            NSString *n = self.userAnonymousName.length ? self.userAnonymousName : @"匿名用户";
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
        
        if (hasArrow) {   // 有回复指向
            
            // 被回复者的名字
            CGSize beReplyNameFrameSize = CGSizeZero;
            if (self.replyIsAnonymous) {  // 是匿名用户
                NSString *n = self.replyAnonymousName.length ? self.replyAnonymousName : @"匿名用户";
                beReplyNameFrameSize = [n sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont)}];
            }else{
                beReplyNameFrameSize = [self.replyUserName sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_PersonalDetail_commentPersonalFont)}];
            }
            CGFloat beReplyNameFrameX = 0;
            CGFloat beReplyNameFrameY = _nameFrame.origin.y;
            CGFloat beReplyNameFrameW = beReplyNameFrameSize.width;
           
            if (hasNameTag) {   // 前一个有标签
                
                // 判断名字的长度
                CGFloat maxW = JA_SCREEN_WIDTH - 80 - 57 - 34 - 30 - 13;
                if (beReplyNameFrameW + nameW > maxW) {
                    nameW = nameW > maxW * 0.5 ? maxW * 0.5 : nameW;
                    beReplyNameFrameW = beReplyNameFrameW > maxW * 0.5 ? maxW * 0.5 : beReplyNameFrameW;
                }
                
                _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
                
                // 帖主标签
                _nameTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 34, 16);
                
                // 箭头
                _arrowFrame = CGRectMake(CGRectGetMaxX(_nameTagFrame) + 5, _nameFrame.origin.y, 30, 20);
            
                beReplyNameFrameX = CGRectGetMaxX(_arrowFrame) + 5;
                _beReplyNameFrame = CGRectMake(beReplyNameFrameX, beReplyNameFrameY, beReplyNameFrameW, 20);
                
            }else{
                
                if (hasReplyNameTag) {   // 后一个有帖主的标签
                    
                    // 判断名字的长度
                    CGFloat maxW = JA_SCREEN_WIDTH - 80 - 57 - 34 - 30 - 13;
                    if (beReplyNameFrameW + nameW > maxW) {
                        nameW = nameW > maxW * 0.5 ? maxW * 0.5 : nameW;
                        beReplyNameFrameW = beReplyNameFrameW > maxW * 0.5 ? maxW * 0.5 : beReplyNameFrameW;
                    }
                   
                    _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
                    
                    // 箭头
                    _arrowFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 5, _nameFrame.origin.y, 30, 20);

                    beReplyNameFrameX = CGRectGetMaxX(_arrowFrame) + 5;
                    _beReplyNameFrame = CGRectMake(beReplyNameFrameX, beReplyNameFrameY, beReplyNameFrameW, 20);
                    
                    // 帖主标签
                    _nameTagFrame = CGRectMake(CGRectGetMaxX(_beReplyNameFrame) + 3, _nameFrame.origin.y + 2, 34, 16);
                    
                }else{    // 两个都没有标签
                    
                    // 判断名字的长度
                    CGFloat maxW = JA_SCREEN_WIDTH - 80 - 57 - 30 - 10;
                    if (beReplyNameFrameW + nameW > maxW) {
                        nameW = nameW > maxW * 0.5 ? maxW * 0.5 : nameW;
                        beReplyNameFrameW = beReplyNameFrameW > maxW * 0.5 ? maxW * 0.5 : beReplyNameFrameW;
                    }
                    
                    _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
                    
                    // 箭头
                    _arrowFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 5, _nameFrame.origin.y, 30, 20);

                     beReplyNameFrameX = CGRectGetMaxX(_arrowFrame) + 5;
                    _beReplyNameFrame = CGRectMake(beReplyNameFrameX, beReplyNameFrameY, beReplyNameFrameW, 20);
                    
                }
            }
            
        }else{              // 无回复指向
            
            // 箭头
            _arrowFrame = CGRectZero;
            
            // 被回复者姓名
            _beReplyNameFrame = CGRectZero;
            
            if (hasNameTag) {
                
                // 判断名字的长度
                CGFloat maxW = JA_SCREEN_WIDTH - 80 - 57 - 34 - 3;
                if (nameW > maxW) {
                    nameW = maxW;
                }
                
                _nameFrame = CGRectMake(nameX, nameY, nameW, 20);
                
                _nameTagFrame = CGRectMake(CGRectGetMaxX(_nameFrame) + 3, _nameFrame.origin.y + 2, 34, 16);
                
            }else{
                
                _nameTagFrame = CGRectZero;
            }
        }
        
        // floorFrame;
        _floorFrame = CGRectZero;
        
        // 时间
        CGSize timeSize = CGSizeZero;
        NSString *voicetime = [NSString distanceTimeWithBeforeTime:self.createTime.doubleValue];
        timeSize = [voicetime sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(12)}];
        _timeFrame = CGRectMake(_nameFrame.origin.x, CGRectGetMaxY(_nameFrame) + 1, timeSize.width + 10, 14);
        
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
            
            _annimateFrame = CGRectMake(_timeFrame.origin.x, CGRectGetMaxY(_iconFrame) + 15, 210, 35);

            // 标题
            CGFloat titleFrameX = _timeFrame.origin.x;
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
            CGFloat titleFrameX = _timeFrame.origin.x;
            CGFloat titleFrameY = CGRectGetMaxY(_timeFrame) + 10;
            CGFloat titleFrameW = JA_SCREEN_WIDTH - titleFrameX - 15;
            CGSize max = CGSizeMake(titleFrameW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_commentFont)} context:nil];
            
            _titleFrame = CGRectMake(titleFrameX, titleFrameY, titleFrameW, rect.size.height);
        }
        
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
        
        _cellHeight = CGRectGetMaxY(_lineFrame);
        
    }
    
    return _cellHeight;
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
