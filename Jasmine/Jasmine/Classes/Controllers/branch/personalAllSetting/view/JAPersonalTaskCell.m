//
//  JAPersonalTaskCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalTaskCell.h"

@interface JAPersonalTaskCell ()

@property (nonatomic, weak) UILabel *title_label;
@property (nonatomic, weak) UILabel *subTitle_label;
@property (nonatomic, weak) UIImageView *finishImageView;
@property (nonatomic, weak) UIButton *awardButton;
@property (nonatomic, weak) UIButton *showAllButton;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIButton *goFinishButton;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JAPersonalTaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTaskCellUI];
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.backgroundColor = HEX_COLOR(0xF3F7F8);
        self.backgroundColor = HEX_COLOR(0xffffff);
    }
    return self;
}

- (void)setupTaskCellUI
{
    UILabel *title_label = [[UILabel alloc] init];
    _title_label = title_label;
    title_label.text = @" ";
    title_label.textColor = HEX_COLOR(JA_Title);
    title_label.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:title_label];
    
    UILabel *subTitle_label = [[UILabel alloc] init];
    _subTitle_label = subTitle_label;
    subTitle_label.text = @" ";
    subTitle_label.textColor = HEX_COLOR(0x222222);
    subTitle_label.font = JA_LIGHT_FONT(12);
    [self.contentView addSubview:subTitle_label];
    
    UIImageView *finishImageView = [[UIImageView alloc] init];
    _finishImageView = finishImageView;
    finishImageView.hidden = YES;
    finishImageView.image = [UIImage imageNamed:@"branch_task_finish"];
    [self.contentView addSubview:finishImageView];
    
    UIButton *awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _awardButton = awardButton;
    awardButton.userInteractionEnabled = NO;
    [awardButton setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal]; //
    [awardButton setTitle:@" " forState:UIControlStateNormal];
    [awardButton setTitleColor:HEX_COLOR(0xFC7A56) forState:UIControlStateNormal];
    awardButton.titleLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:awardButton];
    
    UIButton *showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showAllButton = showAllButton;
    [showAllButton setImage:[UIImage imageNamed:@"branch_task_downArrow"] forState:UIControlStateNormal];
    [showAllButton setImage:[UIImage imageNamed:@"branch_task_upArrow"] forState:UIControlStateSelected];
    [showAllButton addTarget:self action:@selector(showAllContent) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:showAllButton];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:bottomView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    contentLabel.font = JA_LIGHT_FONT(13);
    contentLabel.numberOfLines = 0;
    [bottomView addSubview:contentLabel];
    
    UIButton *goFinishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _goFinishButton = goFinishButton;
    goFinishButton.backgroundColor = HEX_COLOR(JA_Branch_Green);
    [goFinishButton setTitle:@"去完成" forState:UIControlStateNormal];
    [goFinishButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    goFinishButton.titleLabel.font = JA_MEDIUM_FONT(12);
    [goFinishButton addTarget:self action:@selector(jumpTypeVC) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:goFinishButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
//    lineView.backgroundColor = HEX_COLOR(0xDFEFEE);
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorTaskCellFrame];
}

- (void)caculatorTaskCellFrame
{
    [self.title_label sizeToFit];
    self.title_label.height = 14;
    self.title_label.x = 15;
    self.title_label.y = 18;
    
    [self.subTitle_label sizeToFit];
    self.subTitle_label.height = 14;
    self.subTitle_label.x = self.title_label.right;
    self.subTitle_label.y = self.title_label.y;
    
    self.finishImageView.width = 51;
    self.finishImageView.height = 30;
    self.finishImageView.centerY = self.title_label.centerY;
    self.finishImageView.x = self.subTitle_label.right + 5;
    
    [self.showAllButton sizeToFit];
    self.showAllButton.centerY = self.title_label.centerY;
    self.showAllButton.x = self.contentView.width - 18 - self.showAllButton.width;
    self.showAllButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    [self.awardButton sizeToFit];
    self.awardButton.centerY = self.title_label.centerY;
    self.awardButton.x = self.showAllButton.x - 17 - self.awardButton.width;
    [self.awardButton setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:4];
    
    self.bottomView.width = JA_SCREEN_WIDTH;
    self.bottomView.y = 50;
    
    self.goFinishButton.width = 55;
    self.goFinishButton.height = 25;
    self.goFinishButton.y = 5;
    self.goFinishButton.x = self.contentView.width - 20 - self.goFinishButton.width;
    self.goFinishButton.layer.cornerRadius = self.goFinishButton.height * 0.5;
    
    self.contentLabel.x = 15;
    self.contentLabel.y = 2;
    self.contentLabel.width = self.goFinishButton.x - self.contentLabel.x - 30;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.goFinishButton.x - self.contentLabel.x - 30;
    
    self.bottomView.height = self.contentLabel.bottom + 16;
    
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setModel:(JATaskRowModel *)model
{
    _model = model;
    
    self.title_label.text = model.taskTitle;
    self.subTitle_label.textColor = HEX_COLOR(0x222222);
    NSString *title = nil;
    if (model.taskFinishCount.integerValue == 0) {
//        title = @"(次数不限)";
        title = @" ";
    }else
    {
        if ([model.taskName isEqualToString:@"task_share_story"]) {
            
            if (model.userFinishCount.integerValue > 0 && model.userFinishCount.integerValue < model.taskFinishCount.integerValue) {
                
                NSString *string = [self getRefreshDate:model.userFinishTime.doubleValue];
                if (string.length) {
                    
                    // 展示时间
                    title = [NSString stringWithFormat:@"(%@)",string];
                    self.subTitle_label.textColor = HEX_COLOR(0xFC7A56);
                }else{
                    // 展示次数
//                    title = [NSString stringWithFormat:@"(%@/%@)",model.userFinishCount,model.taskFinishCount];
                    title = @" ";
                }
                
            }else{
                
                // 展示次数
//                title = [NSString stringWithFormat:@"(%@/%@)",model.userFinishCount,model.taskFinishCount];
                title = @" ";
            }
            
        }else if ([model.taskName isEqualToString:@"task_share_inviteurl"]){
            
            if (model.userFinishCount.integerValue > 0 && model.userFinishCount.integerValue < model.taskFinishCount.integerValue) {
                
                NSString *string = [self getRefreshDate:model.userFinishTime.doubleValue];
                if (string.length) {
                    
                    // 展示时间
                    title = [NSString stringWithFormat:@"(%@)",string];
                    self.subTitle_label.textColor = HEX_COLOR(0xFC7A56);
                }else{
                    // 展示次数
//                    title = [NSString stringWithFormat:@"(%@/%@)",model.userFinishCount,model.taskFinishCount];
                    title = @" ";
                }
                
            }else{
                
                // 展示次数
//                title = [NSString stringWithFormat:@"(%@/%@)",model.userFinishCount,model.taskFinishCount];
                title = @" ";
            }
        }else{
            
//            title = [NSString stringWithFormat:@"(%@/%@)",model.userFinishCount,model.taskFinishCount];
            title = @" ";
        }
        
        
    }
    self.subTitle_label.text = title;
    
    if (model.taskFinishCount.integerValue != 0 && model.userFinishCount.integerValue == model.taskFinishCount.integerValue) {
        
        self.finishImageView.hidden = NO;
    }else{
        self.finishImageView.hidden = YES;
    }
    
    
    // 2.5.0后展示新的任务奖励
    if (model.taskContentType.integerValue == 1) {  // 钱
        
        [self.awardButton setTitle:[NSString stringWithFormat:@"%@",model.taskContent] forState:UIControlStateNormal];
        [self.awardButton setTitleColor:HEX_COLOR(0xFC7A56) forState:UIControlStateNormal];
        [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal];
        
    }else if (model.taskContentType.integerValue == 2){  // 花
        
        [self.awardButton setTitle:[NSString stringWithFormat:@"%@",model.taskContent] forState:UIControlStateNormal];
        [self.awardButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
        [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
        
    }else {  // 不展示图标
        [self.awardButton setTitle:[NSString stringWithFormat:@"%@",model.taskContent] forState:UIControlStateNormal];
        [self.awardButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
        [self.awardButton setImage:nil forState:UIControlStateNormal];
    }
    
//    if (model.taskFinishCount.integerValue > 0) {
//        if (model.taskFlower.integerValue > 0) {
//            NSString *str = [NSString stringWithFormat:@"%ld",model.taskFlower.integerValue * model.taskFinishCount.integerValue];
//            [self.awardButton setTitle:[NSString stringWithFormat:@"+%@朵",str] forState:UIControlStateNormal];
//            [self.awardButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
//            [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
//        }
//
//        if (model.taskMoney.integerValue > 0) {
//            NSString *str = [NSString stringWithFormat:@"%ld",model.taskMoney.integerValue * model.taskFinishCount.integerValue];
//            [self.awardButton setTitle:[NSString stringWithFormat:@"+%@元",str] forState:UIControlStateNormal];
//            [self.awardButton setTitleColor:HEX_COLOR(0xFC7A56) forState:UIControlStateNormal];
//            [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal];
//        }
//    }else{
//        if (model.taskFlower.integerValue > 0) {
//
//            [self.awardButton setTitle:[NSString stringWithFormat:@"+%@朵",model.taskFlower] forState:UIControlStateNormal];
//            [self.awardButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
//            [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
//        }
//
//        if (model.taskMoney.integerValue > 0) {
//
//            [self.awardButton setTitle:[NSString stringWithFormat:@"+%@元",model.taskMoney] forState:UIControlStateNormal];
//            [self.awardButton setTitleColor:HEX_COLOR(0xFC7A56) forState:UIControlStateNormal];
//            [self.awardButton setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal];
//        }
//    }
    
    self.showAllButton.selected = model.unfold;
    
    self.contentLabel.text = model.taskDescription;
    
    if (model.taskOpenTitle.length) {
        
        self.goFinishButton.hidden = NO;
        [self.goFinishButton setTitle:model.taskOpenTitle forState:UIControlStateNormal];
    }else{
        self.goFinishButton.hidden = YES;
        [self.goFinishButton setTitle:@"暂定" forState:UIControlStateNormal];
    }
    
}

- (void)showAllContent
{
    if (self.showAllBlock) {
        self.showAllBlock(self);
    }
}

- (void)jumpTypeVC
{
    if (self.jumpvc) {
        self.jumpvc(self);
    }
}

- (NSString *)getRefreshDate:(CGFloat)timeDouble
{
    timeDouble = timeDouble/1000.0;   // 服务器 秒
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];  // 当前时间 秒
    double time = now - timeDouble;  // 两者时间差
    
    double totleTime = 3 * 60 * 60;
    
    double residueTime = totleTime - time;
    
    if (residueTime > 0) {
        // 获取小时
        int totalmin = residueTime / 60;
        
        int hour = totalmin / 60;
        int min = totalmin % 60;
        
        NSString *str = [NSString stringWithFormat:@"%d:%d后刷新",hour,min];
//        [NSString distanceTimeWithBeforeTime:10.0];
        return str;
    }else{
        return nil;
    }
}
@end
