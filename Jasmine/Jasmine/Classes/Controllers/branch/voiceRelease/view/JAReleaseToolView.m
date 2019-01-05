//
//  JAReleaseToolView.m
//  Jasmine
//
//  Created by xujin on 2018/6/1.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAReleaseToolView.h"

@implementation JAReleaseToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *locationBGView = [UIButton new];
        locationBGView.backgroundColor = HEX_COLOR(0xFAFAFA);
        locationBGView.layer.cornerRadius = 12.5;
        locationBGView.layer.masksToBounds = YES;
        locationBGView.layer.borderWidth = 1;
        locationBGView.layer.borderColor = [HEX_COLOR(0xE8E8E8) CGColor];
        [self addSubview:locationBGView];
        [locationBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.offset(15);
            make.height.offset(25);
        }];
        self.locationBGView = locationBGView;
        
        UIImageView *locationIcon = [UIImageView new];
        locationIcon.image = [UIImage imageNamed:@"release_location_icon"];
        [locationBGView addSubview:locationIcon];
        [locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(10);
            make.centerY.equalTo(locationBGView.mas_centerY);
            make.width.offset(0);
        }];
        self.locationIcon = locationIcon;
        
        UILabel *locationTitleLabel = [UILabel new];
        locationTitleLabel.font = JA_REGULAR_FONT(12);
        locationTitleLabel.textColor = HEX_COLOR(0x6E6E6E);
        locationTitleLabel.text = @"你在哪里?";
        [locationBGView addSubview:locationTitleLabel];
        [locationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(locationIcon.mas_right).offset(0);
            make.centerY.equalTo(locationBGView.mas_centerY);
        }];
        self.locationTitleLabel = locationTitleLabel;
        
        UIButton *locationCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationCloseButton setImage:[UIImage imageNamed:@"release_location_close"] forState:UIControlStateNormal];
        locationCloseButton.userInteractionEnabled = NO;
        [locationBGView addSubview:locationCloseButton];
        [locationCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(locationTitleLabel.mas_right).offset(0);
            make.centerY.equalTo(locationBGView.mas_centerY);
            make.width.offset(0);
            
            make.right.equalTo(locationBGView.mas_right).offset(-10);
        }];
        self.locationCloseButton = locationCloseButton;
        
        UIButton *anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [anonymousButton setImage:[UIImage imageNamed:@"release_anonymous_open"] forState:UIControlStateNormal];
        [anonymousButton setImage:[UIImage imageNamed:@"release_anonymous_open"] forState:UIControlStateHighlighted];
        [anonymousButton setImage:[UIImage imageNamed:@"release_anonymous_close"] forState:UIControlStateSelected];
        [anonymousButton setImage:[UIImage imageNamed:@"release_anonymous_close"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self addSubview:anonymousButton];
        [anonymousButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(locationBGView.mas_centerY);
            make.right.offset(-15);
        }];
        self.anonymousButton = anonymousButton;
        
        UIView *downView = [UIView new];
        downView.backgroundColor = HEX_COLOR(0xF9F9F9);
        [self addSubview:downView];
        downView.y = 35;
        downView.width = self.width;
        downView.height = 44;
        
        UIView *lineView = [UIView new];
        lineView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, 1);
        lineView.backgroundColor = HEX_COLOR(JA_Line);
        [downView addSubview:lineView];
        
        UIView *lineView1 = [UIView new];
        lineView1.frame = CGRectMake(0, downView.height-1, JA_SCREEN_WIDTH, 1);
        lineView1.backgroundColor = HEX_COLOR(JA_Line);
        [downView addSubview:lineView1];
        
        UIButton *keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [keyboardButton setImage:[UIImage imageNamed:@"release_keyboard"] forState:UIControlStateNormal];
        [keyboardButton setImage:[UIImage imageNamed:@"release_keyboard"] forState:UIControlStateHighlighted];
        [keyboardButton setImage:[UIImage imageNamed:@"release_keyboard"] forState:UIControlStateSelected];
        [keyboardButton setImage:[UIImage imageNamed:@"release_keyboard"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [downView addSubview:keyboardButton];
        [keyboardButton sizeToFit];
        keyboardButton.x = 20;
        keyboardButton.centerY = downView.height/2.0;
        self.keyboardButton = keyboardButton;
        
        UIButton *topicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [topicButton setImage:[UIImage imageNamed:@"release_topic"] forState:UIControlStateNormal];
        [topicButton setImage:[UIImage imageNamed:@"release_topic"] forState:UIControlStateHighlighted];
        [downView addSubview:topicButton];
        [topicButton sizeToFit];
        topicButton.x = JA_SCREEN_WIDTH-WIDTH_ADAPTER(32)-topicButton.width;
        topicButton.centerY = keyboardButton.centerY;
        self.topicButton = topicButton;

        UIButton *atPersonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [atPersonButton setImage:[UIImage imageNamed:@"release_at"] forState:UIControlStateNormal];
        [atPersonButton setImage:[UIImage imageNamed:@"release_at"] forState:UIControlStateHighlighted];
        [downView addSubview:atPersonButton];
        [atPersonButton sizeToFit];
        atPersonButton.x = topicButton.x-WIDTH_ADAPTER(36)-atPersonButton.width;
        atPersonButton.centerY = keyboardButton.centerY;
        self.atPersonButton = atPersonButton;

        UIButton *addPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addPicButton setImage:[UIImage imageNamed:@"release_addphoto_btn"] forState:UIControlStateNormal];
        [addPicButton setImage:[UIImage imageNamed:@"release_addphoto_btn"] forState:UIControlStateHighlighted];
        [downView addSubview:addPicButton];
        [addPicButton sizeToFit];
        addPicButton.x = atPersonButton.x-WIDTH_ADAPTER(38)-addPicButton.width;
        addPicButton.centerY = keyboardButton.centerY;
        self.addPicButton = addPicButton;
    }
    return self;
}

- (void)showLocationTitle:(NSString *)title isOpen:(BOOL)isOpen {
    if (isOpen) {
        self.locationTitleLabel.text = title;
        [self.locationTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.locationIcon.mas_right).offset(5);
        }];
        [self.locationIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(10);
        }];
        [self.locationCloseButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.locationTitleLabel.mas_right).offset(5);
            make.width.offset(7);
        }];
    } else {
        self.locationTitleLabel.text = title;
        [self.locationTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.locationIcon.mas_right).offset(0);
        }];
        [self.locationIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.offset(0);
        }];
        [self.locationCloseButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.locationTitleLabel.mas_right).offset(0);
            make.width.offset(0);
        }];
    }
}

- (void)setHiddenActionButtons:(BOOL)hideActionButtons {
    self.addPicButton.hidden = hideActionButtons;
    self.atPersonButton.hidden = hideActionButtons;
    self.topicButton.hidden = hideActionButtons;
}

@end
