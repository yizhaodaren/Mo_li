//
//  JAMedalDetailController.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalDetailController.h"
#import "JAMedalNetRequest.h"

//分享
#import "JAMedalShareManager.h"
@interface JAMedalDetailController ()<PlatformShareDelegate>

@property(nonatomic,strong)UIImageView *medalImageView;//勋章图像
@property(nonatomic,strong)UILabel *medalTitleLable;//勋章标题
@property(nonatomic,strong)UILabel *medalGetChannelLable;//获得条件
@property(nonatomic,strong)UILabel *medalDetailLable;//勋章相关状态
@property(nonatomic,strong)UILabel *medalNextStepLable;//下一等级条件

@property(nonatomic,strong)UIButton *closeBtn;//关闭
@property(nonatomic,strong)UIButton *shareBtn;//分享
@property(nonatomic,strong)UIButton *adornBtn;//佩戴
@property(nonatomic,strong)UIButton *dischargeBtn;//卸下
@property(nonatomic,strong)UIButton *adornedBtn;//已佩戴



@property(nonatomic,strong)JAMedalModel *medal;//当前勋章
@end

@implementation JAMedalDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    //获取勋章勋章信息
    [self getMedalInfoMedalID:self.medalID];
}
-(void)initUI{
    
    //勋章图标
    _medalImageView = [[UIImageView alloc] init];
     [self.view addSubview:_medalImageView];
    [_medalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).multipliedBy(0.5);
        make.height.offset = 120;
        make.width.offset(160);
        
    }];
    //勋章标题
    _medalTitleLable = [[UILabel alloc] init];
    [_medalTitleLable setFont:T24_FONT];
    [self.view addSubview:_medalTitleLable];
    [_medalTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_medalImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    //勋章获得条件
    _medalGetChannelLable = [UILabel new];
    _medalGetChannelLable.textColor = HEX_COLOR(0x9B9B9B);
    [_medalGetChannelLable setFont:T18_FONT];
    [self.view addSubview:_medalGetChannelLable];
    [_medalGetChannelLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_medalTitleLable.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
    }];

    //勋章相关状态
    _medalDetailLable = [UILabel new];
    [_medalDetailLable setFont:T18_FONT];
    [self.view addSubview:_medalDetailLable];
    [_medalDetailLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_medalGetChannelLable.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    
    //下一等级条件
    _medalNextStepLable = [UILabel new];
    [_medalNextStepLable setFont:T14_FONT];
    _medalNextStepLable.textColor = HEX_COLOR(0x9B9B9B);
    [self.view addSubview:_medalNextStepLable];
    [_medalNextStepLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-65);
    }];
    
    //佩戴
    _adornBtn = [[UIButton alloc] init];
        [_adornBtn addTarget:self action:@selector(adornBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_adornBtn setTitleColor:HEX_COLOR(0x6BD379) forState:UIControlStateNormal];
    [_adornBtn setTitle:@"佩戴" forState:UIControlStateNormal];
    [_adornBtn.titleLabel setFont:T18_FONT];
    _adornBtn.layer.cornerRadius = 20;
    _adornBtn.layer.borderWidth = 1;
    _adornBtn.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
    [self.view addSubview:_adornBtn];
    [_adornBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(92, 40));
        make.bottom.equalTo(_medalNextStepLable.mas_top).offset(-18);
        make.centerX.equalTo(self.view);
        
    }];
    
    //已佩戴
    _adornedBtn = [UIButton new];
    [_adornedBtn setTitleColor:HEX_COLOR(0xC6C6C6) forState:UIControlStateNormal];
    [_adornedBtn setTitle:@"已佩戴" forState:UIControlStateNormal];
    [_adornedBtn.titleLabel setFont:T18_FONT];
    _adornedBtn.layer.cornerRadius = 20;
    _adornedBtn.backgroundColor = HEX_COLOR(0xF9F9F9);
    [self.view addSubview:_adornedBtn];
    [_adornedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_adornBtn);
        make.centerY.equalTo(_adornBtn);
        make.left.mas_equalTo(_adornBtn.mas_left).offset(-65);
        
    }];
    
    //卸下
    _dischargeBtn = [UIButton new];
    [_dischargeBtn addTarget:self action:@selector(dischargeAction) forControlEvents:UIControlEventTouchUpInside];
    [_dischargeBtn setTitleColor:HEX_COLOR(0x6BD379) forState:UIControlStateNormal];
    [_dischargeBtn setTitle:@"卸下" forState:UIControlStateNormal];
    [_dischargeBtn.titleLabel setFont:T18_FONT];
    _dischargeBtn.layer.cornerRadius = 20;
    _dischargeBtn.layer.borderWidth = 1;
    _dischargeBtn.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
    [self.view addSubview:_dischargeBtn];
    [_dischargeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_adornBtn);
        make.centerY.equalTo(_adornBtn);
        make.right.mas_equalTo(_adornBtn.mas_right).offset(65);
        
    }];
    
    //关闭
    _closeBtn = [UIButton new];
    [_closeBtn setImage:[UIImage imageNamed:@"branch_medal_back_black"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.top.equalTo(self.view.mas_top).offset(JA_StatusBarHeight + 8);
        make.left.equalTo(self.view.mas_left).offset(20);
    }];
    
    
    if (_isMySelfMedal) {
        //分享
        _shareBtn = [UIButton new];
        [_shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setImage:[UIImage imageNamed:@"branch_medal_share_black"] forState:UIControlStateNormal];
        [self.view addSubview:_shareBtn];
        [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(_closeBtn);
            make.top.equalTo(_closeBtn);
            make.right.equalTo(self.view.mas_right).offset(-20);
        }];
    }
    //展示详情前隐藏
    self.shareBtn.hidden = YES;
    self.adornBtn.hidden = YES;
    self.dischargeBtn.hidden = YES;
    self.adornedBtn.hidden = YES;
}
//根据当前model 刷新页面
-(void)updateUI{
    //勋章图像
    NSString *urlStr = _medal.getImgUrl;
    if ([_medal.status isEqualToString:@"3"]) {
         //如果是未获得状态
        urlStr = _medal.unImgUrl;
        self.shareBtn.hidden = YES;
    }else{
        self.shareBtn.hidden = NO;
    }
    [_medalImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
    //勋章标题
        _medalTitleLable.text = _medal.medalName;
    //勋章获得条件
    if ([_medal.medalType isEqualToString:@"1"]) {
        _medalGetChannelLable.text = [NSString stringWithFormat:@"连续登录%@天获得",_medal.conditionNum];
    }else if([_medal.medalType isEqualToString:@"2"]){
        _medalGetChannelLable.text = [NSString stringWithFormat:@"邀请%@个用户获得",_medal.conditionNum];
    }else if([_medal.medalType isEqualToString:@"3"]){
        _medalGetChannelLable.text = [NSString stringWithFormat:@"发布%@个主贴获得",_medal.conditionNum];
    }
    
    if([_medal.status isEqualToString:@"3"]){
        //未获得勋章
        _medalDetailLable.text = [NSString stringWithFormat:@"已有%@人获得",_medal.totalNum];
    }else{
        NSString *timeStr = [NSString MedalgetDatefromString:_medal.createTime];
        _medalDetailLable.text = [NSString stringWithFormat:@"%@ 完成  已有%@人获得",timeStr,_medal.totalNum];
    }
    
    
    //下一等级条件
    NSInteger  finsedNum = [_medal.finishedNum integerValue];
    NSInteger nextConditionNum = [_medal.nextConditionNum integerValue];

    //如果当前完成度 大于下一勋章等级的
    if (finsedNum > nextConditionNum) {
             _medalNextStepLable.text = @"";
    }else{
        NSInteger distance = nextConditionNum - finsedNum;
        if ([_medal.medalType isEqualToString:@"1"]) {
            _medalNextStepLable.text = [NSString stringWithFormat:@"距离下一级勋章还需连续登录%ld天",distance];
        }else if([_medal.medalType isEqualToString:@"2"]){
            _medalNextStepLable.text = [NSString stringWithFormat:@"距离下一级勋章还需邀请%ld个用户",distance];
        }else if([_medal.medalType isEqualToString:@"3"]){
            _medalNextStepLable.text = [NSString stringWithFormat:@"距离下一级勋章还需发布%ld个主贴",distance];
        }
        
        if ([_medal.status isEqualToString:@"3"]) {
            //如果是未获得的勋章
            if ([_medal.medalType isEqualToString:@"1"]) {
                _medalNextStepLable.text = [NSString stringWithFormat:@"完成度 %@/%@ 天",_medal.finishedNum,_medal.conditionNum];
            }else if([_medal.medalType isEqualToString:@"2"]){
                _medalNextStepLable.text = [NSString stringWithFormat:@"完成度 %@/%@ 个",_medal.finishedNum,_medal.conditionNum];

            }else if([_medal.medalType isEqualToString:@"3"]){
                _medalNextStepLable.text = [NSString stringWithFormat:@"完成度 %@/%@ 个",_medal.finishedNum,_medal.conditionNum];

            }
        }
    }

    
    //如果是重他人也买呢进入的不展示佩戴按钮
    if (_isMySelfMedal) {
        [self updateUIwithStatus:_medal.status];
    }else{
        [self updateUIwithStatus:@"3"];
    }

 
}
#pragma mark BtnAction
//返回
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    //恢复进来时候的statusBarStyle样式
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:NO];
}
//分享
-(void)shareAction{
    [[JAMedalShareManager instance] shareWith:_medal.shareMsgVO domainType:6];

}
//佩戴勋章
-(void)adornBtnAction{
    [self adornOrDischargeMedalWithUse:@"1"];
}
//卸下勋章
-(void)dischargeAction{
    [self adornOrDischargeMedalWithUse:@"0"];
}
//更新按钮显示
-(void)updateUIwithStatus:(NSString *)status{
    
    //0没有阅览 1已阅读  2佩戴中 3未获得
    if ([status isEqualToString:@"1"]) {
        self.adornBtn.hidden = NO;
        self.dischargeBtn.hidden = YES;
        self.adornedBtn.hidden = YES;
    }else if([status isEqualToString:@"2"]){
        self.adornBtn.hidden = YES;
        self.dischargeBtn.hidden = NO;
        self.adornedBtn.hidden = NO;
    }if([status isEqualToString:@"3"]){
        self.adornBtn.hidden = YES;
        self.dischargeBtn.hidden = YES;
        self.adornedBtn.hidden = YES;
    }

}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
#pragma mark 网络请求

//勋章详情
-(void)getMedalInfoMedalID:(NSString *)medalId{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"medalId"] = medalId;
    dic[@"userId"] = self.medalUserID;
    JAMedalNetRequest *request = [[JAMedalNetRequest alloc] initRequest_MedalInfoWithParameter:dic MedalID:medalId WithUserID:self.medalUserID];
    
 
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code == 10000) {
            JAMedalModel *model = (JAMedalModel *)responseModel;
            _medal = model;
            [self updateUI];
            return;
        }else{
            [self.view ja_makeToast:responseModel.message];
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}
//佩戴卸载勋章
-(void)adornOrDischargeMedalWithUse:(NSString *)use{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"medalId"] = _medal.medalId;
    dic[@"use"] = use;
    JAMedalNetRequest *request = [[JAMedalNetRequest alloc] initRequest_adornMedalWithParameter:dic MedalID:_medal.medalId WithUse:use];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code == 10000) {
            if ([use isEqualToString:@"0"]) {
                  [self.view ja_makeToast:@"成功卸下!"];
                  [self updateUIwithStatus:@"1"];
                //把勋章图像保存本地
                  [JAUserInfo userInfo_updataUserInfoWithKey:User_medalImage value:@""];
            }else{
                  [self.view ja_makeToast:@"佩戴成功!"];
                  [self updateUIwithStatus:@"2"];
                 //把勋章图像保存本地
                 [JAUserInfo userInfo_updataUserInfoWithKey:User_medalImage value:_medal.getImgUrl];
            }
            //刷新勋章列表数据
            if ([self.delegate respondsToSelector:@selector(refreshMedalList)]) {
                [self.delegate refreshMedalList];
            }
            return;
        }else{
             [self.view ja_makeToast:responseModel.message];
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

@end

