//
//  JAAboutUsCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAHelperCell.h"
#import "JAGuideHelpModel.h"

@interface JAHelperCell ()

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIImageView *videoImageView;
@property (nonatomic, weak) UIView *lineView;

@end
@implementation JAHelperCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAboutUs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setupAboutUs
{
    UILabel *leftLabel = [[UILabel alloc] init];
    _leftLabel = leftLabel;
    leftLabel.text = @" ";
    leftLabel.textColor = HEX_COLOR(JA_ListTitle);
    leftLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:leftLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImageView;
    [self.contentView addSubview:arrowImageView];
    
    UIImageView *videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guidevideo_video"]];
    _videoImageView = videoImageView;
    videoImageView.hidden = YES;
    [self.contentView addSubview:videoImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self culatorAboutUs];
}

- (void)culatorAboutUs
{
    self.leftLabel.x = 14;
    [self.leftLabel sizeToFit];
    self.leftLabel.centerY = self.contentView.height * 0.5;
    
    self.arrowImageView.x = self.contentView.width - self.arrowImageView.width - 14;
    self.arrowImageView.centerY = self.leftLabel.centerY;
    
    self.videoImageView.x = self.contentView.width - self.videoImageView.width - 14;
    self.videoImageView.centerY = self.leftLabel.centerY;
    
    self.lineView.x = 14;
    self.lineView.y = self.contentView.height - 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.height = 1;
}


//- (void)setHelperDic:(NSDictionary *)helperDic
//{
//    _helperDic = helperDic;
//    
//    self.leftLabel.text = helperDic[@"problem"];
//    
//    if ([helperDic[@"type"] integerValue] == 0) {
//        
//        self.arrowImageView.hidden = NO;
//        self.videoImageView.hidden = YES;
//    }else{
//        self.arrowImageView.hidden = YES;
//        self.videoImageView.hidden = NO;
//    }
//}

- (void)setHelpModel:(JAGuideHelpModel *)helpModel
{
    _helpModel = helpModel;
    
    self.leftLabel.text = helpModel.problem;
    
    if (helpModel.type.integerValue == 0) {
        self.arrowImageView.hidden = NO;
        self.videoImageView.hidden = YES;
    }else{
        self.arrowImageView.hidden = YES;
        self.videoImageView.hidden = NO;
    }
    
}

@end
