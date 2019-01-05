//
//  JARichTitleCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTitleCell.h"
#import "JARichTextView.h"
#import "JARichTitleModel.h"

static const NSInteger maxTitleLength = 30;

@interface JARichTitleCell () <UITextViewDelegate>

@property (nonatomic, strong) JARichTextView *textView;
@property (nonatomic, strong) JARichTitleModel* titleModel;
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation JARichTitleCell

- (void)dealloc {
    _textView.delegate = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [JARichTextView new];
        _textView.font = JA_REGULAR_FONT(16);
        _textView.textColor = HEX_COLOR(JA_BlackTitle);
        _textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
        _textView.scrollEnabled = NO;
        _textView.maxInputs = maxTitleLength;
        _textView.placeHolder = @"帖子标题（选填，最多30个字）";
        _textView.placeHolderColor = HEX_COLOR(JA_BlackSubSubTitle);
        _textView.showPlaceHolder = YES;
        _textView.delegate = self;
        [self.contentView addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEX_COLOR(JA_Line);
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(0);
            make.height.offset(1);
        }];
    }
    return self;
}

- (void)updateWithData:(JARichTitleModel *)data {
    _titleModel = data;
    
    // 重新设置TextView的约束
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(_titleModel.titleContentHeight));
    }];
    
    // Content
    self.textView.text = _titleModel.textContent;
}

- (void)ja_beginEditing {
    [self.textView becomeFirstResponder];
    #warning TODO:是否合理
    if (![self.textView.text isEqualToString:_titleModel.textContent]) {
        self.textView.text = _titleModel.textContent;
        
        [self textViewDidChange:self.textView];
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
    [self handleTextViewDidChange];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(ja_shouldHiddenActionButtons:)]) {
        [self.delegate ja_shouldHiddenActionButtons:YES];
    }
    self.isEditing = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.isEditing = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
    if (textView.text.length + text.length > maxTitleLength) {
        return NO;
    }
    return YES;
}

- (void)handleTextViewDidChange {
    CGRect frame = self.textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [self.textView sizeThatFits:constraintSize];
    
    // 更新模型数据
    _titleModel.titleContentHeight = size.height;
    _titleModel.textContent = self.textView.text;
    _titleModel.selectedRange = self.textView.selectedRange;
    _titleModel.isEditing = YES;
    
    if (ABS(_textView.frame.size.height - size.height) > 5) {
        // 重新设置TextView的约束
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(_titleModel.titleContentHeight));
        }];
        
        UITableView* tableView = [self containerTableView];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark - notification
//- (void)textDidChange:(NSNotification*)notification {
//    NSObject* obj = notification.object;
//    if (obj == self.textView) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self handleTextViewDidChange];
//        });
//    }
//}

@end
