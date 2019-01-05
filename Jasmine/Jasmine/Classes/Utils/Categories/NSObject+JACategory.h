//
//  NSObject+JACategory.h
//  Jasmine
//
//  Created by xujin on 25/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JACategory)

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                    completion:(void (^)(BOOL complete))completion;

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                   buttonTitle:(NSInteger)buttonTitleType
                    completion:(void (^)(BOOL complete))completion;  // buttonTitleType 0 : 取消  1 ： 确定

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
               leftButtonTitle:(NSString *)leftTitle
               rightButtonTitle:(NSString *)rightTitle
                    completion:(void (^)(BOOL complete))completion;

- (NSArray *)playList_getNewListWithArray:(NSArray *)storyArray pageCount:(NSInteger)pageCount clickIndex:(NSInteger)clickIndex;
@end
