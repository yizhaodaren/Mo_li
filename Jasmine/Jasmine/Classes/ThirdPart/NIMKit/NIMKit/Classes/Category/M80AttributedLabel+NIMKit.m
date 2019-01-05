//
//  M80AttributedLabel+NIMKit
//  NIM
//
//  Created by chris.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "M80AttributedLabel+NIMKit.h"
#import "NIMInputEmoticonParser.h"
#import "NIMInputEmoticonManager.h"
#import "UIImage+NIMKit.h"

@implementation M80AttributedLabel (NIMKit)
- (void)nim_setText:(NSString *)text
{
    [self setText:@""];
    NSArray *tokens = [[NIMInputEmoticonParser currentParser] tokens:text];
    for (NIMInputTextToken *token in tokens)
    {
        if (token.type == NIMInputTokenTypeEmoticon)
        {
            NIMInputEmoticon *emoticon = [[NIMInputEmoticonManager sharedManager] emoticonByTag:token.text];
            UIImage *image = [UIImage nim_emoticonInKit:emoticon.filename];
            if (image)
            {
                [self appendImage:image
                          maxSize:CGSizeMake(18, 18)];
            }
        }
        else
        {
            NSString *text = token.text;
            [self appendText:text];
        }
    }
}

- (void)nim_appendAttributedText:(NSAttributedString *)text
{
    
    [self setText:@""];
    [self setAttributedText:nil];
    [self appendAttributedText:text];
//    NSArray *tokens = [[NIMInputEmoticonParser currentParser] tokens:text];
//    for (NIMInputTextToken *token in tokens)
//    {
//        if (token.type == NIMInputTokenTypeEmoticon)
//        {
//            NIMInputEmoticon *emoticon = [[NIMInputEmoticonManager sharedManager] emoticonByTag:token.text];
//            UIImage *image = [UIImage nim_emoticonInKit:emoticon.filename];
//            if (image)
//            {
//                [self appendImage:image
//                          maxSize:CGSizeMake(18, 18)];
//            }
//        }
//        else
//        {
//            NSAttributedString *text = [self attributedString:token.text];
//            [self appendAttributedText:text];
//        }
//    }
}

@end
