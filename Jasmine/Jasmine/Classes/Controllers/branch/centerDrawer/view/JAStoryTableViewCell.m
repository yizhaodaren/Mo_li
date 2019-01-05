//
//  JAStoryTableViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTableViewCell.h"
#import "KILabel.h"
#import "UIView+JACategory.h"
#import "JAStoryVoiceView.h"
#import "JANewPlayTool.h"
#import "KNPhotoBrower.h"
#import "JACommonHelper.h"

@implementation JAStoryUserView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImageView *headImageView = [UIImageView new];
        headImageView.layer.cornerRadius = 40/2.0;
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
        headImageView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
        headImageView.userInteractionEnabled = YES;
        [self addSubview:headImageView];
        self.headImageView = headImageView;
        
        UILabel *nicknameLabel = [UILabel new];
        nicknameLabel.textColor = HEX_COLOR(0x576B95);
        nicknameLabel.font = JA_REGULAR_FONT(15);
        nicknameLabel.userInteractionEnabled = YES;
        [self addSubview:nicknameLabel];
        self.nicknameLabel = nicknameLabel;
        
        // 头衔、勋章
        JAMedalMarkView *medalMarkView = [[JAMedalMarkView alloc] init];
        _medalMarkView = medalMarkView;
        [self addSubview:medalMarkView];
        
        // 圈主标签
        JAPersonTagView *circleTagLabel = [[JAPersonTagView alloc] init];
        _circleTagLabel = circleTagLabel;
        circleTagLabel.type = 1;
        [self addSubview:circleTagLabel];

        UILabel *locationAndTimeLabel = [UILabel new];
        locationAndTimeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        locationAndTimeLabel.font = JA_REGULAR_FONT(12);
        [self addSubview:locationAndTimeLabel];
        self.locationAndTimeLabel = locationAndTimeLabel;
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        moreButton.backgroundColor = [UIColor redColor];
        [moreButton setImage:[UIImage imageNamed:@"recommend_more"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"recommend_more"] forState:UIControlStateHighlighted];
        moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        moreButton.hidden = YES;
        [self addSubview:moreButton];
        self.moreButton = moreButton;
        
        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followButton setImage:[UIImage imageNamed:@"detail_follow"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"detail_follow"] forState:UIControlStateHighlighted];
        [followButton setImage:[UIImage imageNamed:@"detail_followed"] forState:UIControlStateSelected];
        [followButton setImage:[UIImage imageNamed:@"detail_followed"] forState:UIControlStateSelected|UIControlStateHighlighted];
        followButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        followButton.hidden = YES;
        [self addSubview:followButton];
        self.followButton = followButton;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImageView.width = self.headImageView.height = 40;
    
    [self.nicknameLabel sizeToFit];
    if (self.nicknameLabel.width > JA_SCREEN_WIDTH * 0.75) {
        self.nicknameLabel.width = JA_SCREEN_WIDTH * 0.75;
    }
//    self.nicknameLabel.width = self.width-15-50;
    self.nicknameLabel.height = 21;
    self.nicknameLabel.left = self.headImageView.right+10;
    self.nicknameLabel.top = self.headImageView.top;
   
    [self.medalMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nicknameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.nicknameLabel.mas_centerY).offset(0);
    }];
    
    [self.circleTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.medalMarkView.mas_right).offset(5);
        make.centerY.equalTo(self.medalMarkView.mas_centerY).offset(0);
    }];
    
    self.moreButton.width = self.moreButton.height = 20;
    self.moreButton.right = self.width-15;
    self.moreButton.centerY = self.headImageView.centerY;

    self.followButton.width = 50;
    self.followButton.height = 23;
    self.followButton.right = self.width-15;
    self.followButton.centerY = self.headImageView.centerY;
    
    self.locationAndTimeLabel.width = self.followButton.x - self.nicknameLabel.left;
    self.locationAndTimeLabel.height = 12;
    self.locationAndTimeLabel.left = self.nicknameLabel.left;
    self.locationAndTimeLabel.bottom = self.headImageView.bottom;
}

@end

@implementation JAStoryToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        JAEmitterView *agreeButton = [JAEmitterView buttonWithType:UIButtonTypeCustom];
        [agreeButton setImage:[UIImage imageNamed:@"recommend_agree_nor"] forState:UIControlStateNormal];
        [agreeButton setImage:[UIImage imageNamed:@"recommend_agree_nor"] forState:UIControlStateHighlighted];
        [agreeButton setImage:[UIImage imageNamed:@"recommend_agree_sel"] forState:UIControlStateSelected];
        [agreeButton setImage:[UIImage imageNamed:@"recommend_agree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
        agreeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -30);
        [self addSubview:agreeButton];
        self.agreeButton = agreeButton;
        
        UILabel *agreeLabel = [UILabel new];
        agreeLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        agreeLabel.font = JA_REGULAR_FONT(13);
        agreeLabel.text = @"0";
        [self insertSubview:agreeLabel belowSubview:self.agreeButton];
        self.agreeLabel = agreeLabel;
        
        // 在禁掉点赞button的时候，防止继续点击进入详情
        UIButton *zanBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self insertSubview:zanBgButton belowSubview:self.agreeButton];
        self.zanBgButton = zanBgButton;
        
        UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentButton setImage:[UIImage imageNamed:@"recommend_comment"] forState:UIControlStateNormal];
        [commentButton setImage:[UIImage imageNamed:@"recommend_comment"] forState:UIControlStateHighlighted];
        commentButton.userInteractionEnabled = NO;
        [self addSubview:commentButton];
        self.commentButton = commentButton;
        
        UILabel *commentLabel = [UILabel new];
        commentLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        commentLabel.font = JA_REGULAR_FONT(13);
        commentLabel.text = @"0";
        [self addSubview:commentLabel];
        self.commentLabel = commentLabel;
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"recommend_share"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"recommend_share"] forState:UIControlStateHighlighted];
        [self addSubview:shareButton];
        shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -50);
        self.shareButton = shareButton;

        UILabel *shareLabel = [UILabel new];
        shareLabel.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        shareLabel.font = JA_REGULAR_FONT(13);
        shareLabel.text = @"0";
        [self addSubview:shareLabel];
        self.shareLabel = shareLabel;
        
        UIButton *circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        circleButton.titleLabel.font = JA_REGULAR_FONT(12);
        circleButton.backgroundColor = HEX_COLOR(JA_BlackSubSubTitle);
        circleButton.layer.cornerRadius = 10;
        circleButton.layer.masksToBounds = YES;
        [circleButton setTitle:@"" forState:UIControlStateNormal];
        [self addSubview:circleButton];
        self.circleButton = circleButton;
        self.circleButton.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.agreeButton.width = 20;
    self.agreeButton.height = 18;
    
    self.zanBgButton.frame = self.agreeButton.frame;
    
    self.agreeLabel.width = 40;
    self.agreeLabel.height = 13;
    self.agreeLabel.centerY = self.agreeButton.centerY;
    self.agreeLabel.left = self.agreeButton.right+5;
    
    self.commentButton.width = 20;
    self.commentButton.height = 18;
    self.commentButton.centerY = self.agreeButton.centerY;
    self.commentButton.left = self.agreeButton.right+50;
    
    self.commentLabel.width = 40;
    self.commentLabel.height = 13;
    self.commentLabel.centerY = self.agreeButton.centerY;
    self.commentLabel.left = self.commentButton.right+5;
    
    self.shareButton.width = 20;
    self.shareButton.height = 18;
    self.shareButton.centerY = self.agreeButton.centerY;
    self.shareButton.left = self.commentButton.right+50;
    
    self.shareLabel.width = 40;
    self.shareLabel.height = 13;
    self.shareLabel.centerY = self.agreeButton.centerY;
    self.shareLabel.left = self.shareButton.right+5;
    
    if (self.circleButton.width > 100) {
        self.circleButton.width = 100;
    }
    self.circleButton.height = 20;
    self.circleButton.right = self.width;
    self.circleButton.centerY = self.agreeButton.centerY;
}

@end

@interface JAStoryImageView : UIView

@property (nonatomic, assign) CGSize *imageSize;
@property (nonatomic, strong) NSMutableArray *imageViews;

- (void)setImages:(NSArray *)images;
@end

@implementation JAStoryImageView

- (instancetype)initWithImageCount:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.imageViews = [NSMutableArray new];
        
        CGFloat lastX = 0;
        NSInteger itemCount = count>1?3:1; // 图片个数大于一，创建三个控件
        for (int i=0; i<itemCount; i++) {
            UIImageView *imageView = [UIImageView new];
            imageView.clipsToBounds = YES;
            imageView.tag = i;
            imageView.hidden = YES;
            imageView.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
            imageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
            imageView.layer.cornerRadius = 3;

//            [self addShapeLayer:imageView];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            if (count == 1) {
                imageView.frame = CGRectMake(lastX, 0, 50, 50);
            } else {
                CGFloat imageW = (JA_SCREEN_WIDTH-15*2-WIDTH_ADAPTER(3)*2)/3.0;
                CGFloat imageH = imageW;
                imageView.frame = CGRectMake(lastX, 0, imageW, imageH);
                lastX = imageView.right+WIDTH_ADAPTER(3);
            }
        }
    }
    return self;
}

- (void)setImages:(NSArray *)images {
    if (images.count) {
        for (int i=0; i<self.imageViews.count; i++) {
            UIImageView *imageView = self.imageViews[i];
            if (i <= images.count-1) {
                imageView.hidden = NO;
                JAVoicePhoto *photo = images[i];
                if (images.count == 1) {
                    CGSize imageSize = CGSizeMake(photo.width, photo.height);
                    CGSize newSize = [JACommonHelper getListImageSize:imageSize];
                    CGFloat imageW = newSize.width;
                    CGFloat imageH = newSize.height;
                    NSString *url = [photo.src ja_getFillImageStringWidth:imageW height:imageH];
                    [imageView ja_setImageWithURLStr:url];
                    imageView.width = imageW;
                    imageView.height = imageH;
                } else {
                    CGFloat imageW = (JA_SCREEN_WIDTH-15*2-WIDTH_ADAPTER(3)*2)/3.0;
                    CGFloat imageH = imageW;
                    NSString *url = [photo.src ja_getFillImageStringWidth:imageW height:imageH];
                    [imageView ja_setImageWithURLStr:url];
                }
            } else {
                imageView.hidden = YES;
                imageView.image = nil;
            }
        }
    }
}

- (void)addShapeLayer:(UIView *)view {
    CAShapeLayer *border = [CAShapeLayer layer];
    border.fillColor = [UIColor clearColor].CGColor;
    border.lineWidth = 2.f;
    border.strokeColor = HEX_COLOR(0xF9F9F9).CGColor;
    border.lineCap = kCALineCapRound;
    border.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius].CGPath;
    [view.layer addSublayer:border];
}

@end

@interface JAStoryTableViewCell ()<JAEmitterViewDelegate, KNPhotoBrowerDelegate>

@property (nonatomic, strong) UIImageView *leftImageView; // 左上角的精帖
@property (nonatomic, strong) JAStoryVoiceView *voiceContentView;
@property (nonatomic, strong) JAStoryImageView *imageContentView;
@property (nonatomic, strong) KILabel *desLabel; // 绘制的原因不能使用sizetofit计算高度
@property (nonatomic, strong) KILabel *sub_desLabel; // 绘制的原因不能使用sizetofit计算高度
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) NSTimeInterval frontTime;
@property (nonatomic, strong) NSString *agreeMethod;
@property (nonatomic, assign) BOOL isDetail;
@property (nonatomic, strong) UILabel *playLabel;
@property (nonatomic, strong) UILabel *agreeLabel;

@end

@implementation JAStoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellType:(NSInteger)cellType imageCount:(NSInteger)imageCount {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier cellType:cellType imageCount:imageCount isDetail:NO];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     cellType:(NSInteger)cellType
                   imageCount:(NSInteger)imageCount
                     isDetail:(BOOL)isDetail {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isDetail = isDetail;
        
//        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jinghua"]];
//        [self.contentView addSubview:leftImageView];
//        self.leftImageView = leftImageView;
        
        // 头部栏
        JAStoryUserView *userView = [JAStoryUserView new];
        [userView.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
        [userView.nicknameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoAction)]];
        if (isDetail) {
            userView.followButton.hidden = NO;
            [userView.followButton addTarget:self action:@selector(followButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusTrue:) name:@"searchRefreshFocusStatusTrue" object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFocusStatusFalse:) name:@"searchRefreshFocusStatusFalse" object:nil];
        } else {
            userView.moreButton.hidden = NO;
            [userView.moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.contentView addSubview:userView];
//        userView.backgroundColor = [UIColor greenColor];
        self.userContentView = userView;
        
        // 内容区：文字、语音、图片
        KILabel *desLabel = [KILabel new];
        desLabel.textColor = HEX_COLOR(0x000000);
        desLabel.font = JA_REGULAR_FONT(18);
        desLabel.numberOfLines = 0;
        desLabel.linkDetectionTypes = KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
        [desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
        [desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
        @WeakObj(self);
        desLabel.hashtagLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (string.length) {
                if (self.topicDetailBlock) {
                    self.topicDetailBlock(string);
                }
            }
        };
        desLabel.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (self.atPersonBlock) {
                self.atPersonBlock(string, self.data.atList);
            }
        };
        [self.contentView addSubview:desLabel];
        self.desLabel = desLabel;
        
        // v3.1 - 描述
        KILabel *sub_desLabel = [KILabel new];
        sub_desLabel.textColor = HEX_COLOR(0x545454);
        sub_desLabel.font = JA_REGULAR_FONT(16);
        sub_desLabel.linkDetectionTypes = KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
        [sub_desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
        [sub_desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
        
        sub_desLabel.hashtagLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (string.length) {
                if (self.topicDetailBlock) {
                    self.topicDetailBlock(string);
                }
            }
        };
        desLabel.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (self.atPersonBlock) {
                self.atPersonBlock(string, self.data.atList);
            }
        };
        [self.contentView addSubview:sub_desLabel];
        self.sub_desLabel = sub_desLabel;
        
        UIImageView *iconImageView = [UIImageView new];
        iconImageView.image = [UIImage imageNamed:@"circle_jinghua"];
        iconImageView.hidden = YES;
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        if (cellType == VoiceNoImageCellType ||
            cellType == VoiceAndSingleImageCellType ||
            cellType == VoiceAndMuliImageCellType) {
            JAStoryVoiceView *voiceView = [JAStoryVoiceView new];
//            [voiceView.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
            UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAction)];
            [voiceView addGestureRecognizer:playTap];
            [self.contentView addSubview:voiceView];
            self.voiceContentView = voiceView;
        }
        
        if (imageCount>0) {
            JAStoryImageView *imageView = [[JAStoryImageView alloc] initWithImageCount:imageCount];
//            imageView.backgroundColor = [UIColor cyanColor];
            [self.contentView addSubview:imageView];
            if (isDetail) {
                for (UIImageView *iv in imageView.imageViews) {
                    iv.userInteractionEnabled = YES;
                    [iv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPicture:)]];
                }                
            }
            self.imageContentView = imageView;
        }
        
        // 底部栏
        if (isDetail) {
            UILabel *playLabel = [UILabel new];
            playLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
            playLabel.font = JA_REGULAR_FONT(13);
            [self.contentView addSubview:playLabel];
            self.playLabel = playLabel;

            UILabel *agreeLabel = [UILabel new];
            agreeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
            agreeLabel.font = JA_REGULAR_FONT(13);
            [self.contentView addSubview:agreeLabel];
            self.agreeLabel = agreeLabel;
            
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 10)];
            bottomView.backgroundColor = HEX_COLOR(0xF4F4F4);
            [self.contentView addSubview:bottomView];
            self.bottomView = bottomView;
        } else {
            JAStoryToolView *toolView = [JAStoryToolView new];
//            [toolView.commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
            [toolView.shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
            [toolView.circleButton addTarget:self action:@selector(circleAction) forControlEvents:UIControlEventTouchUpInside];
            toolView.agreeButton.delegate = self;
            [self.contentView addSubview:toolView];
//            toolView.backgroundColor = [UIColor redColor];
            self.toolView = toolView;
    
            // 虚线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
            [self.contentView addSubview:lineView];
            self.lineView = lineView;
            [UIView drawLineOfDashByCAShapeLayer:self.lineView lineLength:3 lineSpacing:2 lineColor:HEX_COLOR(JA_Line) lineDirection:YES];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshUI) name:@"STKAudioPlayer_status" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayer_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayer_finish" object:nil];
    }
    return self;
}

#pragma mark - 关注通知
- (void)refreshFocusStatusTrue:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.data.user.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.userContentView.followButton.selected = YES;
    }
}

- (void)refreshFocusStatusFalse:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *userId = dic[@"id"];
    NSString *modelUserId = self.data.user.userId;
    if ([userId isEqualToString:modelUserId]) {
        self.userContentView.followButton.selected = NO;
    }
}

#pragma mark - 波形图通知
- (void)playStatus_refreshUI   // 状态变化
{
    [self updatePlayButtonUI];
}

- (void)updatePlayButtonUI {
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:self.data.storyId]) {
        NSInteger status = [JANewPlayTool shareNewPlayTool].playType;
        if (status == 0) {
            self.voiceContentView.playButton.selected = NO;
            [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:YES];
        }else if (status == 1){
            self.voiceContentView.playButton.selected = YES;
            [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:YES];
        }else if (status == 2){
            self.voiceContentView.playButton.selected = NO;
            [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:YES];
        }else if (status == 3){
            [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:NO];
        }
    }else{
        self.voiceContentView.playButton.selected = NO;
        [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:YES];
    }
}

- (void)playProcess_refreshUI  // 进度
{
    if ([JANewPlayTool shareNewPlayTool].totalDuration <= 0) {
        return;
    }
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:self.data.storyId]) {
        CGFloat p = [JANewPlayTool shareNewPlayTool].currentDuration / [JANewPlayTool shareNewPlayTool].totalDuration;

        [self.voiceContentView.waveView wave_animateWithTotalArray:self.data.allPeakLevelQueue progress:p];
        NSTimeInterval curDuration = [NSString getSeconds:self.data.time] - [JANewPlayTool shareNewPlayTool].currentDuration;
        if (curDuration > 0) {
            self.voiceContentView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
        }
    }else{
        [self.voiceContentView.waveView wave_animateWithTotalArray:self.data.allPeakLevelQueue progress:0];
        self.voiceContentView.durationLabel.text = [NSString getStoryVoiceShowTime:self.data.time];
    }
    
}

- (void)playFinish_refreshUI   // 完成
{
    // 重置波形图
    [self.voiceContentView.waveView wave_animateWithTotalArray:self.data.allPeakLevelQueue progress:0];
    self.voiceContentView.playButton.selected = NO;
    [self.voiceContentView.playLoadingView setPlayLoadingViewHidden:YES];
    self.voiceContentView.durationLabel.text = [NSString getStoryVoiceShowTime:self.data.time];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat leftMargin = 15;
    CGFloat contentW = JA_SCREEN_WIDTH-30;
    self.userContentView.width = JA_SCREEN_WIDTH-15;
    self.userContentView.height = 40;
    self.userContentView.x = leftMargin;
    self.userContentView.y = 20;
    
    self.desLabel.width = contentW;
    self.desLabel.x = leftMargin;
    self.desLabel.y = self.userContentView.bottom+15;
    
    self.sub_desLabel.width = contentW;
    self.sub_desLabel.height = 20;
    self.sub_desLabel.x = leftMargin;
    self.sub_desLabel.y = self.desLabel.bottom+10;
    
    self.iconImageView.x = self.desLabel.x;
    self.iconImageView.y = self.desLabel.y+2;
    self.iconImageView.width = self.iconImageView.height = 18;
    
    self.voiceContentView.width = contentW;
    self.voiceContentView.height = 50;
    self.voiceContentView.x = leftMargin;
    self.voiceContentView.y = self.desLabel.bottom+15;
    
    self.imageContentView.width = contentW;
    self.imageContentView.x = leftMargin;
    if (self.voiceContentView) {
        self.imageContentView.y = self.voiceContentView.bottom+15;
    } else {
        self.imageContentView.y = (self.data.title.length && self.data.content.length) ? self.sub_desLabel.bottom + 10 : self.desLabel.bottom+15;
    }
    
    if (self.isDetail) {
        self.bottomView.bottom = self.contentView.bottom;

        self.playLabel.width = 80;
        self.playLabel.height = 13;
        self.playLabel.left = self.userContentView.left;
        self.playLabel.bottom = self.bottomView.top-20;
        
        self.agreeLabel.width = 80;
        self.agreeLabel.height = 13;
        self.agreeLabel.left = self.playLabel.right+5;
        self.agreeLabel.bottom = self.playLabel.bottom;
    } else {
        self.toolView.width = JA_SCREEN_WIDTH-30;
        self.toolView.height = 20;
        self.toolView.x = 15;

        CGFloat toolViewY = (self.data.title.length && self.data.content.length) ? self.sub_desLabel.bottom + 10 : self.desLabel.bottom+15;
        if (self.voiceContentView) {
            toolViewY = self.voiceContentView.bottom+15;
        }
        if (self.imageContentView) {
            toolViewY = self.imageContentView.bottom+15;
        }
        self.toolView.y = toolViewY;
        self.lineView.bottom = self.contentView.bottom;
    }
}

- (void)setData:(JANewVoiceModel *)data {
    _data = data;
    
    if (data) {
        if (data.essence) {
            self.leftImageView.hidden = NO;
        }else{
            self.leftImageView.hidden = YES;
        }
        int h = 40;
        int w = h;
        if ([data.concernType integerValue] == 0) {
            NSString *url = [data.user.avatar ja_getFitImageStringWidth:w height:h];
            if (data.user.isAnonymous) {
                self.userContentView.nicknameLabel.text = data.user.userName;
                self.userContentView.headImageView.image = [UIImage imageNamed:@"anonymous_head"];
                self.voiceContentView.headImageView.image = [UIImage imageNamed:@"anonymous_head"];
            } else {
                self.userContentView.nicknameLabel.text = data.user.userName;
                [self.userContentView.headImageView ja_setImageWithURLStr:url];
                [self.voiceContentView.headImageView ja_setImageWithURLStr:url];
            }
            self.userContentView.headImageView.layer.cornerRadius = 40/2.0;
            
            // 头衔、勋章
            self.userContentView.medalMarkView.medalString = data.user.medalUrl;
            self.userContentView.medalMarkView.markString = data.user.crownImage;
            
        } else if ([data.concernType integerValue] == 1) {
            NSString *url = [data.circle.circleThumb ja_getFitImageStringWidth:w height:h];
            [self.userContentView.headImageView ja_setImageWithURLStr:url];
            [self.voiceContentView.headImageView ja_setImageWithURLStr:url];
            NSString *paddingString = @"有了新的精华帖";
            NSString *circleTitle = [NSString stringWithFormat:@"%@ %@", data.circle.circleName, paddingString];
            NSRange range = [circleTitle rangeOfString:paddingString];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:circleTitle];
            [attributedStr addAttribute:NSForegroundColorAttributeName
                                  value:HEX_COLOR(0x363636)
                                  range:NSMakeRange(range.location, range.length)];
            self.userContentView.nicknameLabel.attributedText = attributedStr;
            self.userContentView.headImageView.layer.cornerRadius = 4;
            
            // 头衔、勋章
            self.userContentView.medalMarkView.medalString = @"";
            self.userContentView.medalMarkView.markString = @"";
        }
        [self.userContentView.nicknameLabel sizeToFit];
        
        if (self.userContentView.moreButton.hidden) {
            // 详情页才有关注按钮
            self.userContentView.followButton.selected = ([data.user.friendType integerValue] == 0 || [data.user.friendType integerValue] == 1)?YES:NO;
            if ([[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:data.user.userId]) {
                self.userContentView.followButton.hidden = YES;
            } else {
                self.userContentView.followButton.hidden = NO;
            }
        }
        
        // 内容
        if (data.storyType == 1 && data.title.length) {
            self.sub_desLabel.text = data.content;
            self.sub_desLabel.hidden = NO;
        }else{
            self.sub_desLabel.hidden = YES;
        }
        
        if (data.storyType == 0) {
            self.voiceContentView.durationLabel.text = [NSString getStoryVoiceShowTime:data.time];
            // 获取点的数组
#warning TODO:
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            // 波形图
            if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:data.storyId]) {
                if ([JANewPlayTool shareNewPlayTool].totalDuration > 0) {
                    
                    CGFloat p = [JANewPlayTool shareNewPlayTool].currentDuration / [JANewPlayTool shareNewPlayTool].totalDuration;
                    [self.voiceContentView.waveView wave_animateWithTotalArray:data.allPeakLevelQueue progress:p];
                    NSTimeInterval curDuration = [NSString getSeconds:self.data.time] - [JANewPlayTool shareNewPlayTool].currentDuration;
                    if (curDuration > 0) {
                        self.voiceContentView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)curDuration/60,(int)curDuration%60];
                    }
                }else{
                    [self.voiceContentView.waveView wave_animateWithTotalArray:data.allPeakLevelQueue progress:0];
                    self.voiceContentView.durationLabel.text = [NSString getStoryVoiceShowTime:data.time];
                }
            }else{
                [self.voiceContentView.waveView wave_animateWithTotalArray:data.allPeakLevelQueue progress:0];
                self.voiceContentView.durationLabel.text = [NSString getStoryVoiceShowTime:data.time];
            }
        }
        // 播放按钮
        [self updatePlayButtonUI];

        if (data.photos.count) {
            [self.imageContentView setImages:[data.photos copy]];
            self.imageContentView.height = data.imageViewSize.height;
        }
     
        if (self.isDetail) {
            if (data.storyType == 0) {
                self.playLabel.text = [NSString stringWithFormat:@"播放 %@",[NSString convertCountStr:data.playCount]];
            } else if (data.storyType == 1) {
                self.playLabel.text = [NSString stringWithFormat:@"阅读 %@",[NSString convertCountStr:data.playCount]];
            }
            self.agreeLabel.text = [NSString stringWithFormat:@"喜欢 %@",[NSString convertCountStr:data.agreeCount]];
        } else {
            self.toolView.agreeLabel.text = [NSString convertCountStr:data.agreeCount];
            self.toolView.commentLabel.text = [NSString convertCountStr:data.commentCount];
            self.toolView.shareLabel.text = [NSString convertCountStr:data.shareCount];
        
            self.toolView.agreeButton.selected = data.isAgree;
            self.lastAgreeState = self.toolView.agreeButton.selected;
        }
    }
}

#pragma mark - JAEmitterViewDelegate
- (void)emitterViewClickSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    if (button.selected) {
        
        if ([self checkTimeMargin]) {
            [self agreeAction:button];
        }
    }else{
        
        [self agreeAction:button];
    }
}

// 判断时间间隔是否大于1.3
- (BOOL)checkTimeMargin
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    if (interval - self.frontTime > 1300) {
        
        self.frontTime = interval;
        return YES;
    }
    self.frontTime = interval;
    return NO;
}

- (void)emitterViewClickLongSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    if (!button.selected) {
        [self agreeAction:button];
    }
}

// 单击点赞
- (void)agreeAction:(UIButton *)sender {
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    sender.selected = !sender.selected;
    NSInteger agreeCount = [self.data.agreeCount integerValue];
    if (sender.selected) {
        self.data.agreeCount = [NSString stringWithFormat:@"%zd",++agreeCount];
        self.agreeMethod = @"点击按钮喜欢";
    } else {
        self.data.agreeCount = [NSString stringWithFormat:@"%zd",--agreeCount];
    }
    self.toolView.agreeLabel.text = [NSString convertCountStr:self.data.agreeCount];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
}

- (void)myDelayedMethod {
    if (self.toolView.agreeButton.selected != self.lastAgreeState) {
        self.lastAgreeState = self.toolView.agreeButton.selected;
        self.data.isAgree = self.toolView.agreeButton.selected;
        if (self.agreeBlock) {
            self.agreeBlock(self);
        }
        
        // 神策数据
        if (self.toolView.agreeButton.selected) {
            [self sensorsAnalyticsWithLikeType:JA_STORY_TYPE model:self.data method:self.agreeMethod];
        }
    }
}

// 神策数据
- (void)sensorsAnalyticsWithLikeType:(NSString *)type model:(id)model method:(NSString *)method
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    
    if ([type isEqualToString:JA_STORY_TYPE]) {
        
        JANewVoiceModel *voiceM = (JANewVoiceModel *)model;
        // 计算时间
        NSArray *timeArr = [voiceM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = voiceM.storyId;
        senDic[JA_Property_ContentTitle] = voiceM.content;
        senDic[JA_Property_ContentType] = @"主帖";
        senDic[JA_Property_Anonymous] = @(voiceM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = voiceM.user.userId;
        senDic[JA_Property_PostName] = voiceM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
        senDic[JA_Property_SourcePage] = voiceM.sourceName;
        senDic[JA_Property_RecommendType] = voiceM.recommendType;
        
    }else if([type isEqualToString:JA_COMMENT_TYPE]){
        
        JANewCommentModel *commentM = (JANewCommentModel *)model;
        // 计算时间
        NSArray *timeArr = [commentM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = commentM.commentId;
        senDic[JA_Property_ContentTitle] = commentM.content;
        senDic[JA_Property_ContentType] = @"一级回复";
        senDic[JA_Property_Anonymous] = @(commentM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = commentM.user.userId;
        senDic[JA_Property_PostName] = commentM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
//        senDic[JA_Property_SourcePage] = commentM.sourceName;
//        senDic[JA_Property_RecommendType] = commentM.recommendType;
        
    }else if ([type isEqualToString:JA_REPLY_TYPE]){
        
        JANewReplyModel *replyM = (JANewReplyModel *)model;
        // 计算时间
        NSArray *timeArr = [replyM.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        
        senDic[JA_Property_ContentId] = replyM.replyId;
        senDic[JA_Property_ContentTitle] = replyM.content;
        senDic[JA_Property_ContentType] = @"二级回复";
        senDic[JA_Property_Anonymous] = @(replyM.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = replyM.user.userId;
        senDic[JA_Property_PostName] = replyM.user.userName;
        senDic[JA_Property_LikeMethod] = method;
//        senDic[JA_Property_SourcePage] = replyM.sourceName;
//        senDic[JA_Property_RecommendType] = replyM.recommendType;
    }
    [JASensorsAnalyticsManager sensorsAnalytics_clickAgree:senDic];
}

#pragma mark - PrivateMethod
- (void)userInfoAction {
    if (self.headActionBlock) {
        self.headActionBlock(self);
    }
}

- (void)followButtonAction {
    if (self.followBlock) {
        self.followBlock(self);
    }
}

- (void)moreButtonAction {
    if (self.moreBlock) {
        self.moreBlock(self);
    }
}

- (void)playAction {
    if (self.playBlock) {
        self.playBlock(self);
    }
}

//- (void)commentAction {
//    if (self.commentBlock) {
//        self.commentBlock(self);
//    }
//}

- (void)shareAction {
    if (self.shareBlock) {
        self.shareBlock(self);
    }
}

- (void)circleAction {
    if (self.circleBlock) {
        self.circleBlock(self);
    }
}

- (void)showBigPicture:(UIGestureRecognizer *)tap
{
    UIImageView *imageV = (UIImageView *)tap.view;
    NSMutableArray *arrM = [NSMutableArray array];
    // 查看大图
    for (NSInteger i = 0; i < self.data.photos.count; i++) {
        JAVoicePhoto *photo = self.data.photos[i];
        KNPhotoItems *items = [[KNPhotoItems alloc] init];
        items.url = photo.src;
        [arrM addObject:items];
    }
    
    KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
        photoBrower.actionSheetArr =  [@[@"删除",@"保存"] copy];
    }else{
        photoBrower.actionSheetArr =  [@[@"保存"] copy];
    }
    [photoBrower setIsNeedRightTopBtn:YES];
    [photoBrower setIsNeedPictureLongPress:YES];
    photoBrower.itemsArr = [arrM copy];
    photoBrower.currentIndex = imageV.tag;
    [photoBrower present];
    [photoBrower setDelegate:self];
}


#pragma mark - PublicMethods
// 隐藏时间
- (void)hideTimeLabel:(BOOL)hidden {
    NSString *city = self.data.city.length?self.data.city:@"火星";
    if (hidden || !self.data.createTime.length) {
        self.userContentView.locationAndTimeLabel.text = city;
    } else {
        NSString *createTime = [NSString distanceTimeWithBeforeTime:[self.data.createTime doubleValue]];
        self.userContentView.locationAndTimeLabel.text = [NSString stringWithFormat:@"%@ | %@",city,createTime];
    }
    [self.userContentView.locationAndTimeLabel sizeToFit];
}

- (void)hideCircleView:(BOOL)hidden {
    if (hidden) {
        self.toolView.circleButton.hidden = YES;
    } else {
        if (self.data.circle.circleId.length && self.data.circle.circleName.length) {
            self.toolView.circleButton.hidden = NO;
            [self.toolView.circleButton setTitle:self.data.circle.circleName forState:UIControlStateNormal];
        } else {
            self.toolView.circleButton.hidden = YES;
            [self.toolView.circleButton setTitle:@"" forState:UIControlStateNormal];
        }
        [self.toolView.circleButton sizeToFit];
        self.toolView.circleButton.width += 15;
    }
}

- (void)hideEssenceView:(BOOL)hidden isDetail:(BOOL)isDetail {
    NSString *displayStr = nil;
    if (self.data.title.length) {
        displayStr = self.data.title;
    } else {
        displayStr = self.data.content;
    }
    if (hidden) {
        self.iconImageView.hidden = YES;
        self.desLabel.text = displayStr;
        self.desLabel.height = self.data.describeHeight;
    } else {
        if (self.data.essence) {
            self.iconImageView.hidden = NO;
            CGFloat maxHeight = self.data.title.length?1000:50;
            NSString *desContent = [NSString stringWithFormat:@"     %@",displayStr];
            CGFloat describeWidth = JA_SCREEN_WIDTH-30;
            CGSize size = [desContent sizeOfStringWithFont:JA_REGULAR_FONT(18) maxSize:CGSizeMake(describeWidth, maxHeight)];
            self.data.describeHeight = size.height;
            self.data.detailDescribeHeight = size.height;
            self.desLabel.text = desContent;
            self.desLabel.height = size.height;
            self.data.cellHeight = 0;
            self.data.detailCellHeight = 0;
        } else {
            self.iconImageView.hidden = YES;

            self.desLabel.text = displayStr;
            // isDetail = YES是，hidden 必为 NO
            if (isDetail) {
                self.desLabel.height = self.data.detailDescribeHeight;
            } else {
                self.desLabel.height = self.data.describeHeight;
            }
        }
    }
}

- (void)hideCircleTagView:(BOOL)hidden {
    if (hidden) {
        self.userContentView.circleTagLabel.hidden = YES;
    } else {
        // 只有圈子详情和帖子详情展示
        self.userContentView.circleTagLabel.hidden = NO;
        self.userContentView.circleTagLabel.level = self.data.user.circleLevel;
        self.userContentView.circleTagLabel.isCircle = self.data.user.isCircleAdmin;
    }
}

@end
