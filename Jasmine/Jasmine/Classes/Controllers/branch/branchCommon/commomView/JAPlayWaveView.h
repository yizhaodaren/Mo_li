//
//  JAPlayWaveView.h
//  Jasmine
//
//  Created by xujin on 30/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPlayWaveView : UIView

@property (nonatomic, assign) BOOL isAnimation;

- (void)startAnimation;
- (void)stopAnimation;

@end
