//
//  JASearchPostsCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/4.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASearchPostsCell.h"
#import "JANewVoiceModel.h"
#import <NSButton+WebCache.h>
@interface JASearchPostsCell ()

@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) UILabel *contentLabel;  // 标题
@property (nonatomic, weak) UILabel *sub_contentLabel;  // 描述
@property (nonatomic, weak) UILabel *desLabel;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JASearchPostsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSearchPostsCell];
        self.selectionStyle =UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupSearchPostsCell
{
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = playButton;
    playButton.userInteractionEnabled = NO;
    [playButton setImage:[UIImage imageNamed:@"branch_search_play"] forState:UIControlStateNormal];
    [self.contentView addSubview:playButton];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0x525252);
    contentLabel.font = JA_MEDIUM_FONT(14);
    contentLabel.numberOfLines = 1;
    [self.contentView addSubview:contentLabel];
    
    UILabel *sub_contentLabel = [[UILabel alloc] init];
    _sub_contentLabel = sub_contentLabel;
    sub_contentLabel.text = @" ";
    sub_contentLabel.textColor = HEX_COLOR(0x4a4a4a);
    sub_contentLabel.font = JA_REGULAR_FONT(12);
    sub_contentLabel.numberOfLines = 2;
    [self.contentView addSubview:sub_contentLabel];
    
    UILabel *desLabel = [[UILabel alloc] init];
    _desLabel = desLabel;
    desLabel.textColor = HEX_COLOR(0x9b9b9b);
    desLabel.text = @" ";
    desLabel.font = JA_REGULAR_FONT(11);
    [self.contentView addSubview:desLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorSearchPostsCellFrame];
}

- (void)caculatorSearchPostsCellFrame
{
    self.playButton.width = 60;
    self.playButton.height = self.playButton.width;
    self.playButton.layer.cornerRadius = 4;
    self.playButton.layer.masksToBounds = YES;
    self.playButton.x = self.contentView.width - 15 - self.playButton.width;
    self.playButton.centerY = self.contentView.height * 0.5;
    
    self.contentLabel.x = 15;
    self.contentLabel.y = self.playButton.y - 3;
    self.contentLabel.width = self.model.photos.firstObject || self.model.storyType == 0 ? self.playButton.x - self.contentLabel.x - 20 : self.contentView.width - 20;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.model.photos.firstObject || self.model.storyType == 0 ? self.playButton.x - self.contentLabel.x - 20 : self.contentView.width - 20;
    
    self.sub_contentLabel.width = self.contentLabel.width;
    [self.sub_contentLabel sizeToFit];
    self.sub_contentLabel.width = self.contentLabel.width;
    self.sub_contentLabel.x = self.contentLabel.x;
    self.sub_contentLabel.y = self.contentLabel.bottom + 3;
    
    
    self.desLabel.x = self.contentLabel.x;
    self.desLabel.height = 16;
    self.desLabel.width = self.contentLabel.width;
    self.desLabel.y = self.playButton.bottom - self.desLabel.height + 3;
    
    self.lineView.x = self.contentLabel.x;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JANewVoiceModel *)model
{
    _model = model;
    model.title = @"啥都好说电话是多少大神的多少多少多所多多少多少多所大声道是多少的速度是的";
    if (model.storyType) {
        JAVoicePhoto *photo = model.photos.firstObject;
        if (photo) {
            self.contentLabel.width = self.playButton.x - self.contentLabel.x - 20;
        }else{
            self.contentLabel.width = self.contentView.width - 20;
        }
        [self.playButton sd_setImageWithURL:[NSURL URLWithString:photo.src] forState:UIControlStateNormal];
    }else{
        self.contentLabel.width = self.playButton.x - self.contentLabel.x - 20;
        [self.playButton setImage:[UIImage imageNamed:@"branch_search_play"] forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (model.storyType) {   // 图文
        if (model.title.length) {
            self.sub_contentLabel.hidden = NO;
            [self.contentLabel setAttributedText:[self attributedString:model.title wordArray:self.keyWordArr]];
            [self.sub_contentLabel setAttributedText:[self attributedString:model.content wordArray:self.keyWordArr]];
        }else{
            self.sub_contentLabel.hidden = YES;
            [self.contentLabel setAttributedText:[self attributedString:model.content wordArray:self.keyWordArr]];
        }
    }else{  // 音频
        self.sub_contentLabel.hidden = YES;
        [self.contentLabel setAttributedText:[self attributedString:model.content wordArray:self.keyWordArr]];
    }
    
//    [self.contentLabel setAttributedText:[self attributedString:model.content wordArray:self.keyWordArr]];
    NSString *count = [NSString stringWithFormat:@"%ld",model.commentCount.integerValue];
    self.desLabel.text = [NSString stringWithFormat:@"喜欢 %@  回复 %@",model.agreeCount,count];
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

//- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
//{
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
//    
//    // 获取关键字的位置
//    NSRange rang = [text rangeOfString:keyWord];
//    
//    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
//    
//    return attr;
//}
@end
