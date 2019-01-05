//
//  JAMessageTableViewCell.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAMessageTableViewCell.h"
#import "NTESSnapchatAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESMoliTextAttachment.h"
#import "NIMKitUtil.h"
#import "NIMKitInfoFetchOption.h"

@interface JAMessageTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *unreadLabel;
@property (nonatomic, strong) UILabel *officLabel;

@property (nonatomic, strong) UIButton *contactButton;

@property (nonatomic, strong) UILabel *lineLabel;


@end

@implementation JAMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = HEX_COLOR(JA_Background);
        [self setupSubviews];
    }
    return self;
}

// 跳转个人中心
- (void)jumpPersonalCenter
{
    
    NSString *userUid = [self.conversation.session.sessionId substringFromIndex:4];
    
    if ([self.delegate respondsToSelector:@selector(message_jumpPersonalCenterWithUserId:)]) {
        
        [self.delegate message_jumpPersonalCenterWithUserId:userUid];
    }
}

- (void)setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 13, 45, 45)];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonalCenter)];
    [imageView addGestureRecognizer:tap];
    imageView.layer.cornerRadius = imageView.width * 0.5;
    imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:imageView];
    self.avatarImgView = imageView;
    
    CGFloat y = imageView.top;
    // name
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 14, y, 150, 22)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    // notes
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, nameLabel.bottom + 5, JA_SCREEN_WIDTH - nameLabel.left - 44, 18)];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textColor = HEX_COLOR(0x9b9b9b);
    [self.contentView addSubview:messageLabel];
    
    self.messageLabel = messageLabel;
    
    
    // time
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(JA_SCREEN_WIDTH - 76 ,16, 60, 16)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textColor = HEX_COLOR(0x9b9b9b);
    timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel = timeLabel;
    [self.contentView addSubview:timeLabel];
    
    // unread
    UILabel *unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(JA_SCREEN_WIDTH - 35,
                                                                     timeLabel.bottom + 11,
                                                                     16,
                                                                     16)];
    unreadLabel.backgroundColor = HEX_COLOR(0xFF3B30);
    unreadLabel.font = [UIFont systemFontOfSize:10];
    unreadLabel.textColor = [UIColor whiteColor];
    unreadLabel.textAlignment = NSTextAlignmentCenter;
    unreadLabel.layer.cornerRadius = 8;
    unreadLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:unreadLabel];
    self.unreadLabel = unreadLabel;
    
    self.officLabel = [[UILabel alloc] init];
    self.officLabel.width = 30;
    self.officLabel.height = 16;
    self.officLabel.centerY = self.nameLabel.centerY;
    self.officLabel.text = @"官方";
    self.officLabel.hidden = YES;
    self.officLabel.textColor = HEX_COLOR(0x1CD39B);
    self.officLabel.font = JA_REGULAR_FONT(10);
    self.officLabel.layer.cornerRadius = 8;
    self.officLabel.clipsToBounds = YES;
    self.officLabel.layer.borderWidth = 1;
    self.officLabel.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    self.officLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.officLabel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, 69, JA_SCREEN_WIDTH, 1)];
    line.backgroundColor = HEX_COLOR(0xededed);
    [self.contentView addSubview:line];
    self.lineLabel = line;
}

- (void)setFrame:(CGRect)frame
{
//    frame.size.height = 70;
    [super setFrame:frame];
}

- (void)setAvatarBySession:(NIMSession *)session
{
    NIMKitInfo *info = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        info = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil];
    }
    else
    {
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        info = [[NIMKit sharedKit] infoByUser:session.sessionId option:option];
    }
    
    if (info.avatarUrlString) {
        [self.avatarImgView ja_setImageWithURLStr:info.avatarUrlString placeholder:info.avatarImage];
    }else{
        self.avatarImgView.image = info.avatarImage;
    }
}

- (void)setConversation:(NIMRecentSession *)conversation
{
    _conversation = conversation;
    NIMMessage *message = conversation.lastMessage;
    NIMSession *chatSession = conversation.session;
    [self setAvatarBySession:chatSession];
    self.nameLabel.text = [NIMKitUtil showNick:chatSession.sessionId inSession:chatSession];
    CGFloat w = [self.nameLabel.text sizeWithFont:[UIFont systemFontOfSize:16]].width;
    self.officLabel.x = w + self.nameLabel.x + 10;
    self.chatName = self.nameLabel.text;
    self.chatUid = [chatSession.sessionId substringFromIndex:4];
    
    // 获取消息内容 -- 展示消息（内容、时间、未读数量）
    NSString *unReadCount = [NSString stringWithFormat:@"%ld",conversation.unreadCount];  // 未读数量
    
    
    NSString *messageStr = [self messageContent:message];      
    NSString *time = [NSString distanceMessageTimeWithBeforeTime:(double)message.timestamp * 1000.0];  // 时间
    
//    [self.avatarImgView ja_setImageWithURLStr:imageStr];
//    self.nameLabel.text = name;
//   unReadCount = @"15";
    if (conversation.unreadCount > 0) {
        self.unreadLabel.hidden = NO;
        if ([unReadCount integerValue] >= 100) {
            
            self.unreadLabel.width = 20;
            self.unreadLabel.text = @"...";
        }else if([unReadCount integerValue] >= 10){
            self.unreadLabel.width = 20;
            self.unreadLabel.text = unReadCount;
        }else{
            self.unreadLabel.width = 16;
            self.unreadLabel.text = unReadCount;
        }
        
    }else{
        self.unreadLabel.hidden = YES;
    }
    self.messageLabel.text = messageStr;
    self.timeLabel.text = time;
    
    // 获取最后一个对方的消息 - 判断是不是自己的消息
    NSString *fromId = [message.from substringFromIndex:4];
    
    // 获取自己的id
    NSString *myId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 获取对方的官方标识
    [JAChatMessageManager yx_getUserInfo:@[chatSession.sessionId] complete:^(NSArray<NIMUser *> * _Nullable users) {
        
        NIMUser *user = users.firstObject;
        
        NSLog(@"%@",user.userInfo.ext);
        NSString *officExt = user.userInfo.ext;
        
        if (officExt.length) {
            NSDictionary *officDic = [officExt mj_JSONObject];
            NSString *offic = officDic[@"extMap"][@"achievementId"];
            
            if (offic.integerValue == 1) {
                self.officLabel.hidden = NO;
            }else{
                self.officLabel.hidden = YES;
            }
            
        }else{
            
            if ([myId isEqualToString:fromId]) {   // 该条消息是自己的
                // 获取对方的官方状态
                if (message.remoteExt) {
                    NSDictionary *dic = message.remoteExt;
                    NSInteger status = [dic[@"otherOffic"] integerValue];
                    if (status == 1) {
                        self.officLabel.hidden = NO;
                    }else{
                        self.officLabel.hidden = YES;
                    }
                }else{
                    self.officLabel.hidden = YES;
                }
            }else{
                if (message.remoteExt) {
                    NSDictionary *dic = message.remoteExt;
                    NSInteger status = [dic[@"myOffic"] integerValue];
                    if (status == 1) {
                        self.officLabel.hidden = NO;
                    }else{
                        self.officLabel.hidden = YES;
                    }
                }else{
                    self.officLabel.hidden = YES;
                }
            }
        }
        
    }];
    
    
}

- (NSString *)messageContent:(NIMMessage*)lastMessage{
    NSString *text = @"";
    switch (lastMessage.messageType) {
        case NIMMessageTypeText:
            text = lastMessage.text;
            break;
        case NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case NIMMessageTypeTip:
            text = lastMessage.text;
            break;
        case NIMMessageTypeCustom:
        {
            NIMCustomObject *object = (NIMCustomObject *)lastMessage.messageObject;
            if ([object.attachment isKindOfClass:[NTESJanKenPonAttachment class]]) {
                text = @"[猜拳]";
            }
            else if ([object.attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
                text = @"[阅后即焚]";
            }
            else if ([object.attachment isKindOfClass:[NTESChartletAttachment class]]) {
                text = @"[帖图]";
            }
            else if ([object.attachment isKindOfClass:[NTESMoliTextAttachment class]]) {
                text = ((NTESMoliTextAttachment *)object.attachment).text;
            }
            else{
                text = @"[未知消息]";
            }
        }
            break;
        default:
            text = @"[未知消息]";
    }
    return text;
}

- (void)setData:(JAMessageData *)data
{
    _data = data;

    if (data)
    {
        if (data.isContacts)
        {
            self.lineLabel.y = 33;
            
            self.contactButton.hidden = NO;
            self.avatarImgView.hidden = YES;
            self.nameLabel.hidden = YES;
            self.messageLabel.hidden = YES;
            self.timeLabel.hidden = YES;
            self.unreadLabel.hidden = YES;
        }
        else
        {
            self.lineLabel.y = 75;
            
            
            self.contactButton.hidden = YES;
            self.avatarImgView.hidden = NO;
            self.nameLabel.hidden = NO;
            self.messageLabel.hidden = NO;
            self.timeLabel.hidden = NO;
            self.unreadLabel.hidden = NO;
            
            
            if (data.localImgName)
            {
                self.avatarImgView.image = [UIImage imageNamed:data.localImgName];
                self.timeLabel.hidden = YES;
            }
            else
            {
                [self.avatarImgView ja_setImageWithURLStr:data.avatar];
            }
            if (data.name)
            {
                self.nameLabel.text = data.name;
            }
            if (data.message)
            {
                self.messageLabel.text = data.message;
            }
            
            self.timeLabel.text = [NSString distanceTimeWithBeforeTime:data.timestamp];
            
            CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(100, 10)];
            self.timeLabel.width = size.width;
            
            CGFloat maxX = self.unreadLabel.width/2 + self.unreadLabel.x;
            CGFloat x = maxX - self.timeLabel.width/2;
            self.timeLabel.x = x;
            
            if (data.unreadCount)
            {
                self.unreadLabel.hidden = NO;
                if (data.unreadCount >= 100)
                {
                    self.unreadLabel.text = @"···";
                }
                else
                {
                    self.unreadLabel.text = [NSString stringWithFormat:@"%d", (int)data.unreadCount];
                }
            }
            else
            {
                self.unreadLabel.hidden = YES;
            }
        }
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
