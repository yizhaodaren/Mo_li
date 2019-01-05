//
//  JACircleInfoView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleInfoView.h"
#import "JACircleAdminCollectionViewCell.h"
#import "JACircleAdminModel.h"
#import "JALightUserModel.h"
#import "JACircleAdminCollectionView.h"

@interface JACircleInfoView ()
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) JACircleAdminCollectionView *collectionView1;
@property (nonatomic, weak) UIView *lineView1;
@property (nonatomic, weak) JACircleAdminCollectionView *collectionView2;
@property (nonatomic, weak) UIView *topLineView;

@property (nonatomic, weak) UILabel *levelLabel;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UILabel *myLevelLabel;
@property (nonatomic, weak) UIButton *levelButton;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIView *middleLineView;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIView *bottomLineView;
@end

@implementation JACircleInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleInfoViewUI];
    }
    return self;
}

- (void)setupCircleInfoViewUI
{
    UIView *topView = [[UIView alloc] init];
    _topView = topView;
    topView.backgroundColor = [UIColor whiteColor];
    topView.clipsToBounds = YES;
    [self addSubview:topView];
    
    JACircleAdminCollectionView *collectionView1 = [[JACircleAdminCollectionView alloc] init];
    _collectionView1 = collectionView1;
    [self.topView addSubview:collectionView1];
    
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR(0xEDEDED);
    [self.topView addSubview:lineView1];
    
    JACircleAdminCollectionView *collectionView2 = [[JACircleAdminCollectionView alloc] init];
    _collectionView2 = collectionView2;
    [self.topView addSubview:collectionView2];
    
    UIView *topLineView = [[UIView alloc] init];
    _topLineView = topLineView;
    topLineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self.topView addSubview:topLineView];
    
    UIView *middleView = [[UIView alloc] init];
    _middleView = middleView;
    middleView.backgroundColor = [UIColor whiteColor];
    middleView.clipsToBounds = YES;
    [self addSubview:middleView];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    [self setUpRestrain];
    
    [self setSubView];
}

- (void)setUpRestrain
{
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(0);
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
    }];
    
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(93);
        make.top.equalTo(self.topView.mas_bottom).offset(0);
        make.top.equalTo(self.mas_top).offset(0).priority(300);
        make.left.equalTo(self.mas_left).offset(0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(60);
        make.top.equalTo(self.middleView.mas_bottom).offset(0);
        make.top.equalTo(self.topView.mas_bottom).offset(0).priority(300);
        make.top.equalTo(self.mas_top).offset(0).priority(200);
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    [self.collectionView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(128);
        make.top.equalTo(self.topView.mas_top).offset(0);
        make.left.equalTo(self.topView.mas_left).offset(0);
    }];
    
    [self.lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(1);
        make.top.equalTo(self.collectionView1.mas_bottom).offset(0);
        make.left.equalTo(self.collectionView1.mas_left).offset(0);
    }];
    
    [self.collectionView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(128);
        make.top.equalTo(self.lineView1.mas_bottom).offset(0);
        make.left.equalTo(self.topView.mas_left).offset(0);
    }];
    
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(JA_SCREEN_WIDTH);
        make.height.offset(10);
        make.top.equalTo(self.collectionView2.mas_bottom).offset(0);
        make.top.equalTo(self.collectionView1.mas_bottom).offset(0).priority(300);
        make.left.equalTo(self.topView.mas_left).offset(0);
    }];
}

- (void)setSubView
{
    UILabel *levelLabel = [[UILabel alloc] init];
    _levelLabel = levelLabel;
    levelLabel.text = @"圈内等级";
    levelLabel.textColor = HEX_COLOR(0x363636);
    levelLabel.font = JA_MEDIUM_FONT(15);
    [self.middleView addSubview:levelLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self.middleView addSubview:lineView];
    
    UILabel *myLevelLabel = [[UILabel alloc] init];
    _myLevelLabel = myLevelLabel;
    myLevelLabel.text = @"我的等级";
    myLevelLabel.textColor = HEX_COLOR(0x9b9b9b);
    myLevelLabel.font = JA_MEDIUM_FONT(15);
    [self.middleView addSubview:myLevelLabel];
    
    UIButton *levelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _levelButton = levelButton;
    levelButton.backgroundColor = HEX_COLOR(0x6BD379);
    [levelButton setTitle:@"1" forState:UIControlStateNormal];
    [levelButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    levelButton.titleLabel.font = JA_MEDIUM_FONT(8);
    [levelButton setImage:[UIImage imageNamed:@"branch_circle_level"] forState:UIControlStateNormal];
    [levelButton setButtonImageTitleStyle:ButtonImageTitleStyleDefault padding:4];
    [levelButton sizeToFit];
    [self.middleView addSubview:levelButton];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImageView;
    [self.middleView addSubview:arrowImageView];
    
    UIView *middleLineView = [[UIView alloc] init];
    _middleLineView = middleLineView;
    middleLineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self.middleView addSubview:middleLineView];
    
    UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followButton = followButton;
    [followButton setTitle:@"关注圈子" forState:UIControlStateNormal];
    [followButton setTitle:@"取消关注" forState:UIControlStateSelected];
    [followButton setTitleColor:HEX_COLOR(0x6BD379) forState:UIControlStateNormal];
    [followButton setTitleColor:HEX_COLOR(0xFF7054) forState:UIControlStateSelected];
    followButton.titleLabel.font = JA_REGULAR_FONT(16);
    [self.bottomView addSubview:followButton];
    
    UIView *bottomLineView = [[UIView alloc] init];
    _bottomLineView = bottomLineView;
    bottomLineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self.bottomView addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self calculatorCircleInfoViewFrame];
}

- (void)calculatorCircleInfoViewFrame
{
    [self.levelLabel sizeToFit];
    self.levelLabel.x = 15;
    self.levelLabel.y = 10;
    self.levelLabel.height = 21;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.levelLabel.bottom + 10;
    
    [self.myLevelLabel sizeToFit];
    self.myLevelLabel.x = self.levelLabel.x;
    self.myLevelLabel.y = self.lineView.bottom + 10;
    self.myLevelLabel.height = 21;
    
    [self.levelButton sizeToFit];
    self.levelButton.width += 10;
    self.levelButton.height = 14;
    self.levelButton.centerY = self.myLevelLabel.centerY;
    self.levelButton.x = self.myLevelLabel.right + 10;
    self.levelButton.layer.cornerRadius = 2;
    self.levelButton.layer.masksToBounds = YES;
    
    self.arrowImageView.centerY = self.myLevelLabel.centerY;
    self.arrowImageView.x = self.width - 15 - self.arrowImageView.width;
    
    self.middleLineView.width = JA_SCREEN_WIDTH;
    self.middleLineView.height = 10;
    self.middleLineView.y = self.myLevelLabel.bottom + 10;
    
    self.followButton.width = JA_SCREEN_WIDTH;
    self.followButton.height = 50;
    
    self.bottomLineView.width = JA_SCREEN_WIDTH;
    self.bottomLineView.height = 10;
    self.bottomLineView.y = self.followButton.bottom;
}

- (void)setDataSourceArray:(NSArray *)dataSourceArray
{
    _dataSourceArray = dataSourceArray;
    if (dataSourceArray.count > 1) {
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(267);
        }];
        self.collectionView1.dataSourceModel = dataSourceArray[0];
        self.collectionView2.dataSourceModel = dataSourceArray[1];
    }else if (dataSourceArray.count > 0){
        [self.lineView1 removeFromSuperview];
        [self.collectionView2 removeFromSuperview];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(138);
        }];
        self.collectionView1.dataSourceModel = dataSourceArray[0];
    }else{
        [self.topView removeFromSuperview];
    }
}

- (void)setCircleModel:(JACircleModel *)circleModel
{
    _circleModel = circleModel;
    
    if (!circleModel.isConcern) {
        [self.middleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(0);
        }];
    }else{
        [self.middleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(93);
        }];
    }
    
    self.followButton.selected = self.circleModel.isConcern;
    [self.levelButton setTitle:[NSString stringWithFormat:@"%@",circleModel.level] forState:UIControlStateNormal];
}

@end
