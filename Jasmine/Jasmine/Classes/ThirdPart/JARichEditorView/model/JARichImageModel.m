
//
//  JARichImageModel.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichImageModel.h"

@implementation JARichImageModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.richContentType = JARichContentTypeImage;
        self.imageSize = CGSizeMake(100, 100);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    JARichImageModel * model = [[JARichImageModel allocWithZone:zone] init];
    model.image = [self.image copy];
    model.localImageName = [self.localImageName copy];
    model.remoteImageUrlString = [self.remoteImageUrlString copy];
    model.imageContentHeight = self.imageContentHeight;
    model.imageSize = self.imageSize;
    model.imageSendByte = self.imageSendByte;
    return model;
}


@end
