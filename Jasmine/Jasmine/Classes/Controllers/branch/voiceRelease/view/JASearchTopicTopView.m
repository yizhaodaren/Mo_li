//
//  JASearchTopicTopView.m
//  Jasmine
//
//  Created by xujin on 24/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASearchTopicTopView.h"

@interface JASearchTopicTopView()

@end

@implementation JASearchTopicTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *searchBGView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, JA_SCREEN_WIDTH-12*2-44, 30)];
        searchBGView.backgroundColor = HEX_COLOR(0xF6F6F6);
        searchBGView.layer.cornerRadius = 15.0;
        searchBGView.layer.masksToBounds = YES;
        [self addSubview:searchBGView];
        searchBGView.centerY = self.height/2.0;

        UIImageView *topicIV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 20, 20)];
        topicIV.image = [UIImage imageNamed:@"release_topic"];
        [searchBGView addSubview:topicIV];
        topicIV.centerY = searchBGView.height/2.0;
        
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(topicIV.right+3, 0, searchBGView.width-topicIV.right-3, 30)];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
//        tf.textColor = HEX_COLOR(JA_BlackTitle);
        tf.font = JA_REGULAR_FONT(14);
        NSString *holderText = @"话题";
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:HEX_COLOR(0x9B9B9B)
                            range:NSMakeRange(0, holderText.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:JA_REGULAR_FONT(14)
                            range:NSMakeRange(0, holderText.length)];
        tf.attributedPlaceholder = placeholder;
        tf.returnKeyType = UIReturnKeySearch;
        [searchBGView addSubview:tf];
        self.searchTextField = tf;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.titleLabel.font = JA_REGULAR_FONT(16);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
        [self addSubview:cancelButton];
        [cancelButton sizeToFit];
        cancelButton.x = searchBGView.right+12;
        cancelButton.centerY = searchBGView.centerY;
        self.cancelButton = cancelButton;
    }
    return self;
}

@end
