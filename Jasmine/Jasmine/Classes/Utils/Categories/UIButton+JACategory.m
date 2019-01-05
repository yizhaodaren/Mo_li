
//
//  UIButton+JACategory.m
//  Jasmine
//
//  Created by xujin on 23/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "UIButton+JACategory.h"

static const void *kButtonHitTestEdgeInsets = &kButtonHitTestEdgeInsets;

@implementation UIButton (JACategory)

-(void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, kButtonHitTestEdgeInsets, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, kButtonHitTestEdgeInsets);
    if(value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) ||
        !self.enabled ||
        self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

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
        [self setImage:[UIImage imageWithColor:HEX_COLOR(JA_Line)] forState:UIControlStateNormal];
        return;
    }
    [self sd_setImageWithURL:[NSURL URLWithString:str2] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error);
        }
        if (!image) {
            [self setImage:[UIImage imageWithColor:HEX_COLOR(JA_Line)] forState:UIControlStateNormal];
        }
    }];
}

@end
