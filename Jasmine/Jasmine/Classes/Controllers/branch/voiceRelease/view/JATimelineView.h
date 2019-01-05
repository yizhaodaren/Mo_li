//
//  JATimelineView.h
//  Jasmine
//
//  Created by xujin on 04/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JATimelineView : UIView

@property (nonatomic, weak) UICollectionView *collectionView;

- (void)updateTimeProgress;
- (void)resetTimeProgress;

@end
