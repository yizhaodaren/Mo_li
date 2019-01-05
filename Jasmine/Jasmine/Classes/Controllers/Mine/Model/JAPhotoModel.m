//
//  JAPhotoModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPhotoModel.h"

@implementation JAPhotoModel
+ (instancetype)photoModel:(NSString *)url select:(BOOL)selected show:(BOOL)show ID:(NSString *)ID
{
    JAPhotoModel *model = [[JAPhotoModel alloc] init];
    model.imageUrl = url;
    model.isClick = selected;
    model.isShow = show;
    model.ID = ID;
    
    return model;
}
@end
