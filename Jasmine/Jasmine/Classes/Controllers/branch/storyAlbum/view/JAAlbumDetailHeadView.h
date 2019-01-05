//
//  JAAlbumDetailHeadView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JAAlbumModel;
@interface JAAlbumDetailHeadView : UIView
@property (nonatomic, strong) JAAlbumModel *model;
@property (nonatomic, weak) UIButton *playButton;    // 播放
@property (nonatomic, weak) UIButton *shareButton;    // 分享
@property (nonatomic, weak) UIButton *collectButton;    // 收藏
@end
