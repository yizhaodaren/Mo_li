//
//  JARichImageModel.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseRichContentModel.h"

@interface JARichImageModel : JABaseRichContentModel <NSCopying>

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, copy) NSString* localImageName; //本地保存的名称
@property (nonatomic, copy) NSString* remoteImageUrlString; //上传完成之后的远程路径
@property (nonatomic, assign) CGFloat imageContentHeight; // 用于编辑时，图片高度的展示
@property (nonatomic, assign) CGSize imageSize; // 记录图片真实高度

@property (nonatomic, assign) NSUInteger imageSendByte; //图片已上传文件大小

//// 上传处理
//@property (nonatomic, assign) float uploadProgress;
//@property (nonatomic, assign) BOOL isFailed;
//@property (nonatomic, assign) BOOL isDone;

@end
