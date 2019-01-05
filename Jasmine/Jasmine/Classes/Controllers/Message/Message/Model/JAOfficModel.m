//
//  JAOfficModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAOfficModel.h"

#define kScale [self getScale]

@implementation JAOfficModel

+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"time" : @"sendTime",
             @"officId" : @"id"
             };
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
        CGFloat timeW = [_time sizeWithAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(11)}].width + 3;
        CGFloat timeH = 20;
        CGFloat timeX = JA_SCREEN_WIDTH * 0.5 - timeW * 0.5;
        CGFloat timeY = (50 * kScale - timeH) * 0.5;
        
        _timeFrame = CGRectMake(timeX, timeY, timeW, timeH);
        
        CGFloat moliJunX = 15 * kScale;
        CGFloat moliJunY = 50 * kScale;
        CGFloat moliJunW = 45 * kScale;
        CGFloat moliJunH = 45 * kScale;
        
        _moliJunFrame = CGRectMake(moliJunX, moliJunY, moliJunW, moliJunH);
        
        CGFloat valid_maxW = JA_SCREEN_WIDTH - CGRectGetMaxX(_moliJunFrame) - 10 *kScale - 15 * kScale;  // 有效宽度
        
        CGFloat imageX = 10 * kScale;
        CGFloat imageY = 10 * kScale;
        CGFloat imageW = 0;
        CGFloat imageH = 0;
        if (self.image.length) {  // 有图片
            imageW = valid_maxW - 2 * imageX;
            imageH = imageW * 150.0 / 270.0;
        }
        _imageFrame = CGRectMake(imageX, imageY, imageW, imageH);
        
        
        CGFloat titleX = _imageFrame.origin.x;
        CGFloat titleY = _imageFrame.size.height == 0 ? _imageFrame.origin.y : CGRectGetMaxY(_imageFrame) + 8;
        CGFloat titleW = 0;
        CGFloat titleH = 0;
        if (self.title.length) {
            
            titleW = valid_maxW - 2 * titleX;
            
            // 计算高度
            CGSize max = CGSizeMake(titleW, MAXFLOAT);
            CGRect rect = [self.title boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_MEDIUM_FONT(14)} context:nil];
            
            titleH = rect.size.height;
            _titleFrame = CGRectMake(titleX, titleY, titleW, titleH);
        }
        
        CGFloat contentX = _imageFrame.origin.x;
        CGFloat contentY = _titleFrame.size.height == 0 ? _titleFrame.origin.y : CGRectGetMaxY(_titleFrame) + 2;
        CGFloat contentW = 0;
        CGFloat contentH = 0;
        if (self.content.length) {
           
            contentW = valid_maxW - 2 * contentX;
            
            // 计算高度
            CGSize max = CGSizeMake(contentW, MAXFLOAT);
            CGRect rect = [self.content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil];
            contentH = rect.size.height;
            _contentFrame = CGRectMake(contentX, contentY, contentW, contentH);
        }
        
        
        CGFloat backFrameX = CGRectGetMaxX(_moliJunFrame) + 10 *kScale;
        CGFloat backFrameY = moliJunY;
        CGFloat backFrameW = JA_SCREEN_WIDTH - backFrameX - 15 * kScale;
        CGFloat backFrameH = self.content.length ? (CGRectGetMaxY(_contentFrame) + 7) : CGRectGetMaxY(_titleFrame) + 7;
        if (_contentFrame.size.height) {
            backFrameH = CGRectGetMaxY(_contentFrame) + 7;
        }else if (_titleFrame.size.height){
            backFrameH = CGRectGetMaxY(_titleFrame) + 7;
        }else if (_imageFrame.size.height){
            backFrameH = CGRectGetMaxY(_imageFrame) + 7;
        }
        _backFrame = CGRectMake(backFrameX, backFrameY, backFrameW, backFrameH);
        
        CGFloat urlX = 0;
        CGFloat urlY = backFrameH;
        CGFloat urlW = 0;
        CGFloat urlH = 0;
        if ([self.openType integerValue] > 0) {  // 有跳转

            urlW = _backFrame.size.width;
            urlH = 40 * kScale;
            
            _urlFrame = CGRectMake(urlX, urlY, urlW, urlH);
            
            _urlLineFrame = CGRectMake(0, 0, backFrameW, 1);
            _urlButtonFrame = CGRectMake(15, 1, JA_SCREEN_WIDTH - 2 * 14, urlH);
            _urlArrowFrame = CGRectMake(urlW - 6 - 15, urlH * 0.5 - 5, 6, 10);
            
            _backFrame = CGRectMake(backFrameX, backFrameY, backFrameW, backFrameH + urlH);
        }
        
        _cellHeight = CGRectGetMaxY(_backFrame) + 10;
        
        if (_cellHeight < CGRectGetMaxY(_moliJunFrame)) {
            _cellHeight = CGRectGetMaxY(_moliJunFrame) + 10;
        }
    }
    
    return _cellHeight;
}


- (CGFloat)getScale
{
    if ([UIScreen mainScreen].bounds.size.width == 375) {
        
        return 1;
    }else if ([UIScreen mainScreen].bounds.size.width == 414){
        return 414/375.0;
    }else{
        return 320 / 375.0;
    }
}
@end
