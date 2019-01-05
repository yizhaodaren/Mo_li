//
//  JALabelSelectModel.h
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JANetBaseModel.h"

@interface JALabelSelectModel : JANetBaseModel

@property (nonatomic, strong) NSString *labelId;  // 标签id
@property (nonatomic, strong) NSString *labelName;  // 标签名称
@property (nonatomic, strong) NSString *labelThumb;  // 标签图⽚片

@property (nonatomic, assign) BOOL isSelected;  // 是否选中

@end
