//
//  JARichTitleModel.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTitleModel.h"

@implementation JARichTitleModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TextHeight + separatorHeight
        _titleContentHeight = 44;
        _textContent = @"";
        self.richContentType = JARichContentTypeTitle;
    }
    return self;
}

- (CGFloat)cellHeight {
    return _titleContentHeight;
}

@end
