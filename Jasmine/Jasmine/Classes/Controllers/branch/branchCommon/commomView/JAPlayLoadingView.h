//
//  JAPlayLoadingView.h
//  Jasmine
//
//  Created by xujin on 07/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPlayLoadingView : UIView

@property (nonatomic, copy) void (^stateChangeBlock)(BOOL hidden);

+ (JAPlayLoadingView *)playLoadingViewWithType:(NSInteger)type;

- (void)setPlayLoadingViewHidden:(BOOL)hidden;

@end
