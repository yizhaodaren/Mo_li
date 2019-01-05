//
//  JARichContentUtil.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichContentUtil.h"
#import "JARichTextModel.h"
#import "JARichTextView.h"
#import "JARichImageModel.h"

@implementation JARichContentUtil

// 是否需要显示placeholder
+ (BOOL)shouldShowPlaceHolderFromRichContents:(NSArray*)richContents {
    if (richContents.count == 1) {
        id content = richContents.firstObject;
        if ([content isKindOfClass:[JARichTextModel class]]) {
            JARichTextModel* textContent = (JARichTextModel*)content;
            if (textContent.textContent.length <= 0 || [textContent.textContent isEqualToString:@"\n"]) {
                return YES;
            }
        }
    }
    return NO;
}

// 保存图片到本地
+ (NSString*)saveImageToLocal:(UIImage*)image {
    NSData *imagedata = UIImageJPEGRepresentation(image, 1.0);
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",uuidString];
    NSString *filePath = [NSString ja_getUploadImageFilePath:imageName];
    BOOL result = [imagedata writeToFile:filePath atomically:YES];
    if (result) {
        return imageName;
    }
    return nil;
}

+ (void)deleteImageContent:(JARichImageModel *)imgContent {
    NSString *imgPath = [NSString ja_getUploadImageFilePath:imgContent.localImageName];
    if (imgPath) {
        // 删除单张图片
        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
    }
}

// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content {
    return [self computeHeightInTextVIewWithContent:content minHeight:0];
}

// 计算TextView中的内容的高度
+ (float)computeHeightInTextVIewWithContent:(id)content minHeight:(float)minHeight {
    UITextView* textView = nil;
    if ([content isKindOfClass:[NSString class]]) {
        textView = [self computeTextView];
        textView.text = (NSString*)content;
    } else if ([content isKindOfClass:[NSAttributedString class]]) {
        textView = [self computeTextView];
        textView.attributedText = (NSAttributedString*)content;
    }
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    textView.text = nil;
    textView.attributedText = nil;
    
    return MAX(size.height, minHeight);
}

+ (JARichTextView *)computeTextView {
    static JARichTextView* _textView;
    if (!_textView) {
        _textView = [[JARichTextView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40)];
        _textView.font = JA_REGULAR_FONT(16);
        _textView.textColor = HEX_COLOR(JA_BlackTitle);
        _textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _textView.scrollEnabled = NO;
    }
    return _textView;
}


// 只验证文字不为空
+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents {
    return [self validataContentNotEmptyWithRichContents:richContents isIgnoreImage:YES];
}

+ (BOOL)validataContentNotEmptyWithRichContents:(NSArray*)richContents isIgnoreImage:(BOOL)isIgnoreImage {
    NSInteger textCount = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[JARichImageModel class]]) {
            if (isIgnoreImage) {
                continue;
            }
            return YES;
        } else if ([content isKindOfClass:[JARichTextModel class]]) {
            JARichTextModel* textContent = (JARichTextModel*)content;
            textCount += [textContent.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
            if (textCount > 0) {
                return YES;
            }
        }
    }
    return NO;
}

// 获取已写字数
+ (NSInteger)getTextCount:(NSArray*)richContents {
    NSInteger textCount = 0;
    for (int i = 0; i< richContents.count; i++) {
        NSObject* content = richContents[i];
        if ([content isKindOfClass:[JARichTextModel class]]) {
            JARichTextModel* textContent = (JARichTextModel*)content;
            textCount += [textContent.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
        }
    }
    return textCount;
}

@end
