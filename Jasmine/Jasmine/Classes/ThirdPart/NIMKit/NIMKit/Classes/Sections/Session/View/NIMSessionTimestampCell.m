//
//  NTESSessionTipCell.m
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionTimestampCell.h"
#import "NIMCellConfig.h"
#import "UIView+NIM.h"
#import "NIMTimestampModel.h"
#import "NIMKitUtil.h"
#import "UIImage+NIMKit.h"

@interface NIMSessionTimestampCell()

@property (nonatomic,strong) NIMTimestampModel *model;

@end

@implementation NIMSessionTimestampCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = NIMKit_UIColorFromRGB(JA_backGrayColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _timeBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_timeBGView];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = JA_REGULAR_FONT(11);
        _timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        [self addSubview:_timeLabel];
        _timeBGView.backgroundColor = HEX_COLOR(JA_BtnGrounddColor);
        _timeBGView.layer.cornerRadius = 4.0;
        _timeBGView.layer.masksToBounds = YES;
//        [_timeBGView setImage:[[UIImage nim_imageInKit:@"icon_session_time_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8,20,8,20) resizingMode:UIImageResizingModeStretch]];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_timeLabel sizeToFit];
    _timeLabel.center = CGPointMake(self.nim_centerX, 20);
    _timeBGView.frame = CGRectMake(_timeLabel.nim_left - 7, _timeLabel.nim_top - 2, _timeLabel.nim_width + 14, _timeLabel.nim_height + 4);
    
}


- (void)refreshData:(NIMTimestampModel *)data{
    self.model = data;
    if([self checkData]){
        NIMTimestampModel *model = (NIMTimestampModel *)data;
        [_timeLabel setText:[NIMKitUtil showTime:model.messageTime showDetail:YES]];
    }
}

- (BOOL)checkData{
    return [self.model isKindOfClass:[NIMTimestampModel class]];
}

@end
