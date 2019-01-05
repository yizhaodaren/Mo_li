//
//  JAStoryTopicCollectionViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/7/12.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTopicCollectionViewCell.h"

@interface JAStoryTopicCollectionViewCell ()

@property (nonatomic, strong) UIImageView *topicImageView;
@property (nonatomic, strong) UILabel *topicNameLabel;
@property (nonatomic, strong) UILabel *topicSubNameLabel;

@end

@implementation JAStoryTopicCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [UIView new];
        contentView.layer.cornerRadius = 4.0;
        contentView.layer.masksToBounds = YES;
        contentView.layer.borderWidth = 1.0;
        contentView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
        [self addSubview:contentView];
        contentView.width = self.width;
        contentView.height = self.height;
        
        UIImageView *topicImageView = [UIImageView new];
//        topicImageView.backgroundColor = [UIColor blueColor];
        topicImageView.contentMode = UIViewContentModeScaleAspectFill;
        topicImageView.clipsToBounds = YES;
        [contentView addSubview:topicImageView];
        self.topicImageView = topicImageView;
        self.topicImageView.width = contentView.width;
        self.topicImageView.height = WIDTH_ADAPTER(90);
        
        UILabel *topicNameLabel = [UILabel new];
//        topicNameLabel.backgroundColor = [UIColor redColor];
        topicNameLabel.font = JA_REGULAR_FONT(14);
        topicNameLabel.textColor = HEX_COLOR(0x4A4A4A);
        topicNameLabel.numberOfLines = 2;
        topicNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [contentView addSubview:topicNameLabel];
        self.topicNameLabel = topicNameLabel;
        self.topicNameLabel.x = WIDTH_ADAPTER(10);
        self.topicNameLabel.y = self.topicImageView.bottom+WIDTH_ADAPTER(10);
        self.topicNameLabel.width = self.width-2*WIDTH_ADAPTER(10);
        
        UILabel *topicSubNameLabel = [UILabel new];
//        topicSubNameLabel.backgroundColor = [UIColor greenColor];
        topicSubNameLabel.font = JA_REGULAR_FONT(12);
        topicSubNameLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        [contentView addSubview:topicSubNameLabel];
        self.topicSubNameLabel = topicSubNameLabel;
        self.topicSubNameLabel.width = self.topicNameLabel.width;
        self.topicSubNameLabel.height = 17;
        self.topicSubNameLabel.x = self.topicNameLabel.x;
        self.topicSubNameLabel.bottom = self.bottom-WIDTH_ADAPTER(10);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setData:(JAVoiceTopicModel *)data {
    _data = data;
    if (data) {
        self.topicImageView.image = nil;
        if (data.imgurl.length) {
            int h = self.topicImageView.width;
            int w = self.topicImageView.height;
            NSString *imageurl = [data.imgurl ja_getFillImageStringWidth:w height:h];
            [self.topicImageView ja_setImageWithURLStr:imageurl];
        }
        self.topicNameLabel.text = data.title;
        CGSize size = [self.topicNameLabel.text sizeOfStringWithFont:self.topicNameLabel.font maxSize:CGSizeMake(self.topicNameLabel.width, 1000)];
        self.topicNameLabel.height = size.height;
//        [self.topicNameLabel sizeToFit];
//        self.topicNameLabel.width = self.width-2*WIDTH_ADAPTER(10);
        self.topicSubNameLabel.text = [NSString stringWithFormat:@"%@人参与",[NSString convertCountStr:data.discussCount]];
    }
}

@end
