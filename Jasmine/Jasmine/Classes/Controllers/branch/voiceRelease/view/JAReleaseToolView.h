//
//  JAReleaseToolView.h
//  Jasmine
//
//  Created by xujin on 2018/6/1.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAReleaseToolView : UIView

@property (nonatomic, strong) UIButton *locationBGView;
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UIButton *locationCloseButton;
@property (nonatomic, strong) UIButton *anonymousButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) UIButton *topicButton;
@property (nonatomic, strong) UIButton *atPersonButton;
@property (nonatomic, strong) UIButton *addPicButton;

- (void)showLocationTitle:(NSString *)title isOpen:(BOOL)isOpen;
- (void)setHiddenActionButtons:(BOOL)hideActionButtons;

@end
