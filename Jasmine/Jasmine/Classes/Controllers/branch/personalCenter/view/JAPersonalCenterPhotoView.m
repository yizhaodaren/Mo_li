//
//  JAPersonPhotoView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalCenterPhotoView.h"
#import "JAPhotoModel.h"
#import "KNPhotoBrower.h"
#import "JFImagePickerController.h"
#import "JAUserApiRequest.h"
#import "JAVoicePersonApi.h"

#define kScale [self getScale]
@interface JAPersonalCenterPhotoView ()<KNPhotoBrowerDelegate>
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIScrollView *photoScrollview;
@property (nonatomic, weak) UILabel *noneLabel;
@property (nonatomic, weak) UIButton *addButton; // 加号

@property (nonatomic, strong) NSMutableArray *userIconArray; // 需要展示的数据
@property (nonatomic, strong) NSMutableArray *deleteImageArray;// 需要删除的数据

/// 判断是否调用 更新相册
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSMutableArray *imgArray; // 选择的图片数组
@property (nonatomic, strong) NSString *imageAllUrl; // 拼接的相片URL

// 原来的用户相册的url
@property (nonatomic, strong) NSString *originalImageUrl;
@property (nonatomic, strong) NSString *image_id;

@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, weak) UIView *lineView1;
@property (nonatomic, weak) UIView *lineView2;

@property (nonatomic, assign) NSInteger deleteImageIndex;
@end
@implementation JAPersonalCenterPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPhotoView];
        _userIconArray = [NSMutableArray array];
        _deleteImageArray = [NSMutableArray array];
        _imgArray = [NSMutableArray array];
    }
    return self;
}

- (void)setupPhotoView
{
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    _lineView2 = lineView2;
    lineView2.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView2];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"我的照片";
    nameLabel.textColor = HEX_COLOR(0x9b9b9b);
    nameLabel.font = JA_MEDIUM_FONT(14);
    [self addSubview:nameLabel];
    
    UILabel *noneLabel = [[UILabel alloc] init];
    _noneLabel = noneLabel;
    noneLabel.text = @"你还没有上传照片";
    noneLabel.textColor = HEX_COLOR(0xC6C6CE);
    noneLabel.font = JA_REGULAR_FONT(14);
    [noneLabel sizeToFit];
    [self addSubview:noneLabel];
    
    UIScrollView *photoScrollview = [[UIScrollView alloc] init];
    _photoScrollview = photoScrollview;
    photoScrollview.showsVerticalScrollIndicator = NO;
    photoScrollview.showsHorizontalScrollIndicator = NO;
    //    photoScrollview.backgroundColor = [UIColor redColor];
    photoScrollview.backgroundColor = [UIColor clearColor];
    [self addSubview:photoScrollview];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton = addButton;
    addButton.hidden = YES;
    addButton.layer.cornerRadius = 4;
    addButton.clipsToBounds = YES;
    addButton.backgroundColor = HEX_COLOR(0xffffff);
    [addButton setImage:[UIImage imageNamed:@"person_+"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(upLoadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoScrollview addSubview:addButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.x = 14;
    self.nameLabel.y = 15 * kScale;
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 20;
    
    self.photoScrollview.x = self.nameLabel.x;
    self.photoScrollview.y = self.nameLabel.bottom + 10 * kScale;
    self.photoScrollview.width = JA_SCREEN_WIDTH - self.nameLabel.x;
    self.photoScrollview.height = 88 * kScale;
    
    [self.noneLabel sizeToFit];
    self.noneLabel.center = CGPointMake(self.width * 0.5, self.photoScrollview.height * 0.5 + self.photoScrollview.y);
    
    //    self.addButton.x = 14;
    //    self.addButton.y = self.nameLabel.bottom + 10;
    self.addButton.width = 88 * kScale;
    self.addButton.height = 88 * kScale;
    
    self.lineView1.width = JA_SCREEN_WIDTH;
    self.lineView1.height = 1;
    
    self.lineView2.width = JA_SCREEN_WIDTH;
    self.lineView2.height = 1;
    self.lineView2.y = self.height - 1;
}


- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        self.addButton.hidden = NO;
    }else{
        self.addButton.hidden = YES;
    }
}


// 展示用户相册
- (void)setPhotoArray:(NSArray *)photoArray
{
    _photoArray = photoArray;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self showUserPhoto:photoArray];
}
- (void)showUserPhoto:(NSArray *)imageArray
{
    [self.userIconArray removeAllObjects];
    for (UIButton *btn in self.photoScrollview.subviews) {
        if (btn != self.addButton) {
            [btn removeFromSuperview];
        }
    }
    
    
    NSArray *arr = imageArray;
    
    if (!arr.count) {
        return;
    }
    self.needUpdate = YES;
    NSDictionary *dic = arr.firstObject;
    NSString *imageStr = dic[@"image"];
    
    self.originalImageUrl = imageStr;
    self.image_id = dic[@"id"];
    
    if (![imageStr isEqualToString:@""] && imageStr.length) {   // 用户有相册
        
        // 有相册的时候
        self.photoScrollview.backgroundColor = HEX_COLOR(0xF9F9F9);
        
        NSArray *arr = [imageStr componentsSeparatedByString:@"#"];
        
        NSInteger count = arr.count;
        CGFloat w = self.photoScrollview.height;
        
        BOOL isMe = [self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        
        if (count < 9) {
            
            self.addButton.hidden = isMe ? NO : YES;
            self.photoScrollview.contentSize = isMe ? CGSizeMake(w * (count + 1) + 5 * count, 0) : CGSizeMake(w * (count) + 5 * (count - 1), 0);
        }else{
            self.addButton.hidden = YES;
            self.photoScrollview.contentSize = CGSizeMake(w * (count) + 5 * (count - 1), 0);
        }
        
        for (NSInteger i = 0; i < count; i++) {
            
            NSString *url = arr[i];
            
            
            JAPhotoModel *model = [JAPhotoModel photoModel:url select:NO show:NO ID:dic[@"id"]];
            
            [self.userIconArray addObject:model];
            
            // 创建图片
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.userInteractionEnabled = YES;
            imageView.contentMode =  UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.width = self.photoScrollview.height;
            imageView.height = self.photoScrollview.height;
            imageView.x = i * (imageView.width + 5);
            imageView.y = 0;
            imageView.layer.borderColor = HEX_COLOR(0xeeeeee).CGColor;
            imageView.layer.borderWidth = 1;
            [imageView ja_setImageWithURLStr:url];
            [self.photoScrollview addSubview:imageView];
            imageView.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSignPhoto:)];
            [imageView addGestureRecognizer:tap];
            
        }
        
        self.addButton.x = (self.photoScrollview.height + 5) * count;
        
    }else{  // 用户没有相册
        self.addButton.x = 0;
        // 没有相册的时候 改为透明 - 显示下面的没有相册
        self.photoScrollview.backgroundColor = [UIColor clearColor];
    }
}

// 上传 - 删除图片
- (void)showPhoto:(NSString *)userId
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = userId;
    
    [[JAVoicePersonApi shareInstance] voice_personalPhotoWithParas:dic success:^(NSDictionary *result) {
        
        [self showUserPhoto:result[@"arraylist"]];
        
    } failure:^(NSError *error) {
        
    }];
 
}

// 点击单个图片
- (void)clickSignPhoto:(UITapGestureRecognizer *)tap
{
    UIImageView *imageV = (UIImageView *)tap.view;
    NSMutableArray *arrM = [NSMutableArray array];
    // 查看大图
    for (NSInteger i = 0; i < self.userIconArray.count; i++) {
        KNPhotoItems *items = [[KNPhotoItems alloc] init];
        JAPhotoModel *model = self.userIconArray[i];
        items.url = model.imageUrl;
        [arrM addObject:items];
    }
    
    KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
    if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        
        photoBrower.actionSheetArr =  [@[@"删除"] copy];
    }else{

        if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
            photoBrower.actionSheetArr =  [@[@"删除",@"保存"] copy];
        }else{
            photoBrower.actionSheetArr =  [@[@"保存"] copy];
        }
        
    }
    [photoBrower setIsNeedRightTopBtn:YES];
    [photoBrower setIsNeedPictureLongPress:YES];
    photoBrower.itemsArr = [arrM copy];
    photoBrower.currentIndex = imageV.tag;
    [photoBrower present];
    
    [photoBrower setDelegate:self];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"照片详情";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)setSex:(NSString *)sex
{
    _sex = sex;
    
    [self getName:self.userId sex:sex];
}

- (void)getName:(NSString *)userId sex:(NSString *)sex
{
    if ([userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {   // 是自己
        
        self.nameLabel.text = @"我的照片";
        self.noneLabel.text = @"你还没有上传照片";
        self.noneLabel.hidden = YES;
    }else{   // 不是自己
        self.noneLabel.hidden = NO;
        if ([sex integerValue] == 1) {   // 男
            
            self.nameLabel.text = @"他的照片";
            self.noneLabel.text = @"他还没有上传照片";
        }else{   // 女
            self.nameLabel.text = @"她的照片";
            self.noneLabel.text = @"她还没有上传照片";
        }
    }
}

- (CGFloat)getScale
{
    
    return 1;
//    if ([UIScreen mainScreen].bounds.size.width == 375) {
//        
//        return 1;
//    }else if ([UIScreen mainScreen].bounds.size.width == 414){
//        return 414/375.0;
//    }else{
//        return 320 / 375.0;
//    }
}

#pragma mark - KNPhotoBrowerDelegate
#pragma mark - 删除用户相册
- (void)photoBrowerRightOperationDeleteImageSuccessWithAbsoluteIndex:(NSInteger)index
{
    [self deletePhoto:index];
}

// 删除图片
- (void)deletePhoto:(NSInteger)index
{
    //    // 删除图片
    JAPhotoModel *model = self.userIconArray[index];
    [self.deleteImageArray addObject:model];
    
    NSString *imageID = model.ID;
    // 删除模型
    [self.userIconArray removeObjectsInArray:self.deleteImageArray];
    
    // 拼接图片字符串
    NSString *imageStr = @"";
    
    for (NSInteger i = 0; i < self.userIconArray.count; i++) {
        
        JAPhotoModel *model = self.userIconArray[i];
        if (i == 0) {
            imageStr = model.imageUrl;
        }else{
            imageStr = [NSString stringWithFormat:@"%@#%@",imageStr,model.imageUrl];
        }
        
    }
    
    
    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER && ![self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"managerUserId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"userId"] = self.userId;
        dic[@"image"] = imageStr;
        
        [[JAVoicePersonApi shareInstance] voice_adminUpdatePhotoWithParas:dic success:^(NSDictionary *result) {
            [self showPhoto:self.userId];
            [self.deleteImageArray removeAllObjects];
        } failure:^(NSError *error) {
            [self.deleteImageArray removeAllObjects];
        }];
        
    }else{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = imageID;
        dic[@"userId"] = self.userId;
        dic[@"image"] = imageStr;
        
        [[JAVoicePersonApi shareInstance] voice_personalUpdatePhotoWithParas:dic success:^(NSDictionary *result) {
            
            [self showPhoto:self.userId];
            [self.deleteImageArray removeAllObjects];
            
        } failure:^(NSError *error) {
            
            [self.deleteImageArray removeAllObjects];
            
        }];
    }
    
}

// 上传图片
- (void)upLoadPhoto:(UIButton *)btn
{
    MMDrawerController *tab = [AppDelegateModel rootviewController];
    // 上传照片
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:tab];
    picker.maxCount = 9 - self.userIconArray.count;
    picker.pickerDelegate = self;
    [tab presentViewController:picker animated:YES completion:nil];
}


#pragma mark - 调起相册
#pragma mark - JFImagePicker Delegate -
- (void)imagePickerDidFinished:(JFImagePickerController *)picker
{
    [self loadAssets:picker.assets];
    
    // cancel picker
    [self imagePickerDidCancel:picker];
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [JFImagePickerController clear];
}
- (void)imagePickerDidTakePhotoFinished:(JFImagePickerController *)picker image:(UIImage *)image
{
    
    [self.imgArray addObject:image];
//    [self upLoadImage:self.imgArray];
    // 上传图片到阿里云服务器
    [[JAUserApiRequest shareInstance] ali_upLoadUserIcon:self.imgArray isAsync:YES complete:^(NSArray<NSString *> *names, BOOL state) {
        
        // 上传服务器
        NSLog(@"%@",names);
        [self aliyun_updataImageFinish:names];
    }];
    [self imagePickerDidCancel:picker];
    
}

- (void)loadAssets:(NSArray *)assets
{
    if (assets.count <= 0) {
        return;
    }
    [self getAllImageWith:assets finish:^(NSArray *imageArr) {
        [MBProgressHUD showMessage:nil];
        // 上传图片
//        [self upLoadImage:imageArr];
        [[JAUserApiRequest shareInstance] ali_upLoadUserIcon:imageArr isAsync:YES complete:^(NSArray<NSString *> *names, BOOL state) {
           
            // 上传服务器
            NSLog(@"%@",names);
            [self aliyun_updataImageFinish:names];
        }];
        
    }];
}

// 1 获取所有的图片
- (void)getAllImageWith:(NSArray *)assets finish:(void(^)(NSArray *imageArr))finished
{
    dispatch_group_t group = dispatch_group_create();
    @WeakObj(self)
    for (ALAsset *asset in assets)
    {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [[JFImageManager sharedManager] imageWithAsset:asset resultHandler:^(CGImageRef imageRef, BOOL longImage) {
                
                @StrongObj(self)
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                [self.imgArray addObject:image];
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        finished(self.imgArray);
    });
}

// 上传图片到阿里云服务器
- (void)aliyun_updataImageFinish:(NSArray *)images
{
    self.imageAllUrl = [images componentsJoinedByString:@"#"];
    // 拼接起来
    [self.imgArray removeAllObjects];
    // 上传图片完成
    if (self.needUpdate) {
        
        NSString *imageUrl = nil;
        
        if (self.originalImageUrl.length && self.imageAllUrl.length) {
            imageUrl = [NSString stringWithFormat:@"%@#%@",self.originalImageUrl,self.imageAllUrl];
            
        }else if(self.imageAllUrl.length){
            
            imageUrl = self.imageAllUrl;
        }
        
        if (imageUrl.length) {   // 有值的时候才上传
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = self.image_id;
            dic[@"userId"] = self.userId;
            dic[@"image"] = imageUrl;
            
            [[JAVoicePersonApi shareInstance] voice_personalUpdatePhotoWithParas:dic success:^(NSDictionary *result) {
                
                [self showPhoto:self.userId];
                self.imageAllUrl = nil;
                [MBProgressHUD hideHUD];
            } failure:^(NSError *error) {
                
                self.imageAllUrl = nil;
                [self ja_makeToast:@"图片上传失败"];
                [MBProgressHUD hideHUD];

            }];
        }
    }else{
        
        NSLog(@"上传图片完成 - 提交图片URl %@",self.imageAllUrl);
        if (self.imageAllUrl.length) {
            
            NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = uid;
            dic[@"image"] = self.imageAllUrl;
            
            [[JAVoicePersonApi shareInstance] voice_personalUpLoadPhotoWithParas:dic success:^(NSDictionary *result) {
                self.imageAllUrl = nil;
                [MBProgressHUD hideHUD];
                [self showPhoto:self.userId];
            } failure:^(NSError *error) {
                self.imageAllUrl = nil;
                [self ja_makeToast:@"图片上传失败"];
                [MBProgressHUD hideHUD];
            }];
            
        }else{
            [self ja_makeToast:@"图片上传失败"];
            [MBProgressHUD hideHUD];
        }
    }
}

// 2 开始上传图片
//- (void)upLoadImage:(NSArray *)images
//{
//    dispatch_group_t group = dispatch_group_create();
//
//    for (NSInteger i = 0; i < images.count; i++) {
//
//        // 获取图片
//        UIImage *image = images[i];
//
//        // 计算图片尺寸
//        //        CGFloat imageW = JA_SCREEN_WIDTH;
//        //        CGFloat imageH = image.size.height * imageW / image.size.width;
//        //        UIImage *newImage = [UIImage OriginImage:image scaleToSize:CGSizeMake(imageW, imageH)];
//        NSData *resizeData = [NSData reSizeImageData:image maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
//
//        dispatch_group_enter(group);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//            [[JAUserApiRequest shareInstance] upLoadData:resizeData fileType:@"jpg" finish:^(NSDictionary *result) {
//
//                dispatch_group_leave(group);
//
//                NSLog(@"相册上传图片成功 - %@",result);
//                NSString *str = result[@"hashmap"][@"imgurl"];
//
//                if (self.imageAllUrl.length && str.length) {
//
//                    self.imageAllUrl = [NSString stringWithFormat:@"%@#%@",self.imageAllUrl,str];
//                }else if (str.length){
//
//                    self.imageAllUrl = str;
//                }
//
//            }];
//
//        });
//    }
//
//
//
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//
//        [self.imgArray removeAllObjects];
//        // 上传图片完成
//        if (self.needUpdate) {
//
//            NSString *imageUrl = nil;
//
//            if (self.originalImageUrl.length && self.imageAllUrl.length) {
//                imageUrl = [NSString stringWithFormat:@"%@#%@",self.originalImageUrl,self.imageAllUrl];
//
//            }else if(self.imageAllUrl.length){
//
//                imageUrl = self.imageAllUrl;
//            }
//
//            if (imageUrl.length) {   // 有值的时候才上传
//
//                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                dic[@"id"] = self.image_id;
//                dic[@"userId"] = self.userId;
//                dic[@"image"] = imageUrl;
//
//                [[JAVoicePersonApi shareInstance] voice_personalUpdatePhotoWithParas:dic success:^(NSDictionary *result) {
//
//                    [self showPhoto:self.userId];
//                    self.imageAllUrl = nil;
//                    [SVProgressHUD dismiss];
//
//                } failure:^(NSError *error) {
//
//                    self.imageAllUrl = nil;
//                    [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
//                    [SVProgressHUD dismiss];
//
//                }];
//            }
//
//
//        }else{
//
//            NSLog(@"上传图片完成 - 提交图片URl %@",self.imageAllUrl);
//            if (self.imageAllUrl.length) {
//
//                NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                dic[@"userId"] = uid;
//                dic[@"image"] = self.imageAllUrl;
//
//                [[JAVoicePersonApi shareInstance] voice_personalUpLoadPhotoWithParas:dic success:^(NSDictionary *result) {
//                    self.imageAllUrl = nil;
//                    [SVProgressHUD dismiss];
//                    [self showPhoto:self.userId];
//                } failure:^(NSError *error) {
//                    self.imageAllUrl = nil;
//                    [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
//                    [SVProgressHUD dismiss];
//                }];
//
//            }else{
//                [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
//            }
//        }
//
//    });
//}
@end
