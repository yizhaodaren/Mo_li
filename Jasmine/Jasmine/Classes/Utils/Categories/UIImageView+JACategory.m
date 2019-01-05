
//
//  UIImageView+JACategory.m
//  Jasmine
//
//  Created by xujin on 16/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "UIImageView+JACategory.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation UIImageView (JACategory)

- (void)ja_setImageWithURLStr:(NSString *)urlStr {
    [self ja_setImageWithURLStr:urlStr placeholder:nil];
}

- (void)ja_setImageWithURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder {
    [self ja_setImageWithURLStr:urlStr placeholderImage:placeholder completed:nil];
}

- (void)ja_setImageWithURLStr:(NSString *)urlStr placeholderImage:(UIImage *)placeholder completed:(void(^)(UIImage *image, NSError *error))completedBlock {
    NSString *str1 = [urlStr stringByRemovingPercentEncoding];
    NSString *str2 = [str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (!str2.length) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:@"com.moli.jasmine" code:100000 userInfo:nil];
            completedBlock(nil, error);
        }
        return;
    }
    [self sd_setImageWithURL:[NSURL URLWithString:str2] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error);
        }
        if (!image) {
            self.image = placeholder?:[UIImage imageWithColor:HEX_COLOR(JA_Line)];
        }
    }];
}

@end
