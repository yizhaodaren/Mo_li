//
//  JARichTextModel.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTextModel.h"

@implementation JARichTextModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textContentHeight = 40;
        _textContent = @"";
        self.richContentType = JARichContentTypeText;
    }
    return self;
}

- (void)setTextContent:(NSString *)textContent {
    if ([textContent isEqualToString:@"\n"]) {
        _textContent = @"";
    } else {
        _textContent = textContent;
    }
}

- (id)copyWithZone:(NSZone *)zone{
    JARichTextModel * model = [[JARichTextModel allocWithZone:zone] init];
    model.textContentHeight = self.textContentHeight;
    model.textContent = [self.textContent copy];
    model.isEditing = self.isEditing;
    model.selectedRange = self.selectedRange;
    model.shouldUpdateSelectedRange = self.shouldUpdateSelectedRange;
    return model;
}

@end
