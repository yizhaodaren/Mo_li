//
//  JANewVoiceModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewVoiceModel.h"
#import "JASampleHelper.h"
#import "JACommonHelper.h"

@implementation JAVoicePhoto
MJCodingImplementation
@end

@implementation JANewVoiceModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"photos":[JAVoicePhoto class]
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"searchStoryId" : @"id"};
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.agreeCount = @"0";
        self.commentCount = @"0";
        self.playCount = @"0";
        self.shareCount = @"0";
    }
    return self;
}

- (CGFloat)describeHeight {
    if (_describeHeight == 0) {
        NSString *displayStr = nil;
        if (self.title.length) {
            displayStr = self.title;
        } else {
            displayStr = self.content;
        }
        CGFloat describeWidth = JA_SCREEN_WIDTH-30;
        CGSize size = [displayStr sizeOfStringWithFont:JA_REGULAR_FONT(18) maxSize:CGSizeMake(describeWidth, 50)];
        _describeHeight = size.height;
    }
    return _describeHeight;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        CGFloat cellHeight = 20+40+15;
        cellHeight += self.describeHeight;
        if (self.storyType == 0) {
            // 语音
            cellHeight += 15+50;
        }else{
            if (self.title.length && self.content.length) {
                cellHeight += 20;
            }
        }
        if (self.photos.count) {
            cellHeight += 15;
//            if (self.photos.count == 1) {
//                JAVoicePhoto *photo = self.photos.firstObject;
//                CGSize imageSize = CGSizeMake(photo.width, photo.height);
//                self.imageViewSize =  [JACommonHelper getListImageSize:imageSize];
//            } else {
//                CGFloat imageW = (JA_SCREEN_WIDTH-15*2-WIDTH_ADAPTER(3)*2)/3.0;
//                CGFloat imageH = imageW;
//                self.imageViewSize = CGSizeMake(imageW, imageH);
//            }
            cellHeight += self.imageViewSize.height;
        }
        cellHeight += 15+20+20;
        _cellHeight = cellHeight;
    }
    return _cellHeight;
}

- (CGSize)imageViewSize {
    CGSize size = CGSizeZero;
    if (self.photos.count == 1) {
        JAVoicePhoto *photo = self.photos.firstObject;
        CGSize imageSize = CGSizeMake(photo.width, photo.height);
        size =  [JACommonHelper getListImageSize:imageSize];
    } else {
        CGFloat imageW = (JA_SCREEN_WIDTH-15*2-WIDTH_ADAPTER(3)*2)/3.0;
        CGFloat imageH = imageW;
        size = CGSizeMake(imageW, imageH);
    }
    _imageViewSize = size;
    return _imageViewSize;
}

- (CGFloat)detailDescribeHeight {
    if (_detailDescribeHeight == 0) {
        CGFloat describeWidth = JA_SCREEN_WIDTH-30;
        CGSize size = [self.content sizeOfStringWithFont:JA_REGULAR_FONT(18) maxSize:CGSizeMake(describeWidth, 1000)];
        _detailDescribeHeight = size.height;
    }
    return _detailDescribeHeight;
}

- (CGFloat)detailCellHeight {
    if (_detailCellHeight == 0) {
        CGFloat cellHeight = 20+40+15;
        cellHeight += self.detailDescribeHeight;
        if (self.storyType == 0) {
            // 语音
            cellHeight += 15+50;
        }
        if (self.photos.count) {
            cellHeight += 15;
            cellHeight += self.imageViewSize.height;
        }
        cellHeight += 15+20+20;
        _detailCellHeight = cellHeight;
    }
    return _detailCellHeight;
}

- (NSArray *)allPeakLevelQueue
{
    if (_allPeakLevelQueue.count == 0) {
       _allPeakLevelQueue = [JASampleHelper getAllPeakLevelQueueWithSampleZip:self.sampleZip];
    }
    return _allPeakLevelQueue;
}

// 我的投稿用高度
- (CGFloat)contrbuteHeight
{
    if (_contrbuteHeight == 0) {
        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 60, MAXFLOAT);
        CGFloat height = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_MEDIUM_FONT(15)} context:nil].size.height;
        
        _contrbuteHeight = 15 + 15 + height + 15 + 35 + 10 + 18 + 10;
    }
    
    return _contrbuteHeight;
}

MJCodingImplementation
@end
