//
//  JADraftCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/22.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JADraftCell.h"
#import "JAReleasePostManager.h"
#import "NSString+Extention.h"
#import "JARichImageModel.h"

@interface JADraftCell ()

@property (nonatomic, strong) UIButton *playButton;    // 播放
@property (nonatomic, strong) UIImageView *storyImageView; // 主帖图片
@property (nonatomic, strong) UILabel *nameLabel;      // 帖子名称
@property (nonatomic, strong) UILabel *loadLabel;      // 上传结果
@property (nonatomic, strong) UIButton *againLoadButton;// 重试
@property (nonatomic, strong) UIButton *deleteButton;   // 删除
@property (nonatomic, strong) UIView *loadProcessView;  // 上传进度背景
@property (nonatomic, strong) UIView *lineView;  // 线
@end

@implementation JADraftCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupCellUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshUI) name:@"STKAudioPlayer_status" object:nil];
    }
    return self;
}

- (void)setupCellUI
{
    self.loadProcessView = [[UIView alloc] init];
    self.loadProcessView.backgroundColor = HEX_COLOR(0xE7FFEA);
    [self.contentView addSubview:self.loadProcessView];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"draft_play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"draft_pause"] forState:UIControlStateSelected];
    self.playButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playButton];
    self.playButton.hidden = YES;
    
    self.storyImageView = [UIImageView new];
    self.storyImageView.layer.cornerRadius = 3.0;
    self.storyImageView.layer.masksToBounds = YES;
    self.storyImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.storyImageView];
    self.storyImageView.hidden = YES;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = HEX_COLOR(0x454C57);
//    self.nameLabel.text = @"我当了小三怎么了？";
    self.nameLabel.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:self.nameLabel];
    
    self.loadLabel = [[UILabel alloc] init];
    self.loadLabel.textColor = HEX_COLOR(0xFF7054);
    self.loadLabel.font = JA_REGULAR_FONT(13);
    [self.contentView addSubview:self.loadLabel];
    
    self.againLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.againLoadButton.backgroundColor = HEX_COLOR(JA_Green);
    [self.againLoadButton setTitle:@"上传" forState:UIControlStateNormal];
    [self.againLoadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.againLoadButton.titleLabel.font = JA_REGULAR_FONT(12);
//    self.againLoadButton.layer.borderColor = HEX_COLOR(0x31C27C).CGColor;
//    self.againLoadButton.layer.borderWidth = 1;
    [self.againLoadButton addTarget:self action:@selector(againLoadAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.againLoadButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.backgroundColor = HEX_COLOR(0xEDEDED);
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = JA_REGULAR_FONT(12);
//    self.deleteButton.layer.borderColor = HEX_COLOR(0xC6C6C6).CGColor;
//    self.deleteButton.layer.borderWidth = 1;
    [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:self.lineView];
}

- (void)caculatorCellFrame
{
//    self.loadProcessView.width = 0;
    self.loadProcessView.height = self.contentView.height;
    
    self.playButton.width = 30;
    self.playButton.height = 30;
    self.playButton.x = 16;
    self.playButton.centerY = self.contentView.height * 0.5;
    
    self.storyImageView.frame = self.playButton.frame;

    self.againLoadButton.width = 55;
    self.againLoadButton.height = 25;
    self.againLoadButton.x = self.contentView.width - 80 - self.againLoadButton.width;
    self.againLoadButton.centerY = self.playButton.centerY;
    self.againLoadButton.layer.cornerRadius = self.againLoadButton.height * 0.5;
    self.againLoadButton.layer.masksToBounds = YES;
    
    self.nameLabel.x = self.playButton.right + 10;
    self.nameLabel.y = 14;
    self.nameLabel.width = self.againLoadButton.left - self.nameLabel.x - 10;
    self.nameLabel.height = 22;
    
    self.loadLabel.width = self.nameLabel.width;
    self.loadLabel.height = 18;
    self.loadLabel.x = self.nameLabel.x;
    self.loadLabel.y = self.nameLabel.bottom + 5;
    
    self.deleteButton.width = self.againLoadButton.width;
    self.deleteButton.height = self.againLoadButton.height;
    self.deleteButton.x = self.contentView.width - 15 - self.againLoadButton.width;
    self.deleteButton.centerY = self.playButton.centerY;
    self.deleteButton.layer.cornerRadius = self.againLoadButton.height * 0.5;
    self.deleteButton.layer.masksToBounds = YES;
    
    self.lineView.width = self.contentView.width;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setData:(JAPostDraftModel *)data {
    if (data) {
        _data = data;
        
        NSString *title = @"标题为空";
        if (data.storyType == 0) {
            if (data.content.length) {
                title = data.content;
            }
        } else if (data.storyType == 1) {
            if (data.titleModel.textContent.length) {
                title = data.titleModel.textContent;
            }
        }
        self.nameLabel.text = title;
        
        JAPostDraftModel *currentDraftModel = [JAReleasePostManager shareInstance].postDraftModel;
        if (currentDraftModel.rowid == data.rowid) {
            data.uploadState = currentDraftModel.uploadState;
            data.progress = currentDraftModel.progress;
        }
        
        if (data.uploadState == JAUploadUploadingState) {
            self.againLoadButton.hidden = YES;
            self.deleteButton.hidden = YES;
//            self.loadProcessView.width = data.progress*self.contentView.width;
            
            self.loadLabel.text = [NSString stringWithFormat:@"上传%d%%...",(int)(data.progress*100)];
            self.loadLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        } else {
            self.againLoadButton.hidden = NO;
            self.deleteButton.hidden = NO;
            self.loadProcessView.width = 0;

            if (data.dataType == 0) {
                [self.againLoadButton setTitle:@"上传" forState:UIControlStateNormal];
                
                self.loadLabel.text = @"上传失败";
                self.loadLabel.textColor = HEX_COLOR(0xED1010);
            } else if (data.dataType == 1) {
                [self.againLoadButton setTitle:@"编辑" forState:UIControlStateNormal];
               
                self.loadLabel.text = [NSString draftdateToString:data.createTime];
                self.loadLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
            } else if (data.dataType == 2) {
                [self.againLoadButton setTitle:@"编辑" forState:UIControlStateNormal];
                
                self.loadLabel.text = @"标题含敏感信息，请重新编辑！";
                self.loadLabel.textColor = HEX_COLOR(0xED1010);
            }
        }
        
        // 播放按钮状态
        [self updatePlayButtonUI];
        
        __block UIImage *image = nil;
        NSMutableArray *imageArray = nil;
        if (data.storyType == 0) {
            self.playButton.hidden = NO;
            self.storyImageView.hidden = YES;
            
            if (data.imageInfoArray) {
                imageArray = data.imageInfoArray;
            }
        } else if (data.storyType == 1) {
            self.playButton.hidden = YES;
            self.storyImageView.hidden = NO;
            if (data.richContentModels) {
                imageArray = data.richContentModels;
            }
        }
        [imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                JARichImageModel *model = (JARichImageModel *)obj;
                if (!model.remoteImageUrlString.length) {
                    NSString *localFilePath = [NSString ja_getUploadImageFilePath:model.localImageName];
                    UIImage *img = [[UIImage alloc] initWithContentsOfFile:localFilePath];
                    if (img) {
                        image = img;
                        *stop = YES;
                    }
                }
            }
        }];
        if (image) {
            self.storyImageView.image = image;
        } else {
            self.storyImageView.image = [UIImage imageNamed:@"draft_notadd"];
        }
    }
}

- (void)playAction {
    if (self.playBlock) {
        self.playBlock(self);
    }
}

- (void)againLoadAction {
    if (self.reuploadBlock) {
        self.reuploadBlock(self);
    }
}

- (void)deleteAction {
    if (self.deleteBlock) {
        self.deleteBlock(self);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCellFrame];
}

#pragma mark - 波形图通知
- (void)playStatus_refreshUI   // 状态变化
{
    // 获取播放器的状态
    [self updatePlayButtonUI];
}
- (void)updatePlayButtonUI {
    NSString *draftId = self.data.draftId.length?self.data.draftId:[NSString stringWithFormat:@"%d",(int)self.data.rowid];
    if ([[JANewPlayTool shareNewPlayTool].currentMusic.storyId isEqualToString:draftId]) {
        NSInteger status = [JANewPlayTool shareNewPlayTool].playType;
        if (status == 0) {
            self.playButton.selected = NO;
        }else if (status == 1){
            self.playButton.selected = YES;
        }else if (status == 2){
            self.playButton.selected = NO;
        }else if (status == 3){
        }
    }else{
        self.playButton.selected = NO;
    }
}

@end
