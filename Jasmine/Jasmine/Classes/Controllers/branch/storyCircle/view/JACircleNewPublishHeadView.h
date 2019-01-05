//
//  JACircleNewPublishHeadView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JACircleNewPublishHeadView;
@protocol JACircleNewPublishHeadViewDelegate <NSObject>
- (void)circleNewPublishHeadView_didSelectWithRow:(NSInteger)row headView:(JACircleNewPublishHeadView *)headView;
@end
@interface JACircleNewPublishHeadView : UIView
@property (nonatomic, strong) NSString *circleName;
@property (nonatomic, strong) NSArray *topVoiceArray;  // 置顶帖数据源
@property (nonatomic, weak) id <JACircleNewPublishHeadViewDelegate> delegate;
@end
