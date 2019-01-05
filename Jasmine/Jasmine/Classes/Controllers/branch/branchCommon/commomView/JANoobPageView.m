//
//  JANoobPageView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/27.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANoobPageView.h"

@interface JANoobPageView ()

@property (nonatomic, weak) UIImageView *knowImageView;

@property (nonatomic, strong) NSMutableArray *actionImageViewArray;
@property (nonatomic, strong) NSMutableArray *helpImageViewArray;
@property (nonatomic, strong) NSMutableArray *typeArray;

@property (nonatomic, strong) NSPointerArray *array;
@end

@implementation JANoobPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        _actionImageViewArray = [NSMutableArray array];
        _helpImageViewArray = [NSMutableArray array];
        _typeArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.7);
    
    if (!iPhone5) {
        
        UIImageView *knowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noob_know"]];
        _knowImageView = knowImageView;
        knowImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickKnowButton)];
        [knowImageView addGestureRecognizer:tap];
        [self addSubview:knowImageView];
    }
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickKnowButton)];
    
    [self addGestureRecognizer:tap1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.knowImageView.centerX = self.width * 0.5;
    self.knowImageView.y = self.height - WIDTH_ADAPTER(50) - self.knowImageView.height;
}

- (void)converLocation:(NSPointerArray *)viewArray rectView:(NSPointerArray *)rectViewArray images:(NSArray <NSString *> *)imagesArray type:(NSArray *)typeArray
{
    [_typeArray addObjectsFromArray:typeArray];   //  _typeArray
    
    // 获取需要转换坐标的控件  --  _actionImageViewArray
    for (NSInteger i = 0; i < viewArray.count; i++) {
        
        UIView *view = [viewArray pointerAtIndex:i];
        
        UIView *rectView = [rectViewArray pointerAtIndex:i];
        
        CGRect rect = [view convertRect:rectView.frame toView:self];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagesArray[i]]];
        imageView.centerX = rect.origin.x + rect.size.width * 0.5;
        imageView.centerY = rect.origin.y + rect.size.height * 0.5;
        
        [_actionImageViewArray addObject:imageView];
        
    }
    
    // 根据类型判断需要什么样的描述  ---    _helpImageViewArray
    for (NSInteger i = 0; i < typeArray.count; i++) {
        
        JANoobPageType type = [typeArray[i] integerValue];
        
        UIImage *image = nil;
        
        if (type == JANoobPageTypePersonCenter) {
            image = [UIImage imageNamed:@"noob_personCenter_arrow"];
        }else if (type == JANoobPageTypePostsVoice){
            image = [UIImage imageNamed:@"noob_postsVoice_arrow"];
        }else if (type == JANoobPageTypeAgreeVoice){
            image = [UIImage imageNamed:@"noob_agree_arrow"];
        }else if (type == JANoobPageTypePersonTask){
            image = [UIImage imageNamed:@"noob_task_arrow"];
        }else if (type == JANoobPageTypeHelpCenter){
            image = [UIImage imageNamed:@"noob_help_arrow"];
        }else if (type == JANoobPageTypePersonPage){
            image = [UIImage imageNamed:@"noob_personPage_arrow"];
        }else if (type == JANoobPageTypePersonLevel){
            image = [UIImage imageNamed:@"noob_level_arrow"];
        }
        
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [_helpImageViewArray addObject:imageView];
        }
        
    }
    
}

- (void)showNoob
{
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1) {
        [self removeFromSuperview];
        return;
    }
    
    if (!_typeArray.count) {
        
        [self removeFromSuperview];
        
        return;
    }
    
    JANoobPageType type = [_typeArray.firstObject integerValue];
    
    
    if (type == JANoobPageTypePersonCenter) {
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _helpImageViewArray[0];
        
        view2.x = view1.right - 26;
        view2.y = view1.bottom - 10;
        
        [self addSubview:view1];
        [self addSubview:view2];
        
    }else if (type == JANoobPageTypePostsVoice){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _helpImageViewArray[0];
        
        view2.x = view1.x - view2.width + 40;
        view2.y = view1.bottom - 10;
        
        [self addSubview:view1];
        [self addSubview:view2];
        
    }else if (type == JANoobPageTypeAgreeVoice){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _actionImageViewArray[0 + 1];
        UIView *view3 = _helpImageViewArray[0];
        
        CGFloat w = view3.width;
        CGFloat h = view3.height;
        
        view3.x = view1.right;
        view3.y = view1.centerY;
        view3.height = view2.y - view1.centerY;
        view3.width = w * view3.height / h;
        
        [self addSubview:view1];
        [self addSubview:view2];
        [self addSubview:view3];
    }else if (type == JANoobPageTypePersonTask){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _helpImageViewArray[0];
        
        view1.x = view1.x - 20;
        
        view2.x = view1.centerX - 15;
        view2.y = view1.y - view2.height;
        
        [self addSubview:view1];
        [self addSubview:view2];
    }else if (type == JANoobPageTypeHelpCenter){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _helpImageViewArray[0];
        
        view1.x = view1.x - 40;
        
        view2.x = view1.centerX - 15;
        view2.y = view1.y - view2.height;
        
        [self addSubview:view1];
        [self addSubview:view2];
    }else if (type == JANoobPageTypePersonPage){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _helpImageViewArray[0];
        
        view2.centerX = view1.right;
        view2.y = view1.bottom - 10;
        
        [self addSubview:view1];
        [self addSubview:view2];
    }else if (type == JANoobPageTypePersonLevel){
        
        UIView *view1 = _actionImageViewArray[0];
        UIView *view2 = _actionImageViewArray[0 + 1];
        UIView *view3 = _helpImageViewArray[0];
        
        view1.y = view1.y + 35;

        view2.y = view2.y + 35;
      
        view3.x = view1.x + 10;
        view3.y = view1.bottom;
        
        [self addSubview:view1];
        [self addSubview:view2];
        [self addSubview:view3];
    }
    
}

- (void)clickKnowButton
{
    
    for (UIView *view in self.subviews) {
        
        if (view != self.knowImageView) {
            [view removeFromSuperview];
        }
    }
    
    JANoobPageType type = [_typeArray.firstObject integerValue];
    [_typeArray removeObjectAtIndex:0];
    [_helpImageViewArray removeObjectAtIndex:0];
    if (type == JANoobPageTypePersonCenter) {
        [_actionImageViewArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobHomeKey"];
    }else if (type == JANoobPageTypePostsVoice){
        [_actionImageViewArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobHomeKey"];
    }else if (type == JANoobPageTypeAgreeVoice){
//        [_actionImageViewArray removeObjectAtIndex:0];
//        [_actionImageViewArray removeObjectAtIndex:0];
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:0];
        [set addIndex:1];
        [_actionImageViewArray removeObjectsAtIndexes:set];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobHomeKey"];
    }else if (type == JANoobPageTypePersonTask){
        [_actionImageViewArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobPersonKey"];
    }else if (type == JANoobPageTypeHelpCenter){
        [_actionImageViewArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobPersonKey"];
    }else if (type == JANoobPageTypePersonPage){
        [_actionImageViewArray removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobPersonKey"];
    }else if (type == JANoobPageTypePersonLevel){
//        [_actionImageViewArray removeObjectAtIndex:0];
//        [_actionImageViewArray removeObjectAtIndex:0];
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:0];
        [set addIndex:1];
        [_actionImageViewArray removeObjectsAtIndexes:set];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JANoobLevelKey"];
    }
    
    [self showNoob];
}
@end
