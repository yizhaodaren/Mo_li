//
//  JAInviteFriendView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/5.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACallInviteFriendModel.h"
@interface JAInviteFriendView : UIView

@property (nonatomic, strong) JACallInviteFriendModel *callModel;  // 分享的文案

- (void)showCallFloat:(NSString *)text;
- (void)showRuleFloat:(NSString *)text keyWord:(NSArray *)wordArr ruleText:(NSString *)ruleText;
@end
