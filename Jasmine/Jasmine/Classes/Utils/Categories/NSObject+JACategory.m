//
//  NSObject+JACategory.m
//  Jasmine
//
//  Created by xujin on 25/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NSObject+JACategory.h"

@implementation NSObject (JACategory)

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                    completion:(void (^)(BOOL complete))completion {
    [self showAlertViewWithTitle:title subTitle:subTitle leftButtonTitle:@"取消" rightButtonTitle:@"确定" completion:completion];
}

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                   buttonTitle:(NSInteger)buttonTitleType
                    completion:(void (^)(BOOL complete))completion {
    
    if (buttonTitleType == 0) {
        [self showAlertViewWithTitle:title subTitle:subTitle leftButtonTitle:@"取消" rightButtonTitle:nil completion:completion];

    }else{
        
        [self showAlertViewWithTitle:title subTitle:subTitle leftButtonTitle:nil rightButtonTitle:@"确定" completion:completion];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
               leftButtonTitle:(NSString *)leftTitle
              rightButtonTitle:(NSString *)rightTitle
                    completion:(void (^)(BOOL complete))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    
    if (leftTitle.length) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(NO);
            }
        }];
        [alertController addAction:cancel];
    }
    if (rightTitle.length) {
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (completion) {
                completion(YES);
            }
        }];
        [alertController addAction:ok];
    }
    [[AppDelegateModel rootviewController] presentViewController:alertController animated:YES completion:nil];

}

- (NSArray *)playList_getNewListWithArray:(NSArray *)storyArray pageCount:(NSInteger)pageCount clickIndex:(NSInteger)clickIndex;
{
    if (storyArray.count == 0) {
        return nil;
    }
    
    if (pageCount == 0) {
        pageCount = 6;
    }
    
    // 计算当前点击的index 在该页面中的位置
    NSInteger listIndex = clickIndex % pageCount;
    
    // 找出需要的6条数据
    NSInteger beginNum = clickIndex - listIndex;
    NSInteger endNum = beginNum + (pageCount - 1);
    if (endNum > storyArray.count - 1) {
        endNum = storyArray.count - 1;
    }
    NSMutableArray *listNew = [NSMutableArray array];
    
    for (NSInteger i = beginNum; i <= endNum; i++) {
        
        id model = storyArray[i];
        [listNew addObject:model];
    }
    
    return listNew;
}
@end
