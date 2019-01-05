//
//  JABaseRichContentModel.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JARichContentType) {
    JARichContentTypeImage = 1,
    JARichContentTypeText,
    JARichContentTypeTitle
};

@interface JABaseRichContentModel : NSObject

@property (nonatomic, assign) JARichContentType richContentType;

@end
