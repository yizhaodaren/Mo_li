//
//  JADraftCell.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/22.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPostDraftModel.h"
#import "JANewPlayTool.h"

@interface JADraftCell : UITableViewCell

@property (nonatomic, strong) JAPostDraftModel *data;
@property (nonatomic, copy) void(^playBlock)(JADraftCell *cell);
@property (nonatomic, copy) void(^reuploadBlock)(JADraftCell *cell);
@property (nonatomic, copy) void(^deleteBlock)(JADraftCell *cell);

@end
