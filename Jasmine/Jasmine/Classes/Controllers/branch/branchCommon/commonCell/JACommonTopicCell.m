//
//  JACommonTopicCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACommonTopicCell.h"
#import "JAPaddingLabel.h"
#import "JAVoiceTopicModel.h"

@interface JACommonTopicCell ()

@property (nonatomic, strong) UIImageView *topicImageView;
@property (nonatomic, strong) UILabel *topicNameLabel;
@property (nonatomic, strong) JAPaddingLabel *topicSubNameLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation JACommonTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier type:0];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSInteger)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCommonTopicCellWithType:type];
        self.selectionStyle =UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupCommonTopicCellWithType:(NSInteger)type
{
    self.topicImageView = [[UIImageView alloc] init];
//    self.topicImageView.image = [UIImage imageNamed:@"bg_man"];
//    self.topicImageView.backgroundColor = [UIColor redColor];
    self.topicImageView.layer.masksToBounds = YES;
//    self.topicImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.topicImageView];
    
    self.topicNameLabel = [[UILabel alloc] init];
    self.topicNameLabel.text = @" ";
    [self.contentView addSubview:self.topicNameLabel];
    
    self.topicSubNameLabel = [[JAPaddingLabel alloc] init];
    self.topicSubNameLabel.text = @" ";
    [self.contentView addSubview:self.topicSubNameLabel];
    
    UIImageView *arrowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowV;
    [self.contentView addSubview:arrowV];
    arrowV.hidden = YES;
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:self.lineView];
    
    self.topicImageView.layer.cornerRadius = 4;
    
    self.topicNameLabel.textColor = HEX_COLOR(0x525252);
    self.topicNameLabel.font = JA_MEDIUM_FONT(14);
    
    self.topicSubNameLabel.textColor = HEX_COLOR(0xFF8743);
    self.topicSubNameLabel.font = JA_REGULAR_FONT(11);
    self.topicSubNameLabel.backgroundColor = HEX_COLOR_ALPHA(0xFF8743, 0.05);
    self.topicSubNameLabel.edgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    
    if (type) {
        self.arrowImageView.hidden = NO;
    } else {
        self.arrowImageView.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCommonTopicCellFrame];
}

- (void)caculatorCommonTopicCellFrame
{
    self.topicImageView.width = 40;
    self.topicImageView.height = self.topicImageView.width;
    self.topicImageView.x = 15;
    self.topicImageView.centerY = self.contentView.height * 0.5;
    
    self.topicNameLabel.height = 17;
    self.topicNameLabel.x = self.topicImageView.right + 10;
    self.topicNameLabel.y = self.topicImageView.y;
    self.topicNameLabel.width = JA_SCREEN_WIDTH - self.topicNameLabel.x - 15;
    
    [self.topicSubNameLabel sizeToFit];
   
    self.topicSubNameLabel.height = 16;
    self.topicSubNameLabel.x = self.topicNameLabel.x;
    self.topicSubNameLabel.y = self.topicNameLabel.bottom + 7;
    self.topicSubNameLabel.layer.cornerRadius = self.topicSubNameLabel.height * 0.5;
    self.topicSubNameLabel.layer.masksToBounds = YES;
    if (self.topicSubNameLabel.right > JA_SCREEN_WIDTH - 15) {
        self.topicSubNameLabel.width = self.topicNameLabel.width;
    }
    self.lineView.x = self.topicImageView.x;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.y = self.contentView.height - 1;
    
    self.arrowImageView.width = 6;
    self.arrowImageView.height = 10;
    self.arrowImageView.centerY = self.topicImageView.centerY;
    self.arrowImageView.x = self.contentView.width - 20 - self.arrowImageView.width;
}


- (void)setModel:(JAVoiceTopicModel *)model
{
    _model = model;
    
    if (model.localImgName.length) {
        self.topicImageView.image = [UIImage imageNamed:model.localImgName];
    } else {
        self.topicImageView.image = nil;
        int h = 40;
        int w = 40;
        NSString *imageurl = [model.imgurl ja_getFillImageStringWidth:w height:h];
        [self.topicImageView ja_setImageWithURLStr:imageurl];
    }
    
    [self.topicNameLabel setAttributedText:[self attributedString:model.title wordArray:self.keyWordArr]];
    
    if (model.localTitle.length) {
         self.topicSubNameLabel.text = model.localTitle;
    } else {
        self.topicSubNameLabel.text = [NSString stringWithFormat:@"%@人参与讨论",model.discussCount];
    }
}

- (NSMutableAttributedString *)attributedString:(NSString *)text wordArray:(NSArray *)keyWordArr
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    for (NSInteger i = 0; i < keyWordArr.count; i++) {
        
        NSString *keyWord = keyWordArr[i];
        // 获取关键字的位置
        NSRange rang = [text rangeOfString:keyWord];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
    }
    
    return attr;
}
@end
