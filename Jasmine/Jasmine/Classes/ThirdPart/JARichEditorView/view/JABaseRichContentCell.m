//
//  JABaseRichContentCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseRichContentCell.h"

@implementation JABaseRichContentCell

- (UITableView*)containerTableView {
    UITableView* containerTableView = (UITableView*)self.superview;
    while (containerTableView != nil && ![containerTableView isKindOfClass:[UITableView class]]) {
        containerTableView = (UITableView*)containerTableView.superview;
    }
    return containerTableView;
}

- (void)handleReloadSelf {
    // 获取Container TableView
    UITableView* containerTableView = [self containerTableView];
    if (containerTableView) {
        NSIndexPath* indexPath = [containerTableView indexPathForCell:self];
        if (indexPath) {
            [containerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [containerTableView reloadData];
        }
    }
}

- (NSIndexPath*)curIndexPath {
    UITableView* containerTableView = [self containerTableView];
    NSIndexPath* indexPath = [containerTableView indexPathForCell:self];
    return indexPath;
}

- (void)updateWithData:(id)data {
    
}

@end
