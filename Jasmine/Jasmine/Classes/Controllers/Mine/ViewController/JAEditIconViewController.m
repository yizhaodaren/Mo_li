//
//  JAEditIconViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAEditIconViewController.h"
#import "JAUserApiRequest.h"
//#import "JAPersonalApi.h"
#import "XDImageViewController.h"
#import "JAVoicePersonApi.h"
#import <Photos/Photos.h>

@interface JAEditIconViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMaign;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMargin;

@end

@implementation JAEditIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.iconImageView.image = self.image ? self.image : [UIImage imageNamed:@"zhaopian_grzy"];
    
    [self.cameraBtn setTitleColor:HEX_COLOR(0x02bfa6) forState:UIControlStateNormal];
    self.cameraBtn.layer.borderColor = HEX_COLOR(0x02bfa6).CGColor;
    self.cameraBtn.layer.borderWidth = 1;
    self.cameraBtn.clipsToBounds = YES;
    self.cameraBtn.layer.cornerRadius = 5;
    [self.photoBtn setTitleColor:HEX_COLOR(0x02bfa6) forState:UIControlStateNormal];
    self.photoBtn.layer.borderColor = HEX_COLOR(0x02bfa6).CGColor;
    self.photoBtn.layer.borderWidth = 1;
    self.photoBtn.clipsToBounds = YES;
    self.photoBtn.layer.cornerRadius = 5;
    
    [self setCenterTitle:@"编辑头像"];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"circle_back_black"] highlightImage:[UIImage imageNamed:@"circle_back_black"]];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    [self setNavigationBarColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"编辑头像";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (iPhone4) {
        self.leftMaign.constant = 50;
        self.rightMargin.constant = 50;
    }
}


- (IBAction)clickCamera:(UIButton *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
        picker.allowsEditing = YES;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];        
    }
}


- (IBAction)clickPhoto:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        // 用户选择的头像
        __block UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (!image) {
            NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            PHFetchResult*result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
            PHAsset *asset = [result firstObject];
            PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
            phImageRequestOptions.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                image = [UIImage imageWithData:imageData];
            }];
        }
     
        // 头像截取框
        [picker dismissViewControllerAnimated:YES completion:^{
            
            XDImageViewController *vc = [[XDImageViewController alloc] init];
            vc.userImage = image;
            
            __weak typeof(self) wself = self;
            vc.imageBlock = ^(UIImage *newImg){
                
                self.iconImageView.image = newImg;
                // 压缩图片上传
                [self uploadIcon:newImg];
                
//                [[JAUserApiRequest shareInstance] ali_upLoadUserIcon:@[self.iconImageView.image] isAsync:YES complete:^(NSArray<NSString *> *names, BOOL state) {
//
//                    NSString *imageStr = [names componentsJoinedByString:@"#"];
//                    if (imageStr.length) {
//                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                        dic[@"image"] = imageStr;
//                        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//
//                        [[JAUserApiRequest shareInstance] perfectUserInfo:dic success:^(NSDictionary *result) {
//
//                            [MBProgressHUD hideHUD];
//
//                            [self.view ja_makeToast:@"编辑成功"];
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                [[NSNotificationCenter defaultCenter] postNotificationName:EDITUSERINFOSUCCESS object:nil];
//
//                                if (self.imageChangeBlock) {
//                                    self.imageChangeBlock(newImg);
//                                }
//
//                                [self.navigationController popViewControllerAnimated:YES];
//                            });
//
//                        } failure:^(NSError *error) {
//                            [MBProgressHUD hideHUD];
//                            [self.view ja_makeToast:error.localizedDescription];
//                        }];
//                    }else{
//                        [MBProgressHUD hideHUD];
//                        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"图片上传失败，请重新上传"];
//                    }
//
//                }];
                
            };
                 
            [wself presentViewController:vc animated:YES completion:nil];
            
        }];
        
    }else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        
        UIImage *image = info[UIImagePickerControllerEditedImage];
        self.iconImageView.image = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // 压缩图片上传
            [self uploadIcon:image];
//            [[JAUserApiRequest shareInstance] ali_upLoadUserIcon:@[self.iconImageView.image] isAsync:YES complete:^(NSArray<NSString *> *names, BOOL state) {
//
//                NSString *imageStr = [names componentsJoinedByString:@"#"];
//                if (imageStr.length) {
//                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//                    dic[@"image"] = imageStr;
//                    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//
//                    [[JAUserApiRequest shareInstance] perfectUserInfo:dic success:^(NSDictionary *result) {
//
//                        [MBProgressHUD hideHUD];
//
//                        [self.view ja_makeToast:@"编辑成功"];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//                            [[NSNotificationCenter defaultCenter] postNotificationName:EDITUSERINFOSUCCESS object:nil];
//                            if (self.imageChangeBlock) {
//                                self.imageChangeBlock(image);
//                            }
//
//                            [self.navigationController popViewControllerAnimated:YES];
//                        });
//
//                    } failure:^(NSError *error) {
//                        [MBProgressHUD hideHUD];
//                        [self.view ja_makeToast:error.localizedDescription];
//                    }];
//                }else{
//                    [MBProgressHUD hideHUD];
//                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"图片上传失败，请重新上传"];
//                }
//
//            }];
        }];
        
    }
}

// 头像上传
- (void)uploadIcon:(UIImage *)image
{
    [MBProgressHUD showMessage:nil];
    [[JAUserApiRequest shareInstance] ali_upLoadUserIcon:@[self.iconImageView.image] isAsync:YES complete:^(NSArray<NSString *> *names, BOOL state) {
        
        NSString *imageStr = [names componentsJoinedByString:@"#"];
        if (imageStr.length) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"image"] = imageStr;
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            
            [[JAUserApiRequest shareInstance] perfectUserInfo:dic success:^(NSDictionary *result) {
                
                [MBProgressHUD hideHUD];
                
                [self.view ja_makeToast:@"编辑成功"];
                [JAUserInfo userInfo_updataUserInfoWithKey:User_ImageUrl value:imageStr];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:EDITUSERINFOSUCCESS object:nil];
                    if (self.imageChangeBlock) {
                        self.imageChangeBlock(image);
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUD];
                
            }];
        }else{
            [MBProgressHUD hideHUD];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"头像上传失败，是否要重试？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                [self uploadIcon:image];
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
}
@end
