//
//  JARichTitleModel.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseRichContentModel.h"

@interface JARichTitleModel : JABaseRichContentModel

@property (nonatomic, assign) CGFloat titleContentHeight;
@property (nonatomic, copy) NSString* textContent;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end
