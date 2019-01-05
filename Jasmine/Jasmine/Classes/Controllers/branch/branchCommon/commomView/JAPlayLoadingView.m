//
//  JAPlayLoadingView.m
//  Jasmine
//
//  Created by xujin on 07/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAPlayLoadingView.h"
#import <UIImage+GIF.h>

@interface JAPlayLoadingView()

@property (nonatomic, assign) NSInteger type;
//@property (nonatomic, strong) UIImageView *loadingIV;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIV;

@end

@implementation JAPlayLoadingView

// 0首页播放1通知页面邀请2回复和评论3首页底部播放
+ (JAPlayLoadingView *)playLoadingViewWithType:(NSInteger)type {
    CGRect rect = CGRectZero;
    switch (type) {
        case 0:
        {
            rect = CGRectMake(0, 0, 20, 20);
        }
            break;
        case 1:
        {
            rect = CGRectMake(0, 0, 16, 16);
        }
            break;
        case 2:
        {
            rect = CGRectMake(0, 0, 35, 35);
        }
            break;
        case 3:
        {
            rect = CGRectMake(0, 0, 20, 20);
        }
            break;
        default:
            break;
    }
    JAPlayLoadingView *view = [[JAPlayLoadingView alloc] initWithFrame:rect type:type];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.hidden = YES;
//        UIImageView *loadingIV = [UIImageView new];
        UIActivityIndicatorView *loadingIV = [UIActivityIndicatorView new];
//        loadingIV.backgroundColor = [UIColor greenColor];
//        loadingIV.width = loadingIV.height = 15;
        [self addSubview:loadingIV];
        self.loadingIV = loadingIV;
        
        switch (type) {
            case 0:
            {
                loadingIV.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                CGAffineTransform transform = CGAffineTransformMakeScale(.9f, .9f);
                loadingIV.transform = transform;
            }
                break;
            case 1:
            {
                loadingIV.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                CGAffineTransform transform = CGAffineTransformMakeScale(.7f, .7f);
                loadingIV.transform = transform;
            }
                break;
            case 2:
            {
                loadingIV.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                CGAffineTransform transform = CGAffineTransformMakeScale(.7f, .7f);
                loadingIV.transform = transform;
            }
                break;
            case 3:
            {
                loadingIV.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                CGAffineTransform transform = CGAffineTransformMakeScale(.7f, .7f);
                loadingIV.transform = transform;
            }
                break;
            default:
                break;
        }
        loadingIV.centerX = self.width/2.0;
        loadingIV.centerY = self.height/2.0;
    }
    return self;
}

- (void)setPlayLoadingViewHidden:(BOOL)hidden {
    self.hidden = hidden;
//    if (!hidden) {
//        if (self.type == 2) {
//            self.loadingIV.image = [UIImage sd_animatedGIFNamed:@"replyloading"];
//        } else {
//            self.loadingIV.image = [UIImage sd_animatedGIFNamed:@"voiceloading"];
//        }
//    }
    if (hidden) {
        [self.loadingIV stopAnimating];
    } else {
        [self.loadingIV startAnimating];
    }
    if (self.stateChangeBlock) {
        self.stateChangeBlock(hidden);
    }
}

@end
