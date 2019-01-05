//
//  JFImagePickerController.m
//  JFImagePickerController
//
//  Created by Johnil on 15-7-3.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "JFImagePickerController.h"
#import "JFImageGroupTableViewController.h"
#import "JFPhotoBrowserViewController.h"
#import "JFImageCollectionViewController.h"
#import "JFAssetHelper.h"
#import "JFImageManager.h"

@interface JFImagePickerController () <JDPhotoBrowserDelegate>
@property (nonatomic, weak) UIBarButtonItem *done;
@end

@implementation JFImagePickerController {
	UIBarButtonItem *selectNum;
	UIBarButtonItem *preview;
	UIToolbar *toolbar;
	JFImageCollectionViewController *collectionViewController;
    UIStatusBarStyle tempBarStyle;
}

- (JFImagePickerController *)initWithPreviewIndex:(NSInteger)index{
    self = [super initWithRootViewController:[JFImageGroupTableViewController new]];
    if (self) {
        ASSETHELPER.previewIndex = index;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
	self = [super initWithRootViewController:[JFImageGroupTableViewController new]];
	if (self) {
        ASSETHELPER.previewIndex = -1;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	if (ASSETHELPER.selectdPhotos.count>0) {
		preview.title = @"预览";
	} else {
		preview.title = @"";
	}
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tempBarStyle = [UIApplication sharedApplication].statusBarStyle;
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    });

	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44, [UIScreen mainScreen].bounds.size.width, 44)];
	toolbar.tintColor = [UIColor whiteColor];
	toolbar.barStyle = UIBarStyleBlack;
	[self.view addSubview:toolbar];
    UIBarButtonItem *leftFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	UIBarButtonItem *rightFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	preview = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(preview)];
	UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	selectNum = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *fix2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(choiceDone)];
    _done = done;
    done.enabled = NO;
	[toolbar setItems:@[leftFix, preview, fix, selectNum, fix2, done, rightFix]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCount:) name:@"selectdPhotos" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePhotoImage:) name:@"kJFTakePhotoImage" object:nil];
    
    
	
}

- (void)setLeftTitle:(NSString *)title{
	preview.title = title;
}

- (UIToolbar *)customToolbar{
	return toolbar;
}
- (void)receivePhotoImage:(NSNotification *)notifi
{
    if (tempBarStyle!=UIStatusBarStyleLightContent) {
        [[UIApplication sharedApplication] setStatusBarStyle:tempBarStyle animated:NO];
    }
    UIImage *image = notifi.object;
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(imagePickerDidTakePhotoFinished:image:)])
    {
        [_pickerDelegate imagePickerDidTakePhotoFinished:self image:image];
    }
    
}
- (void)changeCount:(NSNotification *)notifi{
	selectNum.title = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)ASSETHELPER.selectdPhotos.count, _maxCount];
	if (![preview.title isEqualToString:@"取消"]) {
		if (ASSETHELPER.selectdPhotos.count>0) {
			preview.title = @"预览";
            _done.enabled = YES;
		} else {
			preview.title = @"";
            _done.enabled = NO;
		}
    }else{
        
        if (ASSETHELPER.selectdPhotos.count > 0) {
           _done.enabled = YES;
        }else{
           _done.enabled = NO; 
        }
    }
}

- (void)cancel{
	if (_pickerDelegate) {
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:tempBarStyle animated:NO];
        }
		[_pickerDelegate imagePickerDidCancel:self];
	}
}

- (void)preview{
	if (preview.title.length<=0) {
		return;
	}
	if ([preview.title isEqualToString:@"取消"]) {
		[self cancel];
		return;
	}
	if ([preview.title isEqualToString:@"预览"]) {
		preview.title = @"取消";
        ASSETHELPER.previewIndex = 0;
		collectionViewController = (JFImageCollectionViewController *)self.visibleViewController;
		JFPhotoBrowserViewController *photoBrowser = [[JFPhotoBrowserViewController alloc] initWithPreview];
		photoBrowser.delegate = self;
		[self pushViewController:photoBrowser animated:YES];
	} else {
        [self cancel];
	}
}

- (void)choiceDone{
    
    if (!self.assets.count) {
        
//        _done.enabled = NO;
        return;
    }
    
	if (_pickerDelegate) {
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:tempBarStyle animated:NO];
        }
		[_pickerDelegate imagePickerDidFinished:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numOfPhotosFromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
	return ASSETHELPER.selectdPhotos.count;
}

- (NSInteger)currentIndexFromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
	return ASSETHELPER.previewIndex;
}

- (ALAsset *)assetWithIndex:(NSInteger)index fromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
    return ASSETHELPER.selectdAssets[index];
}

- (JFImagePickerViewCell *)cellForRow:(NSInteger)row{
	return (JFImagePickerViewCell *)[[collectionViewController collectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

- (NSArray *)imagesWithType:(NSInteger)type{
    NSMutableArray *temp = [NSMutableArray array];
    for (ALAsset *asset in ASSETHELPER.selectdAssets) {
        [temp addObject:[ASSETHELPER getImageFromAsset:asset type:type]];
    }
    return temp;
}

- (NSArray *)assets{
    return ASSETHELPER.selectdAssets;
}

+ (void)clear{
    [ASSETHELPER clearData];
    [[JFImageManager sharedManager] clearMem];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
 
- (BOOL)shouldAutorotate{
    return NO;
}
- (void)setMaxCount:(NSInteger)maxCount
{
//    if (maxCount > 6)
//    {
//        _maxCount = 6;
//    }
//    else
//    {
//        _maxCount = maxCount;
//    }
     _maxCount = maxCount;
    ASSETHELPER.maxCount = _maxCount;
    selectNum.title = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)ASSETHELPER.selectdPhotos.count,_maxCount];
}


@end
