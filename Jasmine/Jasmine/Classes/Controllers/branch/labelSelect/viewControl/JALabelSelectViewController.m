
//
//  JALabelSelectViewController.m
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JALabelSelectViewController.h"
#import "JALabelCollectionViewCell.h"
#import "JALabelSelectNetRequest.h"

static const NSString *reuseIdenfiter = @"LabelIdentifer";

@interface JALabelSelectViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIView *failureView;
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@end

@implementation JALabelSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.labels = [NSMutableArray new];
    [self setupUI];
    [self retryAction];
}

- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, WIDTH_ADAPTER(70), WIDTH_ADAPTER(330), 35)];
//    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.font = JA_MEDIUM_FONT(22);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = HEX_COLOR(JA_BlackTitle);
    titleLabel.text = @"选择你感兴趣的内容";
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:titleLabel];
    titleLabel.centerX = JA_SCREEN_WIDTH/2.0;
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, WIDTH_ADAPTER(144), 22)];
//    subTitleLabel.backgroundColor = [UIColor greenColor];
    subTitleLabel.font = JA_LIGHT_FONT(18);
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.textColor = HEX_COLOR(JA_BlackTitle);
    subTitleLabel.text = @"定制你的专属首页";
    subTitleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:subTitleLabel];
    subTitleLabel.centerX = JA_SCREEN_WIDTH/2.0;
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.titleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(13));
    [skipButton setTitle:@"跳过，随便看看" forState:UIControlStateNormal];
    [skipButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    [skipButton addTarget:self action:@selector(skipButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    skipButton.width = WIDTH_ADAPTER(120);
    skipButton.height = WIDTH_ADAPTER(50);
    skipButton.centerX = JA_SCREEN_WIDTH/2.0;
    skipButton.bottom = self.view.bottom-JA_TabbarSafeBottomMargin;
    
    UIImageView *arrowImageView = [UIImageView new];
    arrowImageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:arrowImageView];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.backgroundColor = HEX_COLOR(0xEDECEC);
    confirmButton.titleLabel.font = JA_REGULAR_FONT(FONT_ADAPTER(18));
    [confirmButton setTitle:@"选好了，进入茉莉" forState:UIControlStateNormal];
    [confirmButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = WIDTH_ADAPTER(25);
    confirmButton.layer.masksToBounds = YES;
    [self.view addSubview:confirmButton];
    self.confirmButton = confirmButton;
    confirmButton.width = JA_SCREEN_WIDTH-WIDTH_ADAPTER(30*2);
    confirmButton.height =  WIDTH_ADAPTER(50);
    confirmButton.centerX = JA_SCREEN_WIDTH/2.0;
    confirmButton.bottom = skipButton.top;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    CGFloat itemW = (JA_SCREEN_WIDTH-WIDTH_ADAPTER(32*2+18*3))/4.0;
    layout.itemSize = CGSizeMake(itemW, itemW+20+WIDTH_ADAPTER(10));
    layout.minimumInteritemSpacing = WIDTH_ADAPTER(18);
    if (iPhone4 || iPhone5) {
        layout.minimumLineSpacing = WIDTH_ADAPTER(20);
    } else {
        layout.minimumLineSpacing = WIDTH_ADAPTER(30);
    }
    layout.sectionInset = UIEdgeInsetsMake(0, WIDTH_ADAPTER(32), 0, WIDTH_ADAPTER(32));
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[JALabelCollectionViewCell class] forCellWithReuseIdentifier:@"LabelIdentifer"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    collectionView.width = JA_SCREEN_WIDTH;
    collectionView.y = subTitleLabel.bottom+WIDTH_ADAPTER(40);
    collectionView.height = confirmButton.top-WIDTH_ADAPTER(35)-collectionView.y;
    
    UIView *failureView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    failureView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:failureView];
    self.failureView = failureView;
    UITapGestureRecognizer *retryGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryAction)];
    [self.failureView addGestureRecognizer:retryGesture];
    
    UIImageView *imageView = [UIImageView new];
    [self.failureView addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"blank_fail"];
    [imageView sizeToFit];
    imageView.centerX = self.failureView.width/2.0;
    imageView.centerY = self.failureView.height/2.0;

    UILabel *failureLabel = [UILabel new];
    failureLabel.font = JA_REGULAR_FONT(18);
    failureLabel.textColor = HEX_COLOR(0x7e8392);
    [self.failureView addSubview:failureLabel];
    failureLabel.text = @"网络请求失败，请点击重试";
    [failureLabel sizeToFit];
    failureLabel.centerX = self.failureView.width/2.0;
    failureLabel.y = imageView.bottom+20;
}

- (void)confirmButtonAction:(UIButton *)sender {
    NSArray *array = [self getSelectedModels];
    if (array.count) {
        NSMutableArray *labelIds = [NSMutableArray new];
        for (JALabelSelectModel *model in array) {
            if (model.labelId.length) {
                [labelIds addObject:model.labelId];
            }
        }
        if (labelIds.count) {
            sender.userInteractionEnabled = NO;
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"labelIds"] = labelIds;
            JALabelSelectNetRequest *request = [[JALabelSelectNetRequest alloc] initRequest_saveLabelsWithParameter:params];
            [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                sender.userInteractionEnabled = YES;
                if (responseModel.code != 10000) {
                    return;
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                sender.userInteractionEnabled = YES;
            }];
        }
    }
}

- (void)skipButtonAction {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)retryAction {
    self.failureView.hidden = YES;
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [self getRecommendLabels];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.labels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JALabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LabelIdentifer" forIndexPath:indexPath];
    cell.data = self.labels[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JALabelSelectModel *model = self.labels[indexPath.item];
    if (model) {
        model.isSelected = !model.isSelected;
        [self.collectionView reloadData];
        
        NSArray *array = [self getSelectedModels];
        if (array.count) {
            self.confirmButton.backgroundColor = HEX_COLOR(JA_Green);
            [self.confirmButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
        } else {
            self.confirmButton.backgroundColor = HEX_COLOR(0xEDECEC);
            [self.confirmButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        }
    }
}

- (NSArray *)getSelectedModels {
    NSMutableArray *models = [NSMutableArray new];
    for (JALabelSelectModel *model in self.labels) {
        if (model.isSelected) {
            [models addObject:model];
        }
    }
    return models;
}

#pragma mark - Network
- (void)getRecommendLabels {
//    NSMutableArray *array = [NSMutableArray new];
//    for (int i=0; i<12; i++) {
//        JALabelSelectModel *model = [JALabelSelectModel new];
//        model.labelId = [NSString stringWithFormat:@"%d",i];
//        model.labelName = @"呵呵呵呵";
//        model.labelThumb = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/msg_img_log.png";
//        [array addObject:model];
//    }
//    [self.labels addObjectsFromArray:array];
//    [self.collectionView reloadData];
//    return;
    
    JALabelSelectNetRequest *request = [[JALabelSelectNetRequest alloc] initRequest_labelsWithParameter:nil];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        if (responseModel.code != 10000) {
            return;
        }
        JALabelSelectGroupModel *groupModel = (JALabelSelectGroupModel *)responseModel;
        if (groupModel.resBody.count) {
            [self.labels removeAllObjects];
            [self.labels addObjectsFromArray:groupModel.resBody];
            [self.collectionView reloadData];
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        self.failureView.hidden = NO;

    }];
}


@end
