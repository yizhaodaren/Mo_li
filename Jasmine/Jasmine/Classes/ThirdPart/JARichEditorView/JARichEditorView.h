//
//  JARichEditorView.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//
/*
    该图文混排编辑器是基于tableview实现的，主要思路如下
    1、根据数据类型创建不同的model和cell
    2、插入图片时，还要追加一个textCell（三种情况，头尾中间插入）
    3、删除图片时，主要是合并textCell（两种情况，叉号删除和键盘回退删除）
 */

#import <UIKit/UIKit.h>
#import "JARichTitleModel.h"

@interface JARichEditorView : UIView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JARichTitleModel* titleModel;
@property (nonatomic, strong) NSMutableArray* datas;
@property (nonatomic, copy) void(^hiddenActionButtons)(BOOL hidden);
@property (nonatomic, copy) void(^pushSearchTopicVC)(void);
@property (nonatomic, copy) void(^pushAtPersonVC)(void);

- (void)ja_becomeFirstResponder;
// 添加一张图片
- (void)handleInsertImage:(UIImage*)image;
// 追加@和话题
- (void)appendText:(NSString *)text;
- (NSInteger)addImageCount;

@end
