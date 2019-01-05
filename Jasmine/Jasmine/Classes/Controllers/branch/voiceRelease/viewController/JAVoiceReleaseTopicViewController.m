//
//  JAVoiceReleaseTopicViewController.m
//  Jasmine
//
//  Created by xujin on 23/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAVoiceReleaseTopicViewController.h"
#import "JACommonTopicCell.h"
#import "JAHotTopicListView.h"
#import "JASearchTopicTopView.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceTopicGroupModel.h"
#import "JADataHelper.h"

static NSString *const kVoiceTopicCellIdentifier = @"JAVoiceTopicCellIdentifier";

@interface JAVoiceReleaseTopicViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) JAHotTopicListView *hotTopicListView;
@property (nonatomic, strong) JASearchTopicTopView *searchTopicTopView;
@property (nonatomic, copy) NSString *keyWord;

@end

@implementation JAVoiceReleaseTopicViewController

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @WeakObj(self);
    self.searchTopicTopView = [[JASearchTopicTopView alloc] initWithFrame:CGRectMake(0, JA_StatusBarHeight, JA_SCREEN_WIDTH, 44)];
    [self.searchTopicTopView.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.searchTopicTopView.searchTextField.delegate = self;
    [self.searchTopicTopView.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.searchTopicTopView];
    
    self.hotTopicListView = [[JAHotTopicListView alloc] initWithFrame:CGRectMake(0, self.searchTopicTopView.bottom, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-JA_StatusBarAndNavigationBarHeight)];
    [self.view addSubview:self.hotTopicListView];
    self.hotTopicListView.tapTopic = ^(JAVoiceTopicModel *topicModel) {
        @StrongObj(self);
        if (self.selectedTopic && topicModel.title.length) {
            self.selectedTopic(topicModel);
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    self.hotTopicListView.hideKeyboard = ^{
        @StrongObj(self);
        [self.view endEditing:YES];
    };
    
    [self setupTableView];
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTableView {
    self.topics = [NSMutableArray new];

    self.tableView = [[UITableView alloc] initWithFrame:self.hotTopicListView.frame style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getSearchTopicListWithLoadMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
}

// 延迟调用接口获取数据
- (void)myDelayedMethod {
    if (self.keyWord.length) {
        [self getSearchTopicListWithLoadMore:NO];
    } else {
        [self.topics removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - Network
- (void)getSearchTopicListWithLoadMore:(BOOL)isLoadMore
{
    if (self.isRequesting) {
        return;
    }
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"title"] = self.keyWord;
    dic[@"type"] = @"topic";
    dic[@"systemType"] = @"2";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAVoiceCommonApi shareInstance] voice_searchWithParas:dic success:^(NSDictionary *result) {
        // 请求成功
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
        
        if (!isLoadMore) {
            [self.topics removeAllObjects];
            
            // 先判断是否符合茉莉话题标准
            NSArray *array = [JADataHelper getRangesForHashtags:[NSString stringWithFormat:@"#%@#",self.keyWord]];
            if (array.count) {
                // 构造新话题
                JAVoiceTopicModel *model = [JAVoiceTopicModel new];
                model.title = [NSString stringWithFormat:@"#%@#", self.keyWord];
                model.localTitle = @"新话题";
                model.localImgName = @"release_newTopic";
                [self.topics addObject:model];
            }
        }
        
        // 解析数据
        JAVoiceTopicGroupModel *groupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicPageList"]];
        if (groupModel.result.count) {
            __block BOOL isMatch = NO;
            [groupModel.result enumerateObjectsUsingBlock:^(JAVoiceTopicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (self.keyWord &&
                    [obj.title isEqualToString:[NSString stringWithFormat:@"#%@#",self.keyWord]]) {
                    isMatch = YES;
                    *stop = YES;
                }
            }];
            if (isMatch) {
                // 完全匹配上搜索结果，移除新建话题
                if (self.topics.count) {
                    JAVoiceTopicModel *model = self.topics.firstObject;
                    if (model) {
                        [self.topics removeObject:model];
                    }
                }
            }
            [self.topics addObjectsFromArray:groupModel.result];
        }
        
        // 判断是否有下一页
        if (groupModel.nextPage != 0 && groupModel.result.count) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error){
        // 请求结束
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topics.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JACommonTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceTopicCellIdentifier];
    if (!cell) {
        cell = [[JACommonTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVoiceTopicCellIdentifier];
    }
    if (indexPath.row < self.topics.count) {
        JAVoiceTopicModel *model = self.topics[indexPath.row];
        cell.model = model;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.topics.count) {
        JAVoiceTopicModel *model = self.topics[indexPath.row];
        if (self.selectedTopic && model.title.length) {
            self.selectedTopic(model);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void) textFieldDidChange:(UITextField *)sender {
    //防止输入拼音状态时查询
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        //获取高亮部分
        UITextRange *selectedRange = [sender markedTextRange];
        UITextPosition *position = [sender positionFromPosition:selectedRange.start offset:0];
        if (position) {
          //有高亮选择的字符串，则暂不对文字进行统计和限制
            return;
        }
    }
    
    self.keyWord = sender.text;
    
    if (self.searchTopicTopView.searchTextField.text.length) {
        self.hotTopicListView.hidden = YES;
        self.tableView.hidden = NO;
    } else {
        self.hotTopicListView.hidden = NO;
        self.tableView.hidden = YES;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:nil];
    [self performSelector:@selector(myDelayedMethod) withObject:nil afterDelay:0.5];
}

@end
