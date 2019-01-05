//
//  JAPhotoModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAPhotoModel : NSObject
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, assign) BOOL isShow;

+ (instancetype)photoModel:(NSString *)url select:(BOOL)selected show:(BOOL)show ID:(NSString *)ID;
@end
