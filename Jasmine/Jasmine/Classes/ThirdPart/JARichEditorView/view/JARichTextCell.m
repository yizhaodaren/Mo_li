//
//  JARichTextCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTextCell.h"
#import "JARichTextModel.h"
#import "JADataHelper.h"

static const NSInteger maxTextLength = 2000;

@interface JARichTextCell ()<UITextViewDelegate, JARichTextViewDelegate>

@property (nonatomic, strong) JARichTextView *textView;
@property (nonatomic, strong) JARichTextModel* textModel;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSRange frontSelectRange;

@end

@implementation JARichTextCell

- (void)dealloc {
    _textView.delegate = nil;
    _textView.ja_delegate = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [JARichTextView new];
//        _textView.backgroundColor = [UIColor redColor];
        _textView.font = JA_REGULAR_FONT(16);
        _textView.textColor = HEX_COLOR(JA_BlackTitle);
        _textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _textView.scrollEnabled = NO;
        _textView.maxInputs = maxTextLength;
        _textView.placeHolder = @"请输入内容";
        _textView.placeHolderColor = HEX_COLOR(JA_BlackSubSubTitle);
        _textView.showPlaceHolder = YES;
        _textView.delegate = self;
        _textView.ja_delegate = self;
        [self.contentView addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
        }];
    }
    return self;
}

- (void)updateWithData:(JARichTextModel *)data {
    _textModel = data;
    // 重新设置TextView的约束
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(_textModel.textContentHeight));
    }];
    // Content
    _textView.text = _textModel.textContent;
    
    // Placeholder
    [self handlePlaceholder];
}

- (void)ja_beginEditing {
    [self.textView becomeFirstResponder];
#warning TODO:是否合理
    self.textView.text = self.textModel.textContent;
    if (YES) {
        // 手动调用回调方法修改
        [self textViewDidChange:_textView];
    }
    // Placeholder
    [self handlePlaceholder];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(ja_updateActiveIndexPath:)]) {
        [self.delegate ja_updateActiveIndexPath:[self curIndexPath]];
    }
}

- (NSArray<NSString*>*)splitedTextArrWithPreFlag:(BOOL*)isPre postFlag:(BOOL*)isPost {
    NSMutableArray* splitedTextArr = [NSMutableArray new];
    
    NSRange selRange = _textView.selectedRange;
    
    // 设置标记值
    if (isPre) {
        if (selRange.location == 0) {
            *isPre = YES;
        } else {
            *isPre = NO;
        }
    }
    
    if (isPost) {
        if (selRange.location+selRange.length == _textView.text.length) {
            *isPost = YES;
        } else {
            *isPost = NO;
        }
    }
    
    // 0 - selectRange.location
    if (selRange.location > 0) {
        [splitedTextArr addObject:[_textView.text substringToIndex:selRange.location]];
    }
    
    // selectRange.location+selectRange.length - end
    if (selRange.location+selRange.length < _textView.text.length) {
        [splitedTextArr addObject:[_textView.text substringWithRange:NSMakeRange(selRange.location+selRange.length, _textView.text.length - (selRange.location+selRange.length))]];
    }
    
    return splitedTextArr;
}

#pragma mark - private
- (void)scrollToCursorForTextView:(UITextView*)textView {
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.containerTableView convertRect:cursorRect fromView:textView];
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.containerTableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible:(CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.containerTableView.contentOffset;
    visibleRect.origin.y += self.containerTableView.contentInset.top;
    visibleRect.size = self.containerTableView.bounds.size;
    visibleRect.size.height -= self.containerTableView.contentInset.top + self.containerTableView.contentInset.bottom;
    return CGRectContainsRect(visibleRect, rect);
}

- (void)handlePlaceholder {
    if ([self.delegate respondsToSelector:@selector(ja_shouldCellShowPlaceholder)]) {
        BOOL showPlaceholder = [self.delegate ja_shouldCellShowPlaceholder];
        self.textView.showPlaceHolder = showPlaceholder;
    } else {
        self.textView.showPlaceHolder = NO;
    }
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    BOOL isNeedHandle = NO;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            isNeedHandle = YES;
        }else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
    } else {
        isNeedHandle = YES;
    }
    if (!isNeedHandle) {
        // 不需要处理直接返回
        return;
    }
    
    if (_textModel.shouldUpdateSelectedRange) {
        // 光标位置特殊处理
        _textModel.shouldUpdateSelectedRange = NO;
    } else {
        _textModel.selectedRange = textView.selectedRange;
    }
    
    // 处理#话题#和@人
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:textView.text];
    [placeholder addAttribute:NSFontAttributeName
                        value:JA_REGULAR_FONT(16)
                        range:NSMakeRange(0, textView.text.length)];
    NSArray *hashtags = [JADataHelper getRangesForHashtags:textView.text];
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in hashtags)
    {
        NSRange matchRange = [match range];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:HEX_COLOR(0x54C7FC)
                            range:matchRange];
        [placeholder addAttribute:NSFontAttributeName
                            value:JA_REGULAR_FONT(16)
                            range:matchRange];
    }
    NSArray *userHandles = [JADataHelper getRangesForUserHandles:textView.text];
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in userHandles)
    {
        NSRange matchRange = [match range];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:HEX_COLOR(0x54C7FC)
                            range:matchRange];
        [placeholder addAttribute:NSFontAttributeName
                            value:JA_REGULAR_FONT(16)
                            range:matchRange];
    }
    textView.attributedText = placeholder;
    textView.selectedRange = _textModel.selectedRange;
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    // 更新模型数据
    _textModel.textContentHeight = size.height;
    _textModel.textContent = textView.text;
   

    _textModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(_textModel.textContentHeight));
        }];
        [tableView endUpdates];
        
        // 移动光标 https://stackoverflow.com/questions/18368567/uitableviewcell-with-uitextview-height-in-ios-7
        [self scrollToCursorForTextView:textView];
    }
    
    if (textView.text.length <= 0) {
        // Placeholder
        [self handlePlaceholder];
    }
    
    if (textView.text.length == 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JARichTextCell_editText_5" object:nil];
    }else if (textView.text.length < 5){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JARichTextCell_editText_no5" object:nil];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(ja_shouldHiddenActionButtons:)]) {
        [self.delegate ja_shouldHiddenActionButtons:NO];
    }
    self.isEditing = YES;
    if ([self.delegate respondsToSelector:@selector(ja_updateActiveIndexPath:)]) {
        [self.delegate ja_updateActiveIndexPath:[self curIndexPath]];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.isEditing = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 弹出话题页面
    if ([text isEqualToString:@"#"]) {
        if ([self.delegate respondsToSelector:@selector(ja_pushSearchTopicVC)]) {
            [self.delegate ja_pushSearchTopicVC];
        }
    }
    // 弹出@人页面
    if ([text isEqualToString:@"@"]) {
        // ?????
//        if (range.length > 0) {
//            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
//            [textView.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
//        }
        if ([self.delegate respondsToSelector:@selector(ja_pushAtPersonVC)]) {
            [self.delegate ja_pushAtPersonVC];
        }
    }
    // 如果删除的是“\b”
    NSString *subString = [textView.text substringWithRange:range];
    if ([subString isEqualToString:@"\b"]) {
        NSRange headRange = [[textView.text substringToIndex:range.location] rangeOfString:@"@" options:NSBackwardsSearch];
        if (headRange.location != NSNotFound) {
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(headRange.location, range.location-headRange.location+1) withString:@""];
            textView.selectedRange = NSMakeRange(headRange.location, textView.selectedRange.length);
            // 需要更新model和cell
            [self textViewDidChange:_textView];
            return NO;
        }
    }
//    // 不允许输入换行
//    if ([text isEqualToString:@"\n"]) {
//        return NO;
//    }
    // 处理删除，防止输入的字数为最大值的时候删除无效
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if (NO == self.isEditing) {
        // 隐藏键盘,TextView会自动填充选中的联想词，这个地方返回NO做特殊处理，
        // 不让TextView自动填充选中的联想词
        self.isEditing = YES;
        return NO;
    }
    // 中间位置不能插入更多导致超过最大值
    // 结尾位置支持插入更多   && range.location < textView.text.length
    if (textView.text.length + text.length > maxTextLength) {
        return NO;
    }
    return YES;
}

// @ 禁止选中部分内容进行复制
- (void)textViewDidChangeSelection:(UITextView *)textView {
    {
        if (textView.selectedRange.length > 0) {  // 两个光标
            if (self.frontSelectRange.location != textView.selectedRange.location) {  // 移动第一个光标
                
                NSArray *userHandles = [JADataHelper getRangesForUserHandles:textView.text];
                for (NSTextCheckingResult *match in userHandles)
                {
                    NSRange matchRange = [match range];
                    if (textView.selectedRange.location > matchRange.location && textView.selectedRange.location < matchRange.location+matchRange.length) {
                        textView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, self.frontSelectRange.location + self.frontSelectRange.length);
                        break;
                    }
                }
                self.frontSelectRange = textView.selectedRange;
            }else{  // 移动第二个光标
                
                NSArray *userHandles = [JADataHelper getRangesForUserHandles:textView.text];
                for (NSTextCheckingResult *match in userHandles)
                {
                    NSRange matchRange = [match range];
                    if (textView.selectedRange.location + textView.selectedRange.length > matchRange.location && textView.selectedRange.location + textView.selectedRange.length < matchRange.location+matchRange.length) {
                        textView.selectedRange = NSMakeRange(textView.selectedRange.location, matchRange.location+matchRange.length);
                        break;
                    }
                }
                self.frontSelectRange = textView.selectedRange;
            }
        }else{   // 一个光标
            
            NSArray *userHandles = [JADataHelper getRangesForUserHandles:textView.text];
            for (NSTextCheckingResult *match in userHandles)
            {
                NSRange matchRange = [match range];
                if (textView.selectedRange.location > matchRange.location && textView.selectedRange.location < matchRange.location+matchRange.length) {
                    textView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, textView.selectedRange.length);
                    break;
                }
            }
        }
    }
}

#pragma mark - JARichTextViewDelegate
- (void)ja_textViewDeleteBackward:(JARichTextView *)textView {
    // 处理的删除
    NSRange selRange = self.textView.selectedRange;
    if (selRange.location == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(ja_preDeleteItemAtIndexPath:)]) {
                [self.delegate ja_preDeleteItemAtIndexPath:[self curIndexPath]];
            }
        });
    }
}

@end
