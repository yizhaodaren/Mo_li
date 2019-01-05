//
//  JARelationshipViewController.m
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JARelationshipViewController.h"
#import "JASubRelationshipViewController.h"
#import "JASearchTopView.h"


@interface JARelationshipViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) JASubRelationshipViewController *friendVC;
@property (nonatomic, strong) JASubRelationshipViewController *followVC;
@property (nonatomic, strong) JASubRelationshipViewController *fanVC;

@property (nonatomic, strong) NSArray *historyArr;

@property (nonatomic, strong) NSMutableArray *historyRecord;

@property (nonatomic, strong) NSString *front_KeyWord;

@end

@implementation JARelationshipViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置UI
    [self setupUI];
    [self setupChildVC];
}

- (void)setupUI
{
//    [self setRightNavigationItemImage:[UIImage imageNamed:@"mine_addfriend_btn"] highlightImage:nil];
}

- (void)actionRight {
    
}

- (void)setupChildVC
{
    [self setCenterTitle:@"好友"];
    self.layoutY = 0;
    self.title_margin = 20;
    
    self.friendVC = [JASubRelationshipViewController new];
    self.friendVC.type = 0;
    self.friendVC.userId = self.userId;
    self.friendVC.title = @"好友";
    
    self.followVC = [JASubRelationshipViewController new];
    self.followVC.type = 1;
    self.followVC.userId = self.userId;
    self.followVC.title = @"关注";
   
    self.fanVC = [JASubRelationshipViewController new];
    self.fanVC.type = 2;
    self.fanVC.userId = self.userId;
    self.fanVC.title = @"粉丝";
    
    if (self.isOtherRelation) {
        self.childViewControlArray = @[self.followVC,self.fanVC];
    } else {
        self.childViewControlArray = @[self.friendVC,self.followVC,self.fanVC];
    }
    
    // 点击按钮的时候做的事情
    @WeakObj(self);
    self.clickButtonBlock = ^(UIViewController *vc, UIButton *button) {
        @StrongObj(self);
        [self setVCTitle];
        
        if (vc == self.followVC) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[JA_Property_ScreenName] = @"关注列表";
            [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
        }else if(vc == self.fanVC){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[JA_Property_ScreenName] = @"粉丝列表";
            [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
        }
    };
    
    // 滚动结束后需要做的事情
    self.endScrollBlock = ^(UIViewController *vc) {
        @StrongObj(self);
        [self setVCTitle];
        if (vc == self.followVC) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[JA_Property_ScreenName] = @"关注列表";
            [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
        }else if(vc == self.fanVC){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[JA_Property_ScreenName] = @"粉丝列表";
            [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
        }
    };
}

- (void)setVCTitle {
    [(JASubRelationshipViewController *)self.currentViewControl getData:^(NSInteger dataCount) {
        NSString *titleString = nil;
        if (self.currentViewControl == self.friendVC) {
            if (dataCount) {
                titleString = [NSString stringWithFormat:@"好友(%zd)",dataCount];
            } else {
                titleString = @"好友";
            }
        } else if (self.currentViewControl == self.followVC) {
            if (dataCount) {
                titleString = [NSString stringWithFormat:@"关注(%zd)",dataCount];
            } else {
                titleString = @"关注";
            }
        } else if (self.currentViewControl == self.fanVC) {
            if (dataCount) {
                titleString = [NSString stringWithFormat:@"粉丝(%zd)",dataCount];
            } else {
                titleString = @"粉丝";
            }
        }
        [self setCenterTitle:titleString];
    }];
}

@end

