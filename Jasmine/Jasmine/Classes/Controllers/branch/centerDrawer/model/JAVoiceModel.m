//
//  JAVoiceModel.m
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceModel.h"

@implementation JAVoiceModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"voiceId" : @"id"};
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        NSInteger count = arc4random()%4;
//        if (count) {
//            NSMutableArray *array = [NSMutableArray array];
//            for (int i=0; i<count; i++) {
//                [array addObject:@"http://file.xsawe.top//file/15090904285312b65b269-104e-47ff-a032-148565255643.jpg"];
//            }
//            self.images = array;
//        }
//    }
//    return self;
//}

- (NSString *)image {
    return @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/150823388192966cc6ddd-e355-4535-b27a-bbbb0e7b4801.png,http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/150823388192966cc6ddd-e355-4535-b27a-bbbb0e7b4801.png,http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/150823388192966cc6ddd-e355-4535-b27a-bbbb0e7b4801.png";
    return @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/150823388192966cc6ddd-e355-4535-b27a-bbbb0e7b4801.png";
}

- (CGFloat)describeHeight {
    if (_describeHeight == 0) {
        if (self.content.length) {
            CGFloat bgWidth = JA_SCREEN_WIDTH-12*2;
            CGFloat describeWidth = bgWidth-15*2;
            CGSize size = [self.content sizeOfStringWithFont:JA_REGULAR_FONT(16) maxSize:CGSizeMake(describeWidth, 18*3+3*2)];
            _describeHeight = size.height;
        } else {
            _describeHeight = 0;
        }
    }
    return _describeHeight;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        CGFloat cellHeight = 144;// 点赞、播放、评论区域高度

        NSMutableArray *images = [[self.image componentsSeparatedByString:@","] mutableCopy];
        [images removeObject:@""];
        if (images.count) {
            if (images.count > 1) {
                cellHeight += self.describeHeight+12*2;
            }
            CGFloat imageW = (JA_SCREEN_WIDTH-12*2-6*2)/3.0;
            CGFloat imageH = imageW*85/113.0;
            cellHeight += imageH+15;
        } else {
            cellHeight += self.describeHeight+12*2;
            cellHeight += 15+50;// 波形图高度
        }
        cellHeight += (15+15);
        _cellHeight = cellHeight;
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

MJCodingImplementation

@end
