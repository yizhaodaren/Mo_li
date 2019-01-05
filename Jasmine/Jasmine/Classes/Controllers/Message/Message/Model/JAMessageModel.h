//
//  JAMessageModel.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAMessageData.h"

@interface JAMessageModel : NSObject

@property (nonatomic, assign) NSUInteger dataCount;

- (void)getMessage:(void(^)(void))success failure:(void(^)(void))error;

- (JAMessageData *)dataAtIndex:(NSInteger)index;

@end
