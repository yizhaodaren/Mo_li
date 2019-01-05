//
//  JARichContentUtil.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JARichImageModel.h"

@interface JARichContentUtil : NSObject

+ (BOOL)shouldShowPlaceHolderFromRichContents:(NSArray*)richContents;
// 保存图片到本地
+ (NSString*)saveImageToLocal:(UIImage*)image;
+ (void)deleteImageContent:(JARichImageModel*)imgContent;
// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content;
// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content minHeight:(float)minHeight;
// 验证内容不为空
+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents;
+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents isIgnoreImage:(BOOL)isIgnoreImage;
// 获取已写字数
+ (NSInteger)getTextCount:(NSArray*)richContents;

@end
