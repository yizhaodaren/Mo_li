//
//  JAGlobalPlayView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAGlobalPlayView.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceCommentGroupModel.h"
#import "JAVoiceCommonApi.h"
#import "JAPlayLoadingView.h"
#import "JAVoicePlayerManager.h"

@interface JAGlobalPlayView ()<JAPlayerDelegate>

@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) UIButton *headButton;
@property (nonatomic, weak) UIProgressView *slider;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isAnonymous;

// v2.5.5
@property (nonatomic, strong) JAPlayLoadingView *playLoadingView;

@end

@implementation JAGlobalPlayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayViewUI];
        self.backgroundColor = [UIColor whiteColor];
        [[JAVoicePlayerManager shareInstance] addDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:JAPlayNotification object:nil];

    }
    return self;
}

- (void)setupPlayViewUI
{
    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _headButton = headButton;
    headButton.layer.cornerRadius = 15;
    headButton.layer.masksToBounds = YES;
    [headButton ja_setImageWithURLStr:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png"];
    [_headButton addTarget:self action:@selector(headAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_headButton];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = playButton;
    [playButton setImage:[UIImage imageNamed:@"branch_gloable_play"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"branch_gloable_play"] forState:UIControlStateHighlighted];
//    [playButton setImage:[UIImage imageNamed:@"branch_gloable_pause"] forState:UIControlStateSelected];
//    [playButton setImage:[UIImage imageNamed:@"branch_gloable_pause"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];
    
    self.playLoadingView = [JAPlayLoadingView playLoadingViewWithType:3];
    self.playLoadingView.centerX = 30/2.0;
    self.playLoadingView.centerY = 30/2.0;
    self.playLoadingView.backgroundColor = HEX_COLOR(JA_Green);

    [self.playButton addSubview:self.playLoadingView];
   
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    _nameLabel.text = @"茉莉";
    nameLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    nameLabel.font = JA_REGULAR_FONT(12);
    nameLabel.userInteractionEnabled = YES;
    [self addSubview:nameLabel];
   
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"听见世界，听见你";
    titleLabel.textColor = HEX_COLOR(0x203F2F);
    titleLabel.font = JA_REGULAR_FONT(12);
    titleLabel.userInteractionEnabled = YES;
    [self addSubview:titleLabel];
    
    [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)]];
    [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)]];
    
    UIProgressView *slider = [[UIProgressView alloc] init];
    _slider = slider;
    slider.trackTintColor = HEX_COLOR(0xF4F4F4);
    slider.progressTintColor = HEX_COLOR(JA_Green);
//    slider.value = 0.5;
//    [slider setThumbImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
//    slider.maximumTrackTintColor = HEX_COLOR(0xF4F4F4);
//    slider.minimumTrackTintColor = HEX_COLOR(JA_Green);
    slider.userInteractionEnabled = NO;
    [self addSubview:slider];
}

- (void)setPlayButtonImage:(BOOL)isSelected {
    if (isSelected) {
        [self.playButton setImage:[UIImage imageNamed:@"branch_gloable_pause"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"branch_gloable_pause"] forState:UIControlStateHighlighted];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"branch_gloable_play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"branch_gloable_play"] forState:UIControlStateHighlighted];
    }
}

- (void)setUserHeadImage:(NSString *)imageName isAnonymous:(BOOL)isAnonymous {
    self.isAnonymous = isAnonymous;
    if (isAnonymous) {
        [self.headButton setImage:[UIImage imageNamed:@"anonymous_head"] forState:UIControlStateNormal];
    } else {
        [self.headButton ja_setImageWithURLStr:imageName];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
   
    self.slider.x = 0;
    self.slider.y = 0;
    self.slider.width = self.width;
    self.slider.height = 3;
    
    self.headButton.x = 15;
    self.headButton.y = 10;
    self.headButton.width = 30;
    self.headButton.height = self.headButton.width;
    
    self.playButton.width = self.headButton.width;
    self.playButton.height = self.playButton.width;
    self.playButton.x = self.width-15-self.playButton.width;
//    self.playButton.y = self.headButton.y;
    self.playButton.centerY = self.headButton.centerY;
    
    self.titleLabel.x = self.headButton.right+10;
    self.titleLabel.y = 10;
    self.titleLabel.width = self.playButton.x-10-self.titleLabel.x;
    self.titleLabel.height = 17;

    self.nameLabel.x = self.titleLabel.x;
    self.nameLabel.y = self.titleLabel.bottom;
    self.nameLabel.width = self.titleLabel.width;
    self.nameLabel.height = 17;
}

- (void)setLayoutY:(CGFloat)layoutY
{
    _layoutY = layoutY;
    
    self.y = layoutY;
}

- (void)showDetail {
    if (self.showVoiceDetail) {
        self.showVoiceDetail();
    }
}

- (void)headAction {
    if (self.isAnonymous) {
        return;
    }
    if (!self.userId.length) {
        return;
    }
    if (self.personalCenter) {
        self.personalCenter(self.userId);
    }
}

- (void)playAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCurrentNotFocusView" object:nil];

    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
    JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
    if (voiceModel) {
        if (voiceModel.playState == 0) {
            // 拉取评论列表
            [JAVoicePlayerManager shareInstance].commentVoices = [NSMutableArray new];
            [self getVoiceCommentListWithTypeId:voiceModel.voiceId];
            
//            [[JAVoicePlayerManager shareInstance] stop];
            voiceModel.playState = 1;
            [[JAVoicePlayerManager shareInstance] setVoiceModel:voiceModel playMethod:0];
         
        } else if (voiceModel.playState == 1) {
            voiceModel.playState = 2;
            [[JAVoicePlayerManager shareInstance] pause];
        } else if (voiceModel.playState == 2) {
            voiceModel.playState = 1;
            [[JAVoicePlayerManager shareInstance] contiunePlay];
        }
    } else if (commentModel) {
        if (commentModel.playState == 0) {
//            [[JAVoicePlayerManager shareInstance] stop];
            
            commentModel.playState = 1;
            [JAVoicePlayerManager shareInstance].commentModel = commentModel;
            
        } else if (commentModel.playState == 1) {
            commentModel.playState = 2;
            [[JAVoicePlayerManager shareInstance] pause];
        } else if (commentModel.playState == 2) {
            commentModel.playState = 1;
            [[JAVoicePlayerManager shareInstance] contiunePlay];
        }
    } else if (replyModel) {
        if (replyModel.playState == 0) {
//            [[JAVoicePlayerManager shareInstance] stop];
            
            replyModel.playState = 1;
            [JAVoicePlayerManager shareInstance].replyModel = replyModel;
            
        } else if (replyModel.playState == 1) {
            replyModel.playState = 2;
            [[JAVoicePlayerManager shareInstance] pause];
        } else if (replyModel.playState == 2) {
            replyModel.playState = 1;
            [[JAVoicePlayerManager shareInstance] contiunePlay];
        }
    } else {
        // 初始化首页数据
//        [[JAVoicePlayerManager shareInstance] stop];
        
        JAVoiceModel *model = [JAVoicePlayerManager shareInstance].voices.firstObject;
        if (model.voiceId.length) {
            [JAVoicePlayerManager shareInstance].isHomeData = YES;
            model.playState = 1;
            [[JAVoicePlayerManager shareInstance] setVoiceModel:model playMethod:0];
            [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
            
            // 拉取评论列表
            [self getVoiceCommentListWithTypeId:model.voiceId];
            [JAVoicePlayerManager shareInstance].commentVoices = [NSMutableArray new];
        }
     }
}

- (void)playNextAction {
    [[JAVoicePlayerManager shareInstance] removePlayNext];
}

// 获取语音评论列表
- (void)getVoiceCommentListWithTypeId:(NSString *)typeId
{
    if (self.isRequesting) {
        return;
    }
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @"6";
    dic[@"type"] = @"story";
    dic[@"typeId"] = typeId;
    dic[@"orderType"] = @"1";
    
    if (IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoiceCommentApi shareInstance] voice_commentListWithParas:dic success:^(NSDictionary *result) {
        self.isRequesting = NO;
        // 解析数据
        JAVoiceCommentGroupModel *groupModel = [JAVoiceCommentGroupModel mj_objectWithKeyValues:result[@"commentPageList"]];
        if (groupModel.result.count) {
            //            [self.commentVoices addObjectsFromArray:groupModel.result];
            
            [JAVoicePlayerManager shareInstance].commentVoices = [groupModel.result mutableCopy];
        }
    } failure:^(NSError *error) {
        self.isRequesting = NO;
    }];
}

#pragma mark -
- (void)playNotification:(NSNotification *)noti {
    [self.playLoadingView setPlayLoadingViewHidden:YES];

    JAVoiceModel *voiceModel = [JAVoicePlayerManager shareInstance].voiceModel;
    JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
    JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
    if (voiceModel) {
        NSString *userName = voiceModel.userName;
        if (voiceModel.isAnonymous) {
            
            userName = voiceModel.anonymousName.length ? voiceModel.anonymousName : @"匿名用户";
        }
        
        if (!userName.length && !voiceModel.content.length) {
            self.nameLabel.text = @"该内容被删除";
        }else{
            [self setUserHeadImage:voiceModel.userImage isAnonymous:voiceModel.isAnonymous];
            self.nameLabel.text = userName;
            self.titleLabel.text = voiceModel.content;
            self.userId = voiceModel.userId;
//            self.nameLabel.text = [NSString stringWithFormat:@"%@：%@",userName,voiceModel.content];
        }
        if (voiceModel.playState == 0) {
            
            
        } else if (voiceModel.playState == 1) {
//            self.playButton.selected = YES;
            [self setPlayButtonImage:YES];
        } else if (voiceModel.playState == 2) {
//            self.playButton.selected = NO;
            [self setPlayButtonImage:NO];
        } else if (voiceModel.playState == 3) {
            [self.playLoadingView setPlayLoadingViewHidden:NO];
        }
    } else if (commentModel) {
        NSString *userName = commentModel.userName;
        if (commentModel.isAnonymous) {
            
            userName = commentModel.anonymousName.length ? commentModel.anonymousName : @"匿名用户";
        }
        //        self.nameLabel.text = [NSString stringWithFormat:@"%@：%@",userName,commentModel.content];
        if (!userName.length && !commentModel.content.length) {
            self.nameLabel.text = @"该内容被删除";
        }else{
            [self setUserHeadImage:commentModel.userImage isAnonymous:commentModel.isAnonymous];
            self.nameLabel.text = userName;
            self.titleLabel.text = commentModel.content;
            self.userId = commentModel.userId;
//            self.nameLabel.text = [NSString stringWithFormat:@"%@：%@",userName,commentModel.content];
        }
        if (commentModel.playState == 1) {
//            self.playButton.selected = YES;
            [self setPlayButtonImage:YES];
        } else if (commentModel.playState == 2) {
//            self.playButton.selected = NO;
            [self setPlayButtonImage:NO];
        } else if (commentModel.playState == 3) {
            [self.playLoadingView setPlayLoadingViewHidden:NO];
        }
    } else if (replyModel) {
        NSString *userName = replyModel.userName;
        if (replyModel.isAnonymous) {
            
            userName = replyModel.userAnonymousName.length ? replyModel.userAnonymousName : @"匿名用户";
        }
        //        self.nameLabel.text = [NSString stringWithFormat:@"%@：%@",userName,replyModel.content];
        if (!userName.length && !replyModel.content.length) {
            self.nameLabel.text = @"该内容被删除";
        }else{
            [self setUserHeadImage:replyModel.userImage isAnonymous:replyModel.isAnonymous];
            self.nameLabel.text = userName;
            self.titleLabel.text = replyModel.content;
            self.userId = replyModel.userId;
//            self.nameLabel.text = [NSString stringWithFormat:@"%@：%@",userName,replyModel.content];
        }
        if (replyModel.playState == 1) {
//            self.playButton.selected = YES;
            [self setPlayButtonImage:YES];
        } else if (replyModel.playState == 2) {
//            self.playButton.selected = NO;
            [self setPlayButtonImage:NO];
        } else if (replyModel.playState == 3) {
            [self.playLoadingView setPlayLoadingViewHidden:NO];
        }
    } else {
        // 试听本地录音时，没有model
        [self setUserHeadImage:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png" isAnonymous:NO];
        self.nameLabel.text = @"茉莉";
        self.titleLabel.text = @"听见世界，听见你";
        self.userId = nil;
        
        self.slider.progress = 0.0;
        [self setPlayButtonImage:NO];
    }
}

#pragma mark - JAPlayerDelegate
- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    self.slider.progress = time/duration;
    [self setPlayButtonImage:YES];
}

- (void)audioPlayerDidPlayFinished {
    self.slider.progress = 0.0;
//    self.playButton.selected = NO;
    [self setPlayButtonImage:NO];
}

@end
