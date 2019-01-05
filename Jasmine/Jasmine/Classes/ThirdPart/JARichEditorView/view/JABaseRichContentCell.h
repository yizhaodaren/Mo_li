//
//  JABaseRichContentCell.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JARichContentEditDelegate <NSObject>

@optional
- (void)ja_shouldHiddenActionButtons:(BOOL)shouldHidden;
- (BOOL)ja_shouldCellShowPlaceholder;

//- (void)ja_preInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
//- (void)ja_postInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent;
- (void)ja_preDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
//- (void)ja_PostDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath;
- (void)ja_updateActiveIndexPath:(NSIndexPath*)activeIndexPath;
- (void)ja_reloadItemAtIndexPath:(NSIndexPath*)actionIndexPath;
//- (void)ja_uploadFailedAtIndexPath:(NSIndexPath*)actionIndexPath;
//- (void)ja_uploadDonedAtIndexPath:(NSIndexPath*)actionIndexPath;

// 弹出话题页面
- (void)ja_pushSearchTopicVC;
// 弹出@人页面
- (void)ja_pushAtPersonVC;

@end

@interface JABaseRichContentCell : UITableViewCell

- (UITableView*)containerTableView;
- (NSIndexPath*)curIndexPath;
- (void)updateWithData:(id)data;

@end
