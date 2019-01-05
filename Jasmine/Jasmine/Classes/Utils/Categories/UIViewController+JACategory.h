//
//  UIViewController+JACategory.h
//  Jasmine
//
//  Created by xujin on 24/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JACategory)

/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack.

/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
@property (nonatomic, assign) BOOL ja_prefersNavigationBarHidden;


@end
