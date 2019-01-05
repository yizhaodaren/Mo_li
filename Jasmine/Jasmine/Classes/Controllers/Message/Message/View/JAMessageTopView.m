//
//  JAMessageTopView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMessageTopView.h"
#import "JAOfficCustomerModel.h"
#import "NTESMoliTextAttachment.h"
#import "JAVoiceCommonApi.h"

@interface JAMessageTopView ()
@property (weak, nonatomic) IBOutlet UIImageView *officImageView;  // 小秘书
@property (weak, nonatomic) IBOutlet UILabel *officLabel;
@property (weak, nonatomic) IBOutlet UILabel *officNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *officTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *officTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;

@property (weak, nonatomic) IBOutlet UIView *middleLine;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *customerImageView;  // 客服
@property (weak, nonatomic) IBOutlet UILabel *customerLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *kefuRedLabel;
@property (weak, nonatomic) IBOutlet UILabel *kefuOfficTagLabel;


@property (weak, nonatomic) IBOutlet UILabel *notiIntroduceLabel;   // 茉莉君
@property (weak, nonatomic) IBOutlet UILabel *moliJunOfficTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *moliJunRedCountLabel;

@end
@implementation JAMessageTopView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.middleLine.backgroundColor = HEX_COLOR(0xEDEDED);
    self.bottomView.backgroundColor = HEX_COLOR(0xEDEDED);
    
    self.middleLine.height = 1;
    self.bottomView.height = 1;
    
    self.officImageView.layer.cornerRadius = self.officImageView.width * 0.5;
    self.officImageView.clipsToBounds = YES;
    self.officImageView.backgroundColor = [UIColor redColor];
    self.officNameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.officLabel.textColor = HEX_COLOR(0x9b9b9b);
    self.officTagLabel.textColor = HEX_COLOR(0x1CD39B);
    self.officTagLabel.layer.cornerRadius = 8;
    self.officTagLabel.clipsToBounds = YES;
    self.officTagLabel.layer.borderWidth = 1;
    self.officTagLabel.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    self.officTimeLabel.textColor = HEX_COLOR(0x9b9b9b);
    self.redLabel.layer.cornerRadius = 8;
    self.redLabel.clipsToBounds = YES;
    
    self.customerImageView.layer.cornerRadius = self.customerImageView.width * 0.5;
    self.customerImageView.clipsToBounds = YES;
    self.customerImageView.backgroundColor = [UIColor redColor];
    self.customerNameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.customerLabel.textColor = HEX_COLOR(0x9b9b9b);
    self.kefuOfficTagLabel.textColor = HEX_COLOR(0x1CD39B);
    self.kefuOfficTagLabel.layer.cornerRadius = 8;
    self.kefuOfficTagLabel.clipsToBounds = YES;
    self.kefuOfficTagLabel.layer.borderWidth = 1;
    self.kefuOfficTagLabel.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    self.kefuRedLabel.layer.cornerRadius = 8;
    self.kefuRedLabel.clipsToBounds = YES;
    
    self.backgroundColor = HEX_COLOR(0xFCFAF4);
    
    self.moliJunImageView.layer.cornerRadius = self.moliJunImageView.width * 0.5;
    self.moliJunImageView.clipsToBounds = YES;
    self.notiIntroduceLabel.text = @"每天为你奉上茉莉的精选内容，千万不要错过哦~";
    self.notiIntroduceLabel.textColor = HEX_COLOR(0x9b9b9b);
    self.moliJunOfficTagLabel.textColor = HEX_COLOR(0x1CD39B);
    self.moliJunOfficTagLabel.layer.cornerRadius = 8;
    self.moliJunOfficTagLabel.clipsToBounds = YES;
    self.moliJunOfficTagLabel.layer.borderWidth = 1;
    self.moliJunOfficTagLabel.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    self.moliJunRedCountLabel.layer.cornerRadius = 8;
    self.moliJunRedCountLabel.clipsToBounds = YES;
    self.moliJunRedCountLabel.hidden = YES;
    
    self.moliJunName.userInteractionEnabled = YES;
    self.moliJunImageView.userInteractionEnabled = YES;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width = JA_SCREEN_WIDTH;
}



// 茉莉官方信息
- (void)setRecentSession:(NIMRecentSession *)recentSession
{
    _recentSession = recentSession;
    
    if (recentSession.lastMessage.text.length) {
        
        self.officLabel.text = recentSession.lastMessage.text;
    }else{
        
        NSString *text = nil;
        NIMCustomObject *customObject = (NIMCustomObject*)recentSession.lastMessage.messageObject;
        
        if ([customObject isKindOfClass:[NIMCustomObject class]]) {  // 必须是自定义消息才处理
            
            id attachment = customObject.attachment;
            if ([attachment isKindOfClass:[NTESMoliTextAttachment class]]) {
                text = ((NTESMoliTextAttachment *)attachment).text;
            }
            
            if (text) {
                self.officLabel.text = text;
            }else{
                self.officLabel.text = @"我是茉莉小秘书，社区和谐大家来守护！";
            }
        }else{
            self.officLabel.text = @"我是茉莉小秘书，社区和谐大家来守护！";
        }
        
        
//        if (recentSession.lastMessage.apnsContent) {
//            self.officLabel.text = recentSession.lastMessage.apnsContent;
//        }else{
//            self.officLabel.text = @"我是茉莉小秘书，社区和谐大家来守护！";
//        }
    }
    
    
    if (recentSession.unreadCount > 0) {
        
        self.redLabel.hidden = NO;
        self.redLabel.text = [NSString stringWithFormat:@"%ld",recentSession.unreadCount];
    }else{
        self.redLabel.hidden = YES;
    }
}

// 茉莉客服
- (void)setKeFucount:(NSInteger)keFucount
{
    _keFucount = keFucount;
    
    if (keFucount > 0) {
        
        self.kefuRedLabel.hidden = NO;
        self.kefuRedLabel.text = [NSString stringWithFormat:@"%ld",keFucount];
        
    }else{
        
        self.kefuRedLabel.hidden = YES;
    }
    
}

- (void)setKeFuMessage:(NSString *)keFuMessage
{
    _keFuMessage = keFuMessage;
   
    if (self.keFucount > 0) {
        self.customerLabel.text = keFuMessage;
    }else {
        self.customerLabel.text = @"在茉莉遇到任何问题，都可以找我哦~";
    }
}

- (void)setMoliJunCount:(NSInteger)moliJunCount
{
    _moliJunCount = moliJunCount;
    
    if (moliJunCount > 0) {
        
        self.moliJunRedCountLabel.hidden = NO;
        self.moliJunRedCountLabel.text = [NSString stringWithFormat:@"%ld",moliJunCount];
    }else{
        self.moliJunRedCountLabel.hidden = YES;
    }
}

- (void)setMoliJunMessage:(NSString *)moliJunMessage
{
    _moliJunMessage = moliJunMessage;
    
    if (moliJunMessage.length) {
        self.notiIntroduceLabel.text = moliJunMessage;
    }else{
        self.notiIntroduceLabel.text = @"每天为你奉上茉莉的精选内容，千万不要错过哦~";
    }
}
@end
