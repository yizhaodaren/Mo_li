//
//  NTESMoliTextAttachment.m
//  Jasmine
//
//  Created by xujin on 17/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NTESMoliTextAttachment.h"
#import "NTESSessionMoliTextContentView.h"
#import "M80AttributedLabel+NIMKit.h"
#import "NTESSessionUtil.h"

@implementation NTESMoliTextAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dict = @{CMType : @(CustomMessageTypeMoliText),
                           CMData : @{CMValue:self.text}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *content = @"";
    if (data) {
        content = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
    }
    return content;
}

- (NSString *)cellContent:(NIMMessage *)message
{
    return @"NTESSessionMoliTextContentView";
}
- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width
{
    NIMKitBubbleConfig *config = [[NIMKitUIConfig sharedConfig] bubbleConfig:message];
//    self.label.font = config.contentTextFont;
//    
    NSString *text = nil;
    NIMCustomObject *customObject = (NIMCustomObject*)message.messageObject;
    id attachment = customObject.attachment;
    if ([attachment isKindOfClass:[NTESMoliTextAttachment class]]) {
        text = ((NTESMoliTextAttachment *)attachment).text;
    }
//    [self.label nim_setText:text];
    
//    NSArray *arr = message.remoteExt[@"connect"];
//    if (arr.count) {
//        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
//        NSRange rangAll = NSMakeRange(0, text.length);
//        //        [attr addAttribute:NSFontAttributeName value:config.contentTextFont range:rangAll];
//        //        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x454c57) range:rangAll];
//        [attr m80_setFont:config.contentTextFont range:rangAll];
//        [attr m80_setTextColor:HEX_COLOR(0x454c57) range:rangAll];
//
//        for (NSInteger i = 0; i < arr.count; i++) {
//            NSDictionary *dic = arr[i];
//            NSString *string = dic[@"content"];
//            // 设置富文本
//            NSRange rang = [text rangeOfString:string];
//            //            [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
//            [attr m80_setTextColor:HEX_COLOR(JA_Green) range:rang];
//        }
//        [self.label nim_appendAttributedText:attr];
//    }else{
//        self.label.font = config.contentTextFont;
//        self.label.textColor = HEX_COLOR(0x454c57);
//        [self.label nim_setText:text];
//    }
    
    [NTESSessionUtil customText:text textFont:config.contentTextFont message:message label:self.label];

    CGFloat msgBubbleMaxWidth    = (width - 130);
    CGFloat bubbleLeftToContent  = 14;
    CGFloat contentRightToBubble = 14;
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - bubbleLeftToContent);
    
    return [self.label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
}

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    NIMKitBubbleConfig *config = [[NIMKitUIConfig sharedConfig] bubbleConfig:message];
    return config.contentInset;
}
#pragma mark - Private
- (M80AttributedLabel *)label
{
    if (_label) {
        return _label;
    }
    _label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    _label.backgroundColor = [UIColor clearColor];
    //    _label.font = [UIFont systemFontOfSize:NIMKit_Message_Font_Size];
    return _label;
}

@end
