//
//  JARichTitleCell.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseRichContentCell.h"

@interface JARichTitleCell : JABaseRichContentCell

@property (nonatomic, weak) id<JARichContentEditDelegate> delegate;

- (void)ja_beginEditing;

@end
