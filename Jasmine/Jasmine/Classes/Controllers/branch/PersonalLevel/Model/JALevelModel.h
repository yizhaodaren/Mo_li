//
//  JALevelModel.h
//  Jasmine
//
//  Created by xujin on 13/10/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JALevelModel : JABaseModel

@property (nonatomic, copy) NSString *gradeContent;
@property (nonatomic, copy) NSString *gradeImage;
@property (nonatomic, assign) NSInteger gradeNum;
@property (nonatomic, copy) NSString *gradeStatus;
@property (nonatomic, copy) NSString *gradeTitle;
@property (nonatomic, copy) NSString *rightsNum;
@property (nonatomic, copy) NSString *rightsType;

@end
