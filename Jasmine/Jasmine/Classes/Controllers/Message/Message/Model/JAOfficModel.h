//
//  JAOfficModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAOfficModel : NSObject
/*** 图片/文字***/
@property (nonatomic, strong) NSString *time;
/** 图像*/
@property (nonatomic ,copy) NSString *image;
/** 标题*/
@property (nonatomic ,copy) NSString *title;
/** 内容(正文)*/
@property (nonatomic ,copy) NSString *content;
/** url*/
@property (nonatomic ,copy) NSString *url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *typeId;
@property (nonatomic, strong) NSString *openType;

// id
@property (nonatomic, strong) NSString *officId;

/*** frame数据 ****/
@property (nonatomic, assign) CGRect timeFrame;

@property (nonatomic, assign) CGRect moliJunFrame;   // 茉莉君头像

@property (nonatomic, assign) CGRect backFrame;
/** 图像的frame*/
@property (nonatomic ,assign)CGRect imageFrame;
/** 标题的frame*/
@property (nonatomic ,assign)CGRect titleFrame;
/** 正文的frame*/
@property (nonatomic ,assign)CGRect contentFrame;
/** url的frame*/
@property (nonatomic ,assign)CGRect urlFrame;
@property (nonatomic ,assign)CGRect urlLineFrame;
@property (nonatomic ,assign)CGRect urlButtonFrame;
@property (nonatomic ,assign)CGRect urlArrowFrame;

@property (nonatomic ,assign)CGFloat cellHeight;
@end
