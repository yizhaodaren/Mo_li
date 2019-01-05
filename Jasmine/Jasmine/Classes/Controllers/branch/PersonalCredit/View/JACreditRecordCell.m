//
//  JACreditRecordCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACreditRecordCell.h"

@interface JACreditRecordCell ()

@property (nonatomic, weak) UILabel *title_Label;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *dataLabel;
@property (nonatomic, weak) UIView *lineView;

//@property (nonatomic, strong) NSDictionary *typeDictionary;
@end

@implementation JACreditRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 注意这个字段 在model里面也写了
//        self.typeDictionary = @{
//                                @"story_comment_add" : @"每日发帖",
//                                @"login" : @"每日签到",
//                                @"story_or_comment_sort" : @"帖子被加为精华",
//                                @"god_comment" : @"评论被加为神回复",
//                                @"share_platform" : @"分享帖子到社交平台",
//
//                                @"del_story_comment_content_not" : @"内容因「内容表意不明」」被删除",
//                                @"del_story_comment_noise" : @"内容因「内容噪音过大」被删除",
//                                @"del_story_comment_pornographic" : @"内容因「含垃圾广告信息」、「含政治敏感信息」、「含低俗色情内容」、「含侮辱性词汇」被删除",
//                                @"del_story_comment_day" : @"一天内发布违规内容被删除过2次，再次发布违规内容被删除 信用分减分提升4倍",
//                                @"del_story_comment_week" : @"一周内发布违规内容被删除过10次，再次发布违规内容被删除 信用分减分提升8倍",
//                                @"del_story_comment_month" : @"三个月内发布违规内容被删除过50次，再次发布违规内容被删除 信用分扣0",
//                                };
        
        [self setupRecordCellUI];
    }
    return self;
}

- (void)setupRecordCellUI
{
    UILabel *title_Label = [[UILabel alloc] init];
    _title_Label = title_Label;
    title_Label.text = @"主帖被加为精华帖";
    title_Label.textColor = HEX_COLOR(JA_ListTitle);
    title_Label.font = JA_MEDIUM_FONT(14);
    title_Label.numberOfLines = 0;
    [self.contentView addSubview:title_Label];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"2017-10-23";
    timeLabel.textColor = HEX_COLOR(JA_ListTitle);
    timeLabel.font = JA_MEDIUM_FONT(14);
    [self.contentView addSubview:timeLabel];
    
    UILabel *dataLabel = [[UILabel alloc] init];
    _dataLabel = dataLabel;
    dataLabel.text = @"信用分 +1";
    dataLabel.textColor = HEX_COLOR(JA_ListTitle);
    dataLabel.font = JA_MEDIUM_FONT(14);
    dataLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:dataLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorRecordCellFrame];
}

- (void)caculatorRecordCellFrame
{
    self.title_Label.width = JA_SCREEN_WIDTH - 100 - 14;
    [self.title_Label sizeToFit];
    self.title_Label.width = JA_SCREEN_WIDTH - 100 - 14;
    self.title_Label.x = 14;
    self.title_Label.y = 5;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.title_Label.x;
    self.timeLabel.y = self.title_Label.bottom + 3;
    
    [self.dataLabel sizeToFit];
    self.dataLabel.width = 100 - 14;
    self.dataLabel.x = JA_SCREEN_WIDTH - 100;
    self.dataLabel.centerY = self.contentView.height * 0.5;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setRecordModel:(JACreditRecordModel *)recordModel
{
    _recordModel = recordModel;
    
    self.title_Label.text = recordModel.content;
    [self.title_Label sizeToFit];
    
    self.timeLabel.text = [NSString timeToString:recordModel.createTime];
    if (recordModel.actionType.integerValue == 1) {   // 增加
        
        self.dataLabel.text = [NSString stringWithFormat:@"信用分 +%@",recordModel.integralNum];
        self.dataLabel.textColor = HEX_COLOR(0x54C7FC);
    }else{     // 减少
        self.dataLabel.text = [NSString stringWithFormat:@"信用分 -%@",recordModel.integralNum];
        self.dataLabel.textColor = HEX_COLOR(0xFC7A56);
    }
    
    [self.dataLabel sizeToFit];
}
@end
