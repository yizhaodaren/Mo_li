//
//  JANotiTypeView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceNotiTypeView.h"
#import "JAMessageRedButton.h"
#define kBoardVieHeight 41

@interface JAVoiceNotiTypeView ()

//@property (nonatomic, weak) UIView *boardView;  // 边框view
@property (nonatomic, strong) NSArray *btnArray;  // 按钮
@property (nonatomic, strong) NSMutableArray *btns;  // 按钮
@property (nonatomic, weak) UIView *moveView; // 移动的view
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) JAMessageRedButton *frontButton;

@end

@implementation JAVoiceNotiTypeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _btns = [NSMutableArray array];
        self.btnArray = @[@"回复",@"喜欢",@"邀请",@"关注"];
        
        [self setupNotiTypeUI];
    }
    return self;
}

// 布局
- (void)setupNotiTypeUI
{
    UIView *boardView = [[UIView alloc] init];
    _boardView = boardView;
    [self addSubview:boardView];
    
    for (NSInteger i = 0; i < self.btnArray.count; i++) {
        
        JAMessageRedButton *btn = [JAMessageRedButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setTitle:self.btnArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateHighlighted];
        [btn setTitleColor:HEX_COLOR(JA_Branch_Green) forState:UIControlStateSelected];
        [btn setTitleColor:HEX_COLOR(JA_Branch_Green) forState:UIControlStateHighlighted | UIControlStateSelected];
        btn.titleLabel.font = JA_REGULAR_FONT(15);
        [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            
            btn.selected = YES;
            self.frontButton = btn;
        }
        [_btns addObject:btn];
        [boardView addSubview:btn];
    }
    
    UIView *moveView = [[UIView alloc] init];
    _moveView = moveView;
    moveView.backgroundColor = HEX_COLOR(0x2BAA6D);
    [boardView insertSubview:moveView atIndex:0];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView];
}

// 计算
- (void)caculatorNotiType
{
    self.width = JA_SCREEN_WIDTH;
    self.height = kBoardVieHeight;
    
    self.boardView.width = self.width;
    self.boardView.height = kBoardVieHeight;
    
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = (self.boardView.width - 50) / (self.btnArray.count);
    CGFloat h = self.boardView.height - 2;
    
    for (NSInteger i = 1; i < self.boardView.subviews.count; i++) {
        
        x = (i - 1) * w + 25;
        JAMessageRedButton *btn = self.boardView.subviews[i];
        btn.x = x;
        btn.y = y;
        btn.width = w;
        btn.height = h;
        
        if (i == _tagType + 1) {
            
            self.moveView.width = 12;
            self.moveView.height = 2;
            self.moveView.y = self.height - 2;
            self.moveView.centerX = btn.centerX;
        }
    }
    
    self.lineView.height = 1;
    self.lineView.width = self.width;
    self.lineView.y = self.height - 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorNotiType];
}

- (void)setTagType:(NSInteger)tagType
{
    _tagType = tagType;
    if (tagType > _btns.count - 1) {
        return;
    }
    for (NSInteger i = 0; i < _btns.count; i++) {
        UIButton *btn = _btns[i];
        btn.selected = NO;
    }
    UIButton *btn = _btns[tagType];
    btn.selected = YES;
    self.moveView.centerX = btn.centerX;
    
}


- (void)clickButton:(JAMessageRedButton *)button
{
    self.frontButton.selected = NO;
    button.selected = YES;
    
    if (button.tag == 0) {
        
        if (self.replyClickBlock) {
            self.replyClickBlock(button);
        }
        
    }else if (button.tag == 1){
        
        if (self.agreeClickBlock) {
            self.agreeClickBlock(button);
        }
        
    }else if (button.tag == 2){
        
        if (self.inviteClickBlock) {
            self.inviteClickBlock(button);
        }
        
    }else if (button.tag == 3){
        
        if (self.focusClickBlock) {
            self.focusClickBlock(button);
        }
        
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.moveView.centerX = button.centerX;
    }];
    
    self.frontButton = button;
}


- (void)setReplyState:(BOOL)replyState
{
    _replyState = replyState;
    
    JAMessageRedButton *btn = self.boardView.subviews[1];
    btn.showRed = replyState;
}

- (void)setAgreeState:(BOOL)agreeState
{
    _agreeState = agreeState;
    
    JAMessageRedButton *btn = self.boardView.subviews[2];
    btn.showRed = agreeState;
}

- (void)setInvitationState:(BOOL)invitationState
{
    _invitationState = invitationState;
    
    JAMessageRedButton *btn = self.boardView.subviews[3];
    btn.showRed = invitationState;
}

- (void)setFocusState:(BOOL)focusState
{
    _focusState = focusState;
    
    JAMessageRedButton *btn = self.boardView.subviews[4];
    btn.showRed = focusState;
}

@end
