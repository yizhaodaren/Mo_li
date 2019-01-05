//
//  JAMessageNoneView.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMessageNoneView : UIView

@property (nonatomic, copy) void(^loginBlock)(void);

- (void)show:(NSString *)topMsg
   bottomMsg:(NSString *)bottomMsg
   imageName:(NSString *)imageName
useLoginButton:(BOOL)useLoginButton;

@end
