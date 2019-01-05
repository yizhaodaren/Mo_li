//
//  JARichImageCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichImageCell.h"
#import "JARichImageModel.h"

@interface JARichImageCell ()

@property (nonatomic, strong) UIImageView *imageContentView;
@property (nonatomic, strong) JARichImageModel* imageModel;

@end

@implementation JARichImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [UIView new];
        bgView.layer.cornerRadius = 2.0;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = [HEX_COLOR(0xA1A1A1) CGColor];
        bgView.layer.borderWidth = 1.0;
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.offset(0);
            make.left.offset(15);
            make.right.offset(-15);
        }];
        
        UIImageView *imageContentView = [UIImageView new];
//        imageContentView.backgroundColor = [UIColor redColor];
        [bgView addSubview:imageContentView];
        [imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(5);
            make.bottom.offset(-5);
            make.centerX.equalTo(bgView.mas_centerX);
        }];
        self.imageContentView = imageContentView;
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"release_removephoto"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:deleteButton];
        [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgView.mas_top).offset(6);
            make.right.equalTo(bgView.mas_right).offset(-6);
        }];
    }
    return self;
}

- (void)updateWithData:(JARichImageModel *)data {
    _imageModel = data;
    self.imageContentView.image = _imageModel.image;
}

- (void)deleteButtonAction {
    if ([self.delegate respondsToSelector:@selector(ja_reloadItemAtIndexPath:)]) {
        [self.delegate ja_reloadItemAtIndexPath:[self curIndexPath]];
    }
}

@end
