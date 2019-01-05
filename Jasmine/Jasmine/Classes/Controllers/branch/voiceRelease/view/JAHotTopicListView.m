//
//  JAHotTopicListView.m
//  Jasmine
//
//  Created by xujin on 23/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAHotTopicListView.h"
#import "JACommonTopicCell.h"
#import "JATopicApi.h"
#import "JAVoiceTopicGroupModel.h"

static NSString *const kVoiceTopicCellIdentifier = @"JAVoiceTopicCellIdentifier";

@interface JAHotTopicListView ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *topics;

@end

@implementation JAHotTopicListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.topics = [NSMutableArray new];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        //    self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        //    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        [self addSubview:self.tableView];
        @WeakObj(self);
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @StrongObj(self)
            [self getTopicListWithLoadMore:YES];
        }];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40)];
        headerView.backgroundColor = HEX_COLOR(0xF9F9F9);
        self.tableView.tableHeaderView = headerView;
        UIImageView *iconIV = [UIImageView new];
        iconIV.image = [UIImage imageNamed:@"branch_topic_icon"];
        [headerView addSubview:iconIV];
        [iconIV sizeToFit];
        iconIV.x = 12;
        iconIV.centerY = headerView.height/2.0;
        
        UILabel *titleL = [UILabel new];
        titleL.font = JA_REGULAR_FONT(14);
        titleL.textColor = HEX_COLOR(0x525252);
        titleL.text = @"热门话题";
        [headerView addSubview:titleL];
        [titleL sizeToFit];
        titleL.x = iconIV.right+5;
        titleL.centerY = iconIV.centerY;
        
        [self getTopicListWithLoadMore:NO];
    }
    return self;
}

#pragma mark - Network
- (void)getTopicListWithLoadMore:(BOOL)isLoadMore {
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"1";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    if(IS_LOGIN) dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JATopicApi shareInstance] topic_recommendTopic:dic success:^(NSDictionary *result) {
        [self.tableView.mj_footer endRefreshing];
        // 解析数据
        JAVoiceTopicGroupModel *groupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicList"]];
        if (!isLoadMore) {
            [self.topics removeAllObjects];
        }
        if (groupModel.result.count) {
            [self.topics addObjectsFromArray:groupModel.result];
            
            if (!isLoadMore) {
                NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
                NSFileManager *filemanager = [NSFileManager new];
                if (![filemanager fileExistsAtPath:dictionaryPath]) {
                    [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData/hotTopic.data"];
                [NSKeyedArchiver archiveRootObject:groupModel toFile:filepath];
            }
        }
        if (groupModel.nextPage != 0 && groupModel.result.count) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
    } failure:^{
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
        if (self.tapTopic) {
            self.tapTopic(model);
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.hideKeyboard) {
        self.hideKeyboard();
    }
}

@end
