//
//  UIImageView+JACategory.h
//  Jasmine
//
//  Created by xujin on 16/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (JACategory)

- (void)ja_setImageWithURLStr:(NSString *)urlStr;

- (void)ja_setImageWithURLStr:(NSString *)urlStr
                  placeholder:(UIImage *)placeholder;

- (void)ja_setImageWithURLStr:(NSString *)urlStr
             placeholderImage:(UIImage *)placeholder
                    completed:(void(^)(UIImage *image, NSError *error))completedBlock;

@end
