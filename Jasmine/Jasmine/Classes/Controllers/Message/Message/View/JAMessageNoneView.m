//
//  JAMessageNoneView.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAMessageNoneView.h"

@interface JAMessageNoneView ()


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, assign) BOOL useLoginButton;

@property (nonatomic, strong) NSString *imageName;


@end

@implementation JAMessageNoneView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    imgView.backgroundColor = [UIColor clearColor];
    [self addSubview:imgView];
    self.imageView = imgView;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0, self.width - 20, 52)];
    label.backgroundColor = [UIColor clearColor];
    label.font = JA_FONT(18);
    label.textColor = HEX_COLOR(0x444444);
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    self.messageLabel = label;
    
    [self addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake((self.width - 110)/2, label.bottom + 50, 110, 37);
    [button setTitleColor:HEX_COLOR(0x02bfa6) forState:UIControlStateNormal];
    [button setTitle:@"注册/登录" forState:UIControlStateNormal];
    button.titleLabel.font = JA_FONT(14);
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = HEX_COLOR(0x02bfa6).CGColor;
    button.layer.borderWidth = 1;
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.loginButton = button;
}

- (void)updateMessage:(NSString *)firstMsg secondMsg:(NSString *)secondMsg
{
    NSString *string = [NSString stringWithFormat:@"%@\n%@", firstMsg, secondMsg];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:12];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [message addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
    
    
    NSRange firstRange = NSMakeRange(0, firstMsg.length);
    NSRange secondRange = NSMakeRange(firstMsg.length + 1, secondMsg.length);
    // font
    [message addAttribute:NSFontAttributeName value:JA_REGULAR_FONT(18) range:firstRange];
    [message addAttribute:NSFontAttributeName value:JA_FONT(14) range:secondRange];
    
    // color
    if (IS_LOGIN)
    {
        [message addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x7e8392) range:firstRange];
        [message addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xe5e5e5) range:secondRange];
        
    }
    else
    {
        [message addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x738392) range:firstRange];
        [message addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xe6e6e6) range:secondRange];
        
    }
    
    self.messageLabel.attributedText = message;
    
    
    
}


- (void)show:(NSString *)topMsg
   bottomMsg:(NSString *)bottomMsg
   imageName:(NSString *)imageName
useLoginButton:(BOOL)useLoginButton
{
    self.useLoginButton  = useLoginButton;
    [self updateMessage:topMsg secondMsg:bottomMsg];
    self.imageName = imageName;
    
}



- (void)setImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    CGFloat imageOffset = 20;
    CGFloat messageOffset = 28;
    if (image)
    {
        self.imageView.image = image;
        CGSize size = image.size;
        self.imageView.size = size;
        
        CGFloat messageHeight = self.messageLabel.height;
        CGFloat loginButtonHeight = self.loginButton.height;
        
        CGFloat y = (self.height - messageHeight - 100 - loginButtonHeight - size.height - imageOffset - messageOffset)/2;
        
        if (IS_LOGIN || self.useLoginButton == NO)
        {
            y = (self.height - messageHeight - 100 - size.height - imageOffset)/2;
            self.loginButton.hidden = YES;
        }
        else
        {
            self.loginButton.hidden = NO;
        }
        self.imageView.y = y;
        self.imageView.x = (self.width - size.width)/2;
        
        self.messageLabel.top = self.imageView.bottom + imageOffset;
        self.loginButton.top = self.messageLabel.bottom + messageOffset;
        
    }else{
        self.imageView.x = self.width * 0.5;
        self.imageView.y = JA_SCREEN_HEIGHT * 0.2;
        self.messageLabel.top = self.imageView.bottom + imageOffset;
        self.loginButton.top = self.messageLabel.bottom + messageOffset;
    }
}

- (void)buttonAction
{
    if (self.loginBlock)
    {
        self.loginBlock();
    }
}

@end
