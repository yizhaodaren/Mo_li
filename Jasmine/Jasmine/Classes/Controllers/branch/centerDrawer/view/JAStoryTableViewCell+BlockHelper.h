//
//  JAStoryTableViewCell+BlockHelper.h
//  Jasmine
//
//  Created by xujin on 2018/5/30.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTableViewCell.h"
#import "JANewVoiceModel.h"

@interface JAStoryTableViewCell (BlockHelper)

- (void)setupCommonBlockWithModel:(JANewVoiceModel *)voice superVC:(UIViewController *)superVC;

@end
