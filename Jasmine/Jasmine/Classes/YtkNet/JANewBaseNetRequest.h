//
//  JANewBaseNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "YTKRequest.h"
#import "JANetBaseModel.h"

@interface JANewBaseNetRequest : YTKRequest
@property (nonatomic, assign) Class modelClass;
@property (nonatomic, assign) BOOL isToast;
@end
