//
//  JASearchTopView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASearchTopView : UIView
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchCancleButton;

+ (instancetype)searchTopView;
@end
