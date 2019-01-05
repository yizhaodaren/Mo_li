//
//  JAMayLikeView.h
//  Jasmine
//
//  Created by xujin on 2018/5/23.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAAlbumModel.h"

@interface JAMayLikeView : UIView

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, copy) void (^moreBlock)(void);
@property (nonatomic, copy) void (^seeAlbumBlock)(JAAlbumModel *model);

@end
