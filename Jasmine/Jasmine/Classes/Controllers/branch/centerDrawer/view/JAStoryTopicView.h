//
//  JAStoryTopicTableViewCell.h
//  Jasmine
//
//  Created by xujin on 2018/7/12.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceTopicModel.h"

@interface JAStoryTopicView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, copy) void (^loadMoreBlock)(void);
@property (nonatomic, weak) UIButton *loadMoreButton;
@property (nonatomic, copy) void (^moreBlock)(void);
@property (nonatomic, copy) void (^selectBlock)(JAVoiceTopicModel *topicModel);

@end
