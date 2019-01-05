//
//  JAPersonTopicHeaderView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonTopicHeaderView.h"
#import "JAPersonalTopImageView.h"
#import "JAPaddingLabel.h"

@interface JAPersonTopicHeaderView ()

@property (nonatomic, weak) JAPersonalTopImageView *backImageView;  // 背景图片
//@property (nonatomic, weak) UIView *alphaView;            // 半透明view
@property (nonatomic, weak) UIImageView *topicIconImageView;  // 标签图片
@property (nonatomic, weak) UILabel *topicNameLabel;    // 话题名
@property (nonatomic, weak) UILabel *subNameLabel;     // 话题子描述

@property (nonatomic, weak) JAPaddingLabel *detailLabel;      // 详细描述

@end

@implementation JAPersonTopicHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTopicHeaderView];
    }
    return self;
}

- (void)setupTopicHeaderView
{
    JAPersonalTopImageView *backImageView = [[JAPersonalTopImageView alloc] init];
    _backImageView = backImageView;
    [self addSubview:backImageView];
    
    UIImageView *topicIconImageView = [[UIImageView alloc] init];
    _topicIconImageView = topicIconImageView;
    topicIconImageView.image = [UIImage imageNamed:@"branch_topic_#"];
    [backImageView addSubview:topicIconImageView];
    
    UILabel *topicNameLabel = [[UILabel alloc] init];
    _topicNameLabel = topicNameLabel;
    topicNameLabel.text = @" ";
    topicNameLabel.numberOfLines = 2;
    topicNameLabel.font = JA_MEDIUM_FONT(22);
    topicNameLabel.textColor = HEX_COLOR(0xffffff);
    [backImageView addSubview:topicNameLabel];
    
    UILabel *subNameLabel = [[UILabel alloc] init];
    _subNameLabel = subNameLabel;
    subNameLabel.text = @" ";
    subNameLabel.numberOfLines = 2;
    subNameLabel.font = JA_REGULAR_FONT(16);
    subNameLabel.textColor = HEX_COLOR(0xffffff);
    [backImageView addSubview:subNameLabel];
    
    JAPaddingLabel *detailLabel = [[JAPaddingLabel alloc] init];
    _detailLabel = detailLabel;
    detailLabel.text = @" ";
    detailLabel.numberOfLines = 0;
    detailLabel.font = JA_REGULAR_FONT(14);
    detailLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    detailLabel.edgeInsets = UIEdgeInsetsMake(10, 15, 0, 15);
    detailLabel.backgroundColor = HEX_COLOR(0xffffff);
    [self addSubview:detailLabel];
    
    self.backImageView.width = JA_SCREEN_WIDTH;
    self.backImageView.height = WIDTH_ADAPTER(195);
    
    [self caculatorTopicHeaderViewFrame];
}


- (void)caculatorTopicHeaderViewFrame
{
    self.detailLabel.y = self.backImageView.bottom;
    self.detailLabel.width = JA_SCREEN_WIDTH - 2 * self.detailLabel.x;
    [self.detailLabel sizeToFit];
    self.detailLabel.width = JA_SCREEN_WIDTH - 2 * self.detailLabel.x;
    
    self.subNameLabel.x = 13 + 18 + 4;
    self.subNameLabel.width = self.topicNameLabel.width;
    [self.subNameLabel sizeToFit];
    self.subNameLabel.width = self.topicNameLabel.width;
    self.subNameLabel.y = self.backImageView.height - 30 - 20;

    self.topicNameLabel.x = self.subNameLabel.x;
    self.topicNameLabel.width = self.backImageView.width - self.topicNameLabel.x * 2;
    [self.topicNameLabel sizeToFit];
    self.topicNameLabel.width = self.backImageView.width - self.topicNameLabel.x * 2;
    self.topicNameLabel.y = self.subNameLabel.y - 5 - self.topicNameLabel.height;
    
    self.topicIconImageView.width = 18;
    self.topicIconImageView.height = 20;
    self.topicIconImageView.x = 13;
    self.topicIconImageView.y = self.topicNameLabel.y + 5;
}

- (void)setTopicM:(JAVoiceTopicModel *)topicM
{
    _topicM = topicM;
    
    NSInteger topicdom = topicM.topicId.integerValue % 7;
    NSString *imageName = [NSString stringWithFormat:@"branch_topic_back_%ld",topicdom];
    
    if (topicM.imgurl.length) {

        self.backImageView.imageName = topicM.imgurl;
    }else{
        self.backImageView.imageName = imageName;
    }
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"#"];
    
    NSString *topic_title = [topicM.title stringByTrimmingCharactersInSet:set];
    
    self.topicNameLabel.text = topic_title;

    self.subNameLabel.text = [NSString stringWithFormat:@"%@人参与",topicM.discussCount];
    self.detailLabel.text = topicM.content;
    
    [self caculatorTopicHeaderViewFrame];
}

- (void)setTopOffY:(CGFloat)topOffY
{
    _topOffY = topOffY;
    
    if (topOffY <= 0) {
        self.backImageView.frame = CGRectMake(0, topOffY, JA_SCREEN_WIDTH, WIDTH_ADAPTER(195) - topOffY);
    }else{
        CGFloat y = topOffY > WIDTH_ADAPTER(195) ? WIDTH_ADAPTER(195) : topOffY;
        self.backImageView.frame = CGRectMake(0, y * 0.2, JA_SCREEN_WIDTH, WIDTH_ADAPTER(195));
    }

    self.subNameLabel.y = self.backImageView.height - 30 - 20;
    self.topicNameLabel.y = self.subNameLabel.y - 5 - self.topicNameLabel.height;
    self.topicIconImageView.y = self.topicNameLabel.y + 5;
}
@end
