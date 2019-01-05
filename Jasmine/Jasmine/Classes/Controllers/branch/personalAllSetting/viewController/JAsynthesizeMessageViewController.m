//
//  JAsynthesizeMessageViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAsynthesizeMessageViewController.h"
#import "FSScrollContentView.h"
#import "SPPageMenu.h"

#import "JAActivityCenterViewController.h"
#import "JAMessageViewController.h"
#import "JAVoiceNotiReplyViewController.h"
#import "JACommonSearchPeopleVC.h"

#import "JANotiModel.h"

@interface JAsynthesizeMessageViewController ()<SPPageMenuDelegate>

@property (nonatomic, strong) FSPageContentView *contentView;
@property (nonatomic, strong) SPPageMenu *titleView;
@property (nonatomic, weak) UIButton *contactsButton;
@property (nonatomic, weak) JAVoiceNotiReplyViewController *replyVC;
@end

@implementation JAsynthesizeMessageViewController

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationView];
    [self.view addSubview:self.contentView];
    self.contactsButton.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointDismiss" object:nil];
}

- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 是否有活动红点
        //    BOOL activityRed = [JARedPointManager checkRedPoint:JARedPointTypeActivity];
        // 是否有消息红点
        BOOL notiRed = ([JARedPointManager checkRedPoint:120] || [JARedPointManager checkRedPoint:JARedPointTypeCallPerson]);
        // 是否有私信红点
        BOOL msgRed = ([JARedPointManager checkRedPoint:JARedPointTypeMessage] || [JARedPointManager checkRedPoint:JARedPointTypeAnnouncement]);
        
        //    [self.titleView setRedViewHidden:!activityRed index:0];
        //    [self.titleView setRedViewHidden:!notiRed index:0];
        //    [self.titleView setRedViewHidden:!msgRed index:1];
        
        if (notiRed) {
            
            // 获取消息通知的数目
            NSInteger replyCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Reply];
            NSInteger atCount = [JARedPointManager getRedPointNumber:JARedPointTypeCallPerson];
            NSInteger likeCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Agree];
            NSInteger focusCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Focus];
            NSInteger inviteCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Invite];
            
            NSString *countS = [NSString stringWithFormat:@"%ld",replyCount + atCount + likeCount + focusCount + inviteCount];
            countS = countS.integerValue > 99 ? @"..." : countS;
            [self.titleView setRedCountLabelValue:countS index:0];
            
        }else{
            [self.titleView setRedCountLabelValue:nil index:0];
        }
        
        if (msgRed) {
            
            // 获取私信聊天的数目
            NSInteger announceCount = [JARedPointManager getRedPointNumber:JARedPointTypeAnnouncement];  // 茉莉君
            NSInteger msgCount = [JARedPointManager getRedPointNumber:JARedPointTypeMessage];    // 小秘书、聊天、客服
            NSString *countS = [NSString stringWithFormat:@"%ld",announceCount + msgCount];
            countS = countS.integerValue > 99 ? @"..." : countS;
            [self.titleView setRedCountLabelValue:countS index:1];
            
        }else{
            [self.titleView setRedCountLabelValue:nil index:1];
        }
    });
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self redPointArrive];
}

- (void)setNavigationView
{
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 160, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    pageMenu.delegate = self;
    pageMenu.itemTitleFont = JA_REGULAR_FONT(18);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    pageMenu.dividingLine.hidden = YES;
    self.titleView = pageMenu;
    
    self.navigationItem.titleView = self.titleView;
    
    self.titleView.bridgeScrollView = (UIScrollView *)self.contentView.collectionView;
//    NSArray *titleArr = @[@"活动",@"消息",@"私信"];
    NSArray *titleArr = @[@"消息",@"私信"];
    [self.titleView setItems:titleArr selectedItemIndex:self.selectIndex];
    
}

// 跳转联系人
- (void)clickRight_check
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    JACommonSearchPeopleVC *vc = [JACommonSearchPeopleVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    self.contentView.contentViewCurrentIndex = toIndex;
 
    [_replyVC.inputView registAllInput];
}

#pragma mark - FSPageContentView懒加载
// 已登录视图
- (FSPageContentView *)contentView {
    if (!_contentView) {
        NSMutableArray *contentVCs = [NSMutableArray new];
//        JAActivityCenterViewController *vc1 = [JAActivityCenterViewController new];
        JAVoiceNotiReplyViewController *vc2 = [[JAVoiceNotiReplyViewController alloc]init];
        _replyVC = vc2;
        JAMessageViewController *vc3 = [[JAMessageViewController alloc]init];
        
//        [contentVCs addObject:vc1];
        [contentVCs addObject:vc2];
        [contentVCs addObject:vc3];
        
        CGFloat contentViewHeigh = JA_SCREEN_HEIGHT - JA_StatusBarAndNavigationBarHeight;
        _contentView = [[FSPageContentView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, contentViewHeigh)
                                                       childVCs:contentVCs
                                                       parentVC:self
                                                       delegate:nil];
        self.contentView.contentViewCurrentIndex = self.selectIndex;
        
        
    }
    return _contentView;
}


- (UIButton *)contactsButton
{
    if (_contactsButton == nil) {
        UIButton *contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _contactsButton = contactsButton;
        [contactsButton setImage:[UIImage imageNamed:@"branch_msg_contact"] forState:UIControlStateNormal];
        contactsButton.width = 40;
        contactsButton.height = 44;
        [contactsButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];

        [contactsButton addTarget:self action:@selector(clickRight_check) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:contactsButton];
        self.navigationItem.leftBarButtonItem = rightItem;
    }
    
    return _contactsButton;
}

#pragma mark - 2.6.0后这个作为主控制器后 添加这个类型(这个返回只清空回复的数据,其他的在各自的界面清空)
- (void)actionLeft
{
    [super actionLeft];
    
    // 查看是否有回复红点，如果有不清空数据
    BOOL reply_red = [JARedPointManager checkRedPoint:JARedPointTypeNoti_Reply];
    if (!reply_red) {
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"operation"] = @"reply";
            
            //        NSString *searchStr = [NSString stringWithFormat:@"(playState!=0 or playReplyState!=0 or playCommentState!=0 or readState=NO) and %@",dic];
            
            NSArray *arr = [JANotiModel searchWithWhere:dic];
            //        NSArray *arr = [JANotiModel searchWithWhere:nil];
            
            for (JANotiModel *data in arr) {
                
                data.readState = YES;
                data.playState = 0;
                data.playReplyState = 0;
                data.playCommentState = 0;
                [data updateToDB];
            }
        });
    }
    
}
@end
