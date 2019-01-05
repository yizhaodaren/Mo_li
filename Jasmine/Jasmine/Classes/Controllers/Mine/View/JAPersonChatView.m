//
//  JAPersonChatView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonChatView.h"
#import "JAVoicePersonApi.h"

@interface JAPersonChatView ()

@end
@implementation JAPersonChatView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChatView];
    }
    return self;
}

- (void)setupChatView
{
    
    self.width = JA_SCREEN_WIDTH;
    self.height = 44;
    
    UIButton *chatButton = [[UIButton alloc] init];
    _chatButton = chatButton;
    [chatButton setTitle:@"对话" forState:UIControlStateNormal];
    [chatButton setImage:[UIImage imageNamed:@"person_chat"] forState:UIControlStateNormal];
    [chatButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    chatButton.titleLabel.font = JA_REGULAR_FONT(13);
    chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    chatButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [self addSubview:chatButton];
    
    UIButton *focusButton = [[UIButton alloc] init];
    _focusButton = focusButton;
    [focusButton setTitle:@"关注" forState:UIControlStateNormal];
    [focusButton setImage:[UIImage imageNamed:@"person_fouce"] forState:UIControlStateNormal];
    [focusButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    focusButton.titleLabel.font = JA_REGULAR_FONT(13);
    focusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    focusButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
//    [focusButton addTarget:self action:@selector(focusPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:focusButton atIndex:0];
    
    [self dropShadowWithOffset:CGSizeMake(0, -2)
                        radius:4
                         color:[UIColor blackColor]
                       opacity:0.1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    if (iPhoneX) {
        self.chatButton.height = self.height * 0.7;
    }else{
        self.chatButton.height = self.height;
    }
//    self.chatButton.width = self.relationType == JAUserRelationNone ? self.width * 0.5 : self.width;
    
    if (!IS_LOGIN) {
       self.chatButton.width = self.width * 0.5;
    }else if (self.relationType == JAUserRelationFocus) {
        
        self.chatButton.width = self.width;
    }else if(self.relationType == JAUserRelationFriend){
        self.chatButton.width = self.width;
    }else if(self.relationType == JAUserRelationNone){
        self.chatButton.width = self.width * 0.5;
        
    }else{
        self.chatButton.width = self.width * 0.5;
    }
    self.focusButton.width = self.width * 0.5;
    
    self.focusButton.height = self.chatButton.height;
    self.focusButton.x = self.chatButton.width;
}


- (void)setRelationType:(JAUserRelation)relationType
{
    _relationType = relationType;
    if (self.relationType == JAUserRelationFocus) {
        
        self.chatButton.width = self.width;
    }else if(self.relationType == JAUserRelationFriend){
        self.chatButton.width = self.width;
    }else if(self.relationType == JAUserRelationNone){
        self.chatButton.width = self.width * 0.5;
        
    }else{
        self.chatButton.width = self.width * 0.5;
    }
}

- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.clipsToBounds = NO;
}
@end
