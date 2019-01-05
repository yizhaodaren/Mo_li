//
//  JARichTextCell.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseRichContentCell.h"
#import "JARichTextView.h"

@interface JARichTextCell : JABaseRichContentCell

@property (nonatomic, weak) id<JARichContentEditDelegate> delegate;
@property (nonatomic, strong, readonly) JARichTextView *textView;

- (void)ja_beginEditing;

// 是否在文字中间插入图片
- (NSArray<NSString*>*)splitedTextArrWithPreFlag:(BOOL*)isPre postFlag:(BOOL*)isPost;

@end
