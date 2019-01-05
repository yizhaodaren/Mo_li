//
//  JARichEditorView.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichEditorView.h"
#import "JARichTextModel.h"
#import "JARichImageModel.h"
#import "JARichTitleCell.h"
#import "JARichTextCell.h"
#import "JARichImageCell.h"
#import "JARichContentUtil.h"
#import "UIImage+JACategory.h"

@interface JARichEditorView () <
UITableViewDelegate,
UITableViewDataSource,
JARichContentEditDelegate
>

@property (nonatomic, strong) NSIndexPath *activeIndexPath;

@end

@implementation JARichEditorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        // register cell
        [self.tableView registerClass:JARichTitleCell.class forCellReuseIdentifier:NSStringFromClass(JARichTitleCell.class)];
        [self.tableView registerClass:JARichTextCell.class forCellReuseIdentifier:NSStringFromClass(JARichTextCell.class)];
        [self.tableView registerClass:JARichImageCell.class forCellReuseIdentifier:NSStringFromClass(JARichImageCell.class)];
        
        [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ja_becomeFirstResponder)]];

        self.titleModel = [JARichTitleModel new];
        self.datas = [NSMutableArray array];
        [self.datas addObject:[JARichTextModel new]];
    }
    return self;
}

#pragma mark - public
- (void)ja_becomeFirstResponder {
    NSIndexPath *lastIndexPath;
    if (self.activeIndexPath) {
        lastIndexPath = self.activeIndexPath;
    } else {
        lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
    if ([cell isKindOfClass:[JARichTextCell class]]) {
        [((JARichTextCell*)cell) ja_beginEditing];
    }
}

// 追加@和话题
- (void)appendText:(NSString *)text {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.activeIndexPath];
    id model = _datas[self.activeIndexPath.row];
    if ([cell isKindOfClass:[JARichTextCell class]] && [model isKindOfClass:[JARichTextModel class]]) {
        JARichTextCell *textCell = (JARichTextCell *)cell;
        JARichTextModel *textModel = (JARichTextModel *)model;
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:textModel.textContent];
        [mutableString insertString:text atIndex:textCell.textView.selectedRange.location];
        textModel.textContent = mutableString;
        textModel.selectedRange = NSMakeRange(textCell.textView.selectedRange.location+text.length,textCell.textView.selectedRange.length);
        textModel.shouldUpdateSelectedRange = YES;
        // 因再次进入页面会调用弹起键盘，不需要调用下面方法
//        [self.tableView reloadRowsAtIndexPaths:@[self.activeIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

// 插入图片
- (void)handleInsertImage:(UIImage *)image {
    if (!_activeIndexPath) {
        _activeIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_activeIndexPath];
    if ([cell isKindOfClass:[JARichTextCell class]]) {
        // 处理文本节点
        // 根据光标拆分文本节点
        BOOL isPre = NO;
        BOOL isPost = NO;
        NSArray *splitedTexts = [((JARichTextCell*)cell) splitedTextArrWithPreFlag:&isPre postFlag:&isPost];
        // 前面优先级更高，需要调整优先级，调整if语句的位置即可
        if (isPre) {
            // textview头部插入图片
            // text (新增)/image (新增)/text (原,光标位置)
            [self addTextNodeAtIndexPath:_activeIndexPath textContent:nil];
            [self addImageNodeAtIndexPath:[NSIndexPath indexPathForRow:_activeIndexPath.row + 1 inSection:_activeIndexPath.section] image:image];
            // 重新获取焦点
            NSIndexPath *nextTextIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 2 inSection:_activeIndexPath.section];
            [self positionAtIndex:nextTextIndexPath];
        } else if (isPost) {
            // textview尾部插入图片
            // text (原)/image (新增)/text (新增,光标位置)
            NSIndexPath *nextImageIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 1 inSection:_activeIndexPath.section];
            [self addImageNodeAtIndexPath:nextImageIndexPath image:image];
            NSIndexPath *nextTextIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 2 inSection:_activeIndexPath.section];
            [self addTextNodeAtIndexPath:nextTextIndexPath textContent:nil];
            // 重新获取焦点
            [self positionAtIndex:nextTextIndexPath];
        } else {
            // textview中间插入图片
            // 替换当前节点，添加Text/image/Text，光标移动到图片节点上
            NSInteger tmpActiveIndexRow = _activeIndexPath.row;
            NSInteger tmpActiveIndexSection = _activeIndexPath.section;
            [self deleteItemAtIndexPath:_activeIndexPath shouldPositionPrevious:NO];
            if (splitedTexts.count == 2) {
                // 第一段文字
                [self addTextNodeAtIndexPath:_activeIndexPath textContent:[splitedTexts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                // 图片
                [self addImageNodeAtIndexPath:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 1 inSection:tmpActiveIndexSection] image:image];
                // 第二段文字
                [self addTextNodeAtIndexPath:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 2 inSection:tmpActiveIndexSection] textContent:[splitedTexts.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                // 重新获取焦点
                [self positionAtIndex:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 2 inSection:tmpActiveIndexSection]];
            }
        }
    }
}

- (NSInteger)addImageCount {
    NSInteger imageCount = 0;
    for (id obj in self.datas) {
        if ([obj isKindOfClass:[JARichImageModel class]]) {
            imageCount++;
        }
    }
    return imageCount;
}

#pragma mark - privite
- (void)addImageNodeAtIndexPath:(NSIndexPath*)indexPath image:(UIImage*)image {
    UIImage *scaledImage = [image ja_getScaleImage];
    NSString *scaledImageStoreName = [JARichContentUtil saveImageToLocal:image];
    if (scaledImageStoreName == nil || scaledImageStoreName.length <= 0) {
        // 提示出错
        return;
    }
    JARichImageModel *imageModel = [JARichImageModel new];
    imageModel.image = scaledImage;
    imageModel.localImageName = scaledImageStoreName;
    imageModel.imageContentHeight = scaledImage.size.height;
    imageModel.imageSize = image.size;
//    // 添加到上传队列中
//    [[MMFileUploadUtil sharedInstance] addUploadItem:imageModel];

    [self.tableView beginUpdates];
    [_datas insertObject:imageModel atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)addTextNodeAtIndexPath:(NSIndexPath*)indexPath textContent:(NSString*)textContent {
    JARichTextModel *textModel = [JARichTextModel new];
    textModel.textContent = [textContent isEqualToString:@"\n"] ? @"" : textContent == nil ? @"" : textContent;
    textModel.textContentHeight = [JARichContentUtil computeHeightInTextVIewWithContent:textModel.textContent];

    [self.tableView beginUpdates];
    [_datas insertObject:textModel atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)deleteItemAtIndexPathes:(NSArray<NSIndexPath*>*)actionIndexPathes shouldPositionPrevious:(BOOL)shouldPositionPrevious {
    if (actionIndexPathes.count > 0) {
        // 处理删除
        for (NSInteger i = actionIndexPathes.count - 1; i >= 0; i--) {
            NSIndexPath *actionIndexPath = actionIndexPathes[i];
            id obj = _datas[actionIndexPath.row];
            if ([obj isKindOfClass:[JARichImageModel class]]) {
                [JARichContentUtil deleteImageContent:(JARichImageModel*)obj];
            }
            [_datas removeObjectAtIndex:actionIndexPath.row];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:actionIndexPathes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        //  定位动到上一行
        if (shouldPositionPrevious) {
            [self positionToPreItemAtIndexPath:actionIndexPathes.firstObject];
        }
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath*)actionIndexPath shouldPositionPrevious:(BOOL)shouldPositionPrevious {
    // 处理删除
    [_datas removeObjectAtIndex:actionIndexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:actionIndexPath.row inSection:actionIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

// 定位到指定的元素
- (void)positionAtIndex:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[JARichTextCell class]]) {
        [((JARichTextCell*)cell) ja_beginEditing];
    }
}

// 定位到上一行
- (void)positionToPreItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
    [self positionAtIndex:preIndexPath];
}

- (void)handleReloadItemAdIndexPath:(NSIndexPath*)indexPath {
    // 理论上第一行不能是imageCell
    if (indexPath.row > 0) {
        NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        if (preIndexPath.row < _datas.count) {
            id preData = _datas[preIndexPath.row];
            if ([preData isKindOfClass:[JARichTextModel class]]) {
                NSIndexPath *nextIndexPath = nil;
                if (indexPath.row < _datas.count - 1) {
                    nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                }
                if (nextIndexPath) {
                    if (nextIndexPath.row < _datas.count) {
                        id nextData = _datas[nextIndexPath.row];
                        if ([nextData isKindOfClass:[JARichTextModel class]]) {
                            // Image节点-后面-上面为Text-下面为Text：删除Image节点，合并下面的Text到上面，删除下面Text节点，定位到上面元素的后面
                            ((JARichTextModel*)preData).textContent = [NSString stringWithFormat:@"%@\n%@", ((JARichTextModel*)preData).textContent, ((JARichTextModel*)nextData).textContent];
                            ((JARichTextModel*)preData).textContentHeight = [JARichContentUtil computeHeightInTextVIewWithContent:((JARichTextModel*)preData).textContent];
                            ((JARichTextModel*)preData).selectedRange = NSMakeRange(((JARichTextModel*)preData).textContent.length, 0);
                            ((JARichTextModel*)preData).shouldUpdateSelectedRange = YES;
                            [self deleteItemAtIndexPathes:@[indexPath, nextIndexPath] shouldPositionPrevious:YES];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - JARichContentEditDelegate
// 键盘回退删除图片
- (void)ja_preDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
    if (preIndexPath) {
        [self handleReloadItemAdIndexPath:preIndexPath];        
    }
}

- (void)ja_updateActiveIndexPath:(NSIndexPath*)activeIndexPath {
    self.activeIndexPath = activeIndexPath;
}

// 点击叉号删除图片
- (void)ja_reloadItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    [self handleReloadItemAdIndexPath:actionIndexPath];
}

- (void)ja_shouldHiddenActionButtons:(BOOL)shouldHidden {
    if (self.hiddenActionButtons) {
        self.hiddenActionButtons(shouldHidden);
    }
}

- (BOOL)ja_shouldCellShowPlaceholder {
    return [JARichContentUtil shouldShowPlaceHolderFromRichContents:self.datas];
}

- (void)ja_pushSearchTopicVC {
    if (self.pushSearchTopicVC) {
        self.pushSearchTopicVC();
    }
}

- (void)ja_pushAtPersonVC {
    if (self.pushAtPersonVC) {
        self.pushAtPersonVC();
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Title
    if (section == 0) {
        return 1;
    }
    // Content
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return _titleModel.cellHeight;
    } else if (indexPath.section == 1) {
        id obj = _datas[indexPath.row];
        if ([obj isKindOfClass:[JARichTextModel class]]) {
            JARichTextModel *textModel = (JARichTextModel*)obj;
            return textModel.textContentHeight;
        } else if ([obj isKindOfClass:[JARichImageModel class]]) {
            JARichImageModel *imageModel = (JARichImageModel*)obj;
            return imageModel.imageContentHeight;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Title
    if (indexPath.section == 0) {
        JARichTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JARichTitleCell.class)];
        cell.delegate = self;
        [cell updateWithData:_titleModel];
        return cell;
    }
    // Content
    id obj = _datas[indexPath.row];
    if ([obj isKindOfClass:[JARichTextModel class]]) {
        JARichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JARichTextCell.class)];
        cell.delegate = self;
        [cell updateWithData:obj];
        return cell;
    }
    if ([obj isKindOfClass:[JARichImageModel class]]) {
        JARichImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JARichImageCell.class)];
        cell.delegate = self;
        [cell updateWithData:obj];
        return cell;
    }
    static NSString *cellID = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
