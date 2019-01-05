//
//  JAStoryTableViewCell.h
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAEmitterView.h"
#import "JANewVoiceModel.h"
#import "JAPersonTagView.h"
#import "JAMedalMarkView.h"

typedef NS_ENUM(NSInteger, JAStoryTableViewCellType) {
    DefaultCellType, // 只有标题
    SingleImageCellType, // 标题+单图片
    MultiImageCellType, // 标题+多图片
    VoiceNoImageCellType, // 标题+语音
    VoiceAndSingleImageCellType, // 标题+语音+单图片
    VoiceAndMuliImageCellType, // 标题+语音+多图片
};

@interface JAStoryUserView : UIView

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) JAPersonTagView *circleTagLabel;
@property (nonatomic, strong) JAMedalMarkView *medalMarkView;
@property (nonatomic, strong) UILabel *locationAndTimeLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *followButton;

@end

@interface JAStoryToolView : UIView

@property (nonatomic, strong) JAEmitterView *agreeButton;
@property (nonatomic, strong) UILabel *agreeLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel *shareLabel;

@property (nonatomic, strong) UIButton *zanBgButton;
@property (nonatomic, strong) UIButton *circleButton;

@end

@interface JAStoryTableViewCell : UITableViewCell

@property (nonatomic, strong) JANewVoiceModel *data;
@property (nonatomic, strong) JAStoryUserView *userContentView;
@property (nonatomic, strong) JAStoryToolView *toolView;
@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

@property (nonatomic, copy) void(^headActionBlock)(JAStoryTableViewCell * cell);
@property (nonatomic, copy) void(^shareBlock)(JAStoryTableViewCell *cell);
@property (nonatomic, copy) void(^agreeBlock)(JAStoryTableViewCell *cell);
@property (nonatomic, copy) void(^playBlock)(JAStoryTableViewCell *cell);
//@property (nonatomic, copy) void(^commentBlock)(JAStoryTableViewCell *cell);
@property (nonatomic, copy) void(^moreBlock)(JAStoryTableViewCell *cell);
@property (nonatomic, copy) void(^followBlock)(JAStoryTableViewCell *cell);
@property (nonatomic, copy) void(^circleBlock)(JAStoryTableViewCell *cell);
// v2.5.4
@property (nonatomic, copy) void(^topicDetailBlock)(NSString *topicName);  // 跳转话题详情
// v2.6.0
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName, NSArray *atList);

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     cellType:(NSInteger)cellType
                   imageCount:(NSInteger)imageCount;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     cellType:(NSInteger)cellType
                   imageCount:(NSInteger)imageCount
                     isDetail:(BOOL)isDetail;

- (void)hideTimeLabel:(BOOL)hidden;
- (void)hideCircleView:(BOOL)hidden;
- (void)hideEssenceView:(BOOL)hidden isDetail:(BOOL)isDetail;
- (void)hideCircleTagView:(BOOL)hidden;

@end
