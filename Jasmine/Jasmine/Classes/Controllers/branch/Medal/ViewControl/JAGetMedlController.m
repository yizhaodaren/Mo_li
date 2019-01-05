
//
//  JAGetMedlController.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAGetMedlController.h"

#import "JAMedalModel.h"

#import "JAMedalNetRequest.h"

#import "JAMedalShareManager.h"
@interface JAGetMedlController ()
//约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTopDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareBtnTopDistance;

//UI
@property (weak, nonatomic) IBOutlet UIImageView *medalImageView;
@property (weak, nonatomic) IBOutlet UILabel *medalNameLable;//勋章名字
@property (weak, nonatomic) IBOutlet UILabel *medalDetailLable;//勋章获得条件

@property (weak, nonatomic) IBOutlet UIButton *adornBtn;//佩戴
@property(nonatomic,strong)NSMutableArray *notReadMedalArray;//未读的勋章
@property(nonatomic,strong)JAMedalModel *currentMedalModel;
@end

@implementation JAGetMedlController
+(instancetype)shared{
    static JAGetMedlController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[JAGetMedlController alloc] initWithNibName:@"JAGetMedlController" bundle:[NSBundle mainBundle]];
    });
    return instance;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _closeBtnTopDistance.constant = JA_StatusBarHeight + 8;
    _shareBtnTopDistance.constant = JA_StatusBarHeight + 8;
    _adornBtn.layer.cornerRadius = _adornBtn.size.height/2;
    _adornBtn.layer.borderWidth = 1.5;
    _adornBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
       _medalImageView.center = CGPointMake(JA_SCREEN_WIDTH/2, JA_SCREEN_HEIGHT/3);
}
- (IBAction)adronMedalAction:(id)sender {
    [self adornMedal];
}
- (IBAction)closeBtnAction:(id)sender {
    [self.view removeFromSuperview];
    //移除上一个
    [self.notReadMedalArray removeLastObject];
  
    if (self.notReadMedalArray.count > 0) {
        //跟新UI
        [self updateUIWith:self.notReadMedalArray.lastObject];
        if ([self.delegate respondsToSelector:@selector(showNextMedal)]) {
           [self.delegate showNextMedal];
        }
    }
}
- (IBAction)shareAction:(id)sender {
    [[JAMedalShareManager instance] shareWith:_currentMedalModel.shareMsgVO domainType:6];
}
//更新数据
-(void)updateArrayWith:(JAMedalGroupModel *)model{
    [self.notReadMedalArray removeAllObjects];
    for (JAMedalModel * m in model.inviteList) {
        if ([m.status isEqualToString:@"0"]) {
             [self.notReadMedalArray addObject:m];
        }
    }
    for (JAMedalModel *m in model.dayList) {
        if ([m.status isEqualToString:@"0"]) {
            [self.notReadMedalArray addObject:m];
        }
    }
    for (JAMedalModel *m in model.storyList) {
        if ([m.status isEqualToString:@"0"]) {
            [self.notReadMedalArray addObject:m];
        }
    }
    if (self.notReadMedalArray.count > 0) {
        
        [self updateUIWith:self.notReadMedalArray.lastObject];
        if ([_delegate respondsToSelector:@selector(showNextMedal)]) {
              [self.delegate showNextMedal];
        }
    }
}
-(void)updateUIWith:(JAMedalModel *)model{
     _currentMedalModel = model;
    
    //设置图片
    [self.medalImageView sd_setImageWithURL:[NSURL URLWithString:model.getImgUrl] placeholderImage:[UIImage imageNamed:@""]];
    self.medalNameLable.text = model.medalName;
    //勋章获得条件
    if ([model.medalType isEqualToString:@"1"]) {
        _medalDetailLable.text = [NSString stringWithFormat:@"连续登录%@天获得",model.conditionNum];
    }else if([model.medalType isEqualToString:@"2"]){
        _medalDetailLable.text = [NSString stringWithFormat:@"邀请%@个用户获得",model.conditionNum];
    }else if([model.medalType isEqualToString:@"3"]){
        _medalDetailLable.text = [NSString stringWithFormat:@"发布%@个主贴获得",model.conditionNum];
    }
}
- (void)showAnimation:(BOOL)isAnimation
{
    if (isAnimation) {
        //使用CAAnimationGroup
        //1.不透明度的变化
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @0.;
        opacityAnimation.toValue = @1.;
        opacityAnimation.duration = 0.5f;
        //2.大小的变化
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        //确定变化的情况
        CATransform3D startingScale = CATransform3DScale(self.view.layer.transform, 0, 0, 0);
        CATransform3D overshootScale = CATransform3DScale(self.view.layer.transform, 1.05, 1.05, 1.0);
        CATransform3D undershootScale = CATransform3DScale(self.view.layer.transform, 0.97, 0.97, 1.0);
        CATransform3D endingScale = self.view.layer.transform;
        
        NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
        //第二个动画的时间
        NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
        //添加到group里面
        NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
        //        时间累计
        [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
        //        可以为每个动画设置不同的动画方式
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        //        最后结束的情况
        [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
        [keyTimes addObject:@1.0f];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        //        赋值
        scaleAnimation.values = scaleValues;
        //        注意keytimes时间差
        scaleAnimation.keyTimes = keyTimes;
        scaleAnimation.timingFunctions = timingFunctions;
        //        CAAnimationGroup
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        animationGroup.duration = 0.6;
        [self.view.layer addAnimation:animationGroup forKey:nil];
    }
}
- (void)dismissForAnimated:(BOOL)animated {
    if (animated) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @1.;
        opacityAnimation.toValue = @0.;
        opacityAnimation.duration = 0.5;
        [self.view.layer addAnimation:opacityAnimation forKey:nil];
        
        CATransform3D transform = CATransform3DScale(self.view.layer.transform, 0, 0, 0);
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:self.view.layer.transform];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        scaleAnimation.duration = 0.5;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[opacityAnimation, scaleAnimation];
        animationGroup.duration = 0.5;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.view.layer addAnimation:animationGroup forKey:nil];
        
        self.view.layer.opacity = 0;
        self.view.layer.transform = transform;
    }
}
#pragma mark  懒加载notReadMedalArray
-(NSMutableArray *)notReadMedalArray{
    if (!_notReadMedalArray) {
        _notReadMedalArray = [NSMutableArray array];
    }
    return _notReadMedalArray;
}

#pragma mark 佩戴网络请求
-(void)adornMedal{
        self.adornBtn.enabled = NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"medalId"] = _currentMedalModel.medalId;
    dic[@"use"] = @"1";
    JAMedalNetRequest *request = [[JAMedalNetRequest alloc] initRequest_adornMedalWithParameter:dic MedalID:_currentMedalModel.medalId WithUse:@"1"];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        self.adornBtn.enabled = YES;
        if (responseModel.code == 10000) {
                [self.view ja_makeToast:@"佩戴成功!"];
            //刷新勋章列表数据
            if ([self.delegate respondsToSelector:@selector(refreshMedalList)]) {
                [self.delegate refreshMedalList];
            }
            //
            [self closeBtnAction:nil];
            //把勋章图像保存本地
            [JAUserInfo userInfo_updataUserInfoWithKey:User_medalImage value:_currentMedalModel.getImgUrl];
            return;
        }else{
            [self.view ja_makeToast:responseModel.message];
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
         self.adornBtn.enabled = YES;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
