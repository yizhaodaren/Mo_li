//
//  JARichContentTableView.m
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichContentTableView.h"
#import "JARichTextTableViewCell.h"
#import "JARichImageTableViewCell.h"
#import "JARichContentModel.h"
#import "JARichTitleModel.h"
#import "JARichTextModel.h"
#import "JARichImageModel.h"
#import "JAStoryTableViewCell.h"

@interface JARichContentTableView () <
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) BOOL haveImageContent;
@property (nonatomic, weak) UILabel *agreeLabel;
@property (nonatomic, strong) JANewVoiceModel *storyModel;
@property (nonatomic, weak) JAStoryUserView *userView;

@end

@implementation JARichContentTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datas = [NSMutableArray new];
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.scrollEnabled = NO;
        
        // register cell
        [self registerClass:JARichTextTableViewCell.class forCellReuseIdentifier:NSStringFromClass(JARichTextTableViewCell.class)];
        [self registerClass:JARichImageTableViewCell.class forCellReuseIdentifier:NSStringFromClass(JARichImageTableViewCell.class)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 关注通知
- (void)refreshFocusStatusTrue:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.storyModel.user.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.userView.followButton.selected = YES;
    }
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.storyModel.user.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.userView.followButton.selected = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setupData:(JANewVoiceModel *)model {
    _storyModel = model;
    // headerView
    UIView *headerView = [UIView new];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.font = JA_MEDIUM_FONT(22);
    titleLabel.textColor = HEX_COLOR(0x000000);
    [headerView addSubview:titleLabel];
  
    JAStoryUserView *userView = [JAStoryUserView new];
    _userView = userView;
    [userView.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
    [userView.nicknameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
    userView.followButton.hidden = NO;
    [userView.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:userView];
    
    titleLabel.width = JA_SCREEN_WIDTH-30;
    CGFloat titleHeight = 0;
    if (model.title.length) {
        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30, 200);
        CGFloat height = [model.title boundingRectWithSize:maxS
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName : titleLabel.font}
                                                   context:nil].size.height;
        titleHeight = height;
        titleLabel.y = 15;
    } else {
        titleHeight = 0;
        titleLabel.y = 0;
    }
    titleLabel.height = titleHeight;
    titleLabel.x = 15;
    
    userView.width = JA_SCREEN_WIDTH-30;
    userView.height = 40;
    userView.x = 15;
    
    if (model.title.length) {
        userView.y = titleLabel.bottom+20;
    } else {
        userView.y = titleLabel.bottom+15;
    }
    
    headerView.width = JA_SCREEN_WIDTH;
    headerView.height = userView.bottom+15;
    
    titleLabel.text = model.title;

    int h = 40;
    int w = h;
    NSString *url = [model.user.avatar ja_getFitImageStringWidth:w height:h];
    if (model.user.isAnonymous) {
        userView.nicknameLabel.text = model.user.userName;
        userView.headImageView.image = [UIImage imageNamed:@"anonymous_head"];
    } else {
        userView.nicknameLabel.text = model.user.userName;
        [userView.headImageView ja_setImageWithURLStr:url];
    }
    [userView.nicknameLabel sizeToFit];
    
    NSString *city = model.city.length?model.city:@"火星";
    if (!model.createTime.length) {
        userView.locationAndTimeLabel.text = city;
    } else {
        NSString *createTime = [NSString distanceTimeWithBeforeTime:[model.createTime doubleValue]];
        userView.locationAndTimeLabel.text = [NSString stringWithFormat:@"%@ | %@",city,createTime];
    }
    [userView.locationAndTimeLabel sizeToFit];
    
    userView.followButton.selected = ([model.user.friendType integerValue] == 0 || [model.user.friendType integerValue] == 1)?YES:NO;
    if ([[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:model.user.userId]) {
        userView.followButton.hidden = YES;
    } else {
        userView.followButton.hidden = NO;
    }
    
    // 头衔、勋章
    userView.medalMarkView.markString = model.user.crownImage;
    userView.medalMarkView.medalString = model.user.medalUrl;
    
    // 只有圈子详情和帖子详情展示
    userView.circleTagLabel.hidden = NO;
    userView.circleTagLabel.level = model.user.circleLevel;
    userView.circleTagLabel.isCircle = model.user.isCircleAdmin;
    
//    if (model.user.isCircleAdmin) {
//    } else {
//        userView.circleTagLabel.hidden = YES;
//        userView.circleTagLabel.level = model.user.circleLevel;
//        userView.circleTagLabel.isCircle = NO;
//    }
    
    self.tableHeaderView = headerView;
    
    for (NSDictionary *imageText in model.imageText) {
        JARichContentModel *contentModel = [JARichContentModel mj_objectWithKeyValues:imageText];
        if (contentModel.type == 0) {
            // 文本
            JARichTextModel *textModel = [JARichTextModel new];
            textModel.textContent = contentModel.text;

            NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:textModel.textContent];
            [finalStr addAttribute:NSFontAttributeName value:JA_REGULAR_FONT(18) range:NSMakeRange(0, textModel.textContent.length)];
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init]; [paragraphStyle setLineSpacing:6];
            [finalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textModel.textContent length])];
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30, MAXFLOAT);
            CGRect rect = [finalStr boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            textModel.textContentHeight = rect.size.height;
            [self.datas addObject:textModel];
        } else if (contentModel.type == 1) {
            // 图片
            JARichImageModel *imageModel = [JARichImageModel new];
            imageModel.remoteImageUrlString = contentModel.text;
            if (contentModel.width>0 && contentModel.height>0) {
                imageModel.imageSize = CGSizeMake(contentModel.width, contentModel.height);
            }
            // cell 高度
            CGFloat h = imageModel.imageSize.height / (imageModel.imageSize.width / (JA_SCREEN_WIDTH-30));
            imageModel.imageContentHeight = h;
            [self.datas addObject:imageModel];
            
            self.haveImageContent = YES;
        }
    }
    
    UIView *footerView = [UIView new];

    UILabel *playLabel = [UILabel new];
    playLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    playLabel.font = JA_REGULAR_FONT(13);
    [footerView addSubview:playLabel];
    
    UILabel *agreeLabel = [UILabel new];
    _agreeLabel = agreeLabel;
    agreeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    agreeLabel.font = JA_REGULAR_FONT(13);
    [footerView addSubview:agreeLabel];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 10)];
    bottomView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [footerView addSubview:bottomView];
    
    footerView.width = JA_SCREEN_WIDTH;
    footerView.height = 10+13+15+10;
    
    bottomView.bottom = footerView.bottom;
    
    playLabel.width = 80;
    playLabel.height = 13;
    playLabel.left = 15;
    playLabel.bottom = bottomView.top-15;
    
    agreeLabel.width = 80;
    agreeLabel.height = 13;
    agreeLabel.left = playLabel.right+5;
    agreeLabel.bottom = playLabel.bottom;
    
    if (model.storyType == 0) {
        playLabel.text = [NSString stringWithFormat:@"播放 %@",[NSString convertCountStr:model.playCount]];
    } else if (model.storyType == 1) {
        playLabel.text = [NSString stringWithFormat:@"阅读 %@",[NSString convertCountStr:model.playCount]];
    }
    agreeLabel.text = [NSString stringWithFormat:@"喜欢 %@",[NSString convertCountStr:model.agreeCount]];
    
    self.tableFooterView = footerView;

    [self reloadData];
    self.height = self.contentSize.height;
}

- (void)userInfoAction {
    if (self.headActionBlock) {
        self.headActionBlock();
    }
}

- (void)followButtonAction:(UIButton *)sender {
    if (self.followBlock) {
        self.followBlock(sender);
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = _datas[indexPath.row];
    if ([obj isKindOfClass:[JARichTextModel class]]) {
        JARichTextModel* textModel = (JARichTextModel*)obj;
//        if (self.haveImageContent) {
//            return textModel.textContentHeight+30;
//        }
        return textModel.textContentHeight+10;
    } else if ([obj isKindOfClass:[JARichImageModel class]]) {
        JARichImageModel* imageModel = (JARichImageModel*)obj;
        return imageModel.imageContentHeight+10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id obj = _datas[indexPath.row];
    if ([obj isKindOfClass:[JARichTextModel class]]) {
        JARichTextTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JARichTextTableViewCell.class)];
        cell.data = (JARichTextModel *)obj;
        @WeakObj(self);
        cell.atPersonBlock = ^(NSString *userName) {
            @StrongObj(self);
            if (self.atPersonBlock) {
                self.atPersonBlock(userName);
            }
        };
        cell.topicDetailBlock = ^(NSString *topicName) {
            @StrongObj(self);
            if (self.topicDetailBlock) {
                self.topicDetailBlock(topicName);
            }
        };
        return cell;
    }
    if ([obj isKindOfClass:[JARichImageModel class]]) {
        JARichImageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JARichImageTableViewCell.class)];
        cell.data = (JARichImageModel *)obj;
        @WeakObj(self);
        cell.showBigPicture = ^{
            @StrongObj(self);
            if (self.showBigPicture) {
                self.showBigPicture();
            }
        };
        return cell;
    }
    static NSString* cellID = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - 刷新数据
- (void)setRefreshModel:(JANewVoiceModel *)refreshModel
{
    _refreshModel = refreshModel;
    self.agreeLabel.text = [NSString stringWithFormat:@"喜欢 %@",[NSString convertCountStr:refreshModel.agreeCount]];

}
@end

