//
//  JANewPlayerView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/7.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewPlayerView : UIImageView

- (void)beginAnimate;
- (void)stopAnimate;

- (void)playerView_animateAndHiddenWithViewControl:(UIViewController *)ViewControl;
- (void)playerView_animateAndHidden;
@end
