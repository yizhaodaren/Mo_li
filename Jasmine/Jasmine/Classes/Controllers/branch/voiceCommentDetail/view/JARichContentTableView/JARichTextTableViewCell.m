//
//  JARichTextTableViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTextTableViewCell.h"
#import "KILabel.h"

@interface JARichTextTableViewCell ()

@property (nonatomic, strong) KILabel *desLabel;

@end

@implementation JARichTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        KILabel *desLabel = [KILabel new];
        desLabel.textColor = HEX_COLOR(0x545454);
        desLabel.font = JA_REGULAR_FONT(18);
        desLabel.numberOfLines = 0;
        desLabel.linkDetectionTypes = KILinkTypeOptionHashtag | KILinkTypeOptionUserHandle;
        [desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeHashtag];
        [desLabel setAttributes:@{NSForegroundColorAttributeName : HEX_COLOR(0x54C7FC)} forLinkType:KILinkTypeUserHandle];
        @WeakObj(self);
        desLabel.hashtagLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (string.length) {
                if (self.topicDetailBlock) {
                    self.topicDetailBlock(string);
                }
            }
        };
        desLabel.userHandleLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            @StrongObj(self);
            if (self.atPersonBlock) {
                self.atPersonBlock(string);
            }
        };
        [self.contentView addSubview:desLabel];
        self.desLabel = desLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat leftMargin = 15;
    CGFloat contentW = JA_SCREEN_WIDTH-30;
    self.desLabel.width = contentW;
    self.desLabel.x = leftMargin;
}

- (void)setData:(JARichTextModel *)data {
    _data = data;
    if (data) {
        NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:data.textContent];
        [finalStr addAttribute:NSFontAttributeName value:self.desLabel.font range:NSMakeRange(0, data.textContent.length)];
        [finalStr addAttribute:NSForegroundColorAttributeName value:self.desLabel.textColor range:NSMakeRange(0, data.textContent.length)];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init]; [paragraphStyle setLineSpacing:6];
        [finalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [data.textContent length])];
        self.desLabel.attributedText = finalStr;;
        self.desLabel.height = data.textContentHeight;
    }
}

@end
