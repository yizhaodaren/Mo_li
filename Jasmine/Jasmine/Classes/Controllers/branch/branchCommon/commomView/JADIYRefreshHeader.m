//
//  JADIYRefreshHeader.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JADIYRefreshHeader.h"
#import "JADIYBottomView.h"
#import <UIImage+GIF.h>

//#import "SVGA.h"  // 新

@interface JADIYRefreshHeader ()
//<SVGAPlayerDelegate>
@property (nonatomic, weak) UIImageView *juHuaImageView;
//@property (nonatomic, weak) UILabel *nameLabel;
//@property (nonatomic, weak) JADIYBottomView *diyBottom;

@property (nonatomic, weak) UIView *backView;

//@property (nonatomic, weak) SVGAPlayer *aPlayer_load;  // 动画
//
//@property (nonatomic, weak) SVGAParser *parser_load;  // 加载动画
@end

@implementation JADIYRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.height = 60 + JA_StatusBarHeight;
        
        
        UIView *backView = [[UIView alloc] init];
        _backView = backView;
        backView.backgroundColor = HEX_COLOR(0xf9f9f9);
        backView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, self.height);
        [self addSubview:backView];
        /*
        SVGAParser *parser = [[SVGAParser alloc] init];
        self.parser_load = parser;
        SVGAPlayer *aplyer = [[SVGAPlayer alloc] init];
        self.aPlayer_load = aplyer;
        self.aPlayer_load.clearsAfterStop = YES;
        [self addSubview:self.aPlayer_load];
        
        
        [self.parser_load parseWithNamed:@"iv_loading" inBundle:[NSBundle mainBundle] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
            self.aPlayer_load.videoItem = videoItem;
//            [self.aPlayer_load stepToFrame:1 andPlay:NO];
            
        } failureBlock:nil];
        */
        
        UIImageView *juHuaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingG_1"]];
        self.juHuaImageView = juHuaImageView;
        
//        JADIYBottomView *diyBottom = [[JADIYBottomView alloc] initWithFrame:CGRectMake((JA_SCREEN_WIDTH - 30) * 0.5, 63, 30, 6)];
//        diyBottom.backgroundColor = [UIColor clearColor];
//        self.diyBottom = diyBottom;
//        [self addSubview:diyBottom];
//        NSMutableArray *arr = [NSMutableArray array];
//        for (NSInteger i = 0; i < 30; i++) {
//            NSString *name = [NSString stringWithFormat:@"loading_%ld",i+1];
//            UIImage *image = [UIImage imageNamed:name];
//            [arr addObject:image];
//        }
//
//        self.juHuaImageView.animationImages = arr;
//        self.juHuaImageView.animationRepeatCount = 0;
//        self.juHuaImageView.animationDuration = 0.8;
        
        [self addSubview:juHuaImageView];
        
   

    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /*
    self.aPlayer_load.width = 60;
    self.aPlayer_load.height = self.aPlayer_load.width;
    self.aPlayer_load.centerY = self.height * 0.5;
    self.aPlayer_load.centerX = self.width * 0.5;
    */
    self.juHuaImageView.width = 60;
    self.juHuaImageView.height = self.juHuaImageView.width;
    self.juHuaImageView.centerY = self.height * 0.5 + 10;
    self.juHuaImageView.centerX = self.width * 0.5;
    
}

- (void)setState:(MJRefreshState)state
{
    [super setState:state];
    
    switch (state) {
        case MJRefreshStateIdle: {// 普通
            
//            [self.juHuaImageView stopAnimating];
            self.juHuaImageView.image = [UIImage imageNamed:@"loadingG_1"];
            
            
            /*
            [self.aPlayer_load stepToFrame:1 andPlay:NO];
             */
            break;
        }
        case MJRefreshStatePulling: {// 松开就可以刷新
            
            break;
        }
            
        case MJRefreshStateRefreshing:{
//            [self.juHuaImageView startAnimating];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loadingG" ofType:@"gif"];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            self.juHuaImageView.image = [UIImage sd_animatedGIFWithData:imageData];
  
            /*
            if (self.aPlayer_load.videoItem) {
                [self.aPlayer_load startAnimation];
            }else{
                [self.parser_load parseWithNamed:@"iv_loading" inBundle:[NSBundle mainBundle] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                    self.aPlayer_load.videoItem = videoItem;
                    [self.aPlayer_load startAnimation];
                } failureBlock:nil];
            }
             */
            
//            [self.juHuaImageView startAnimating];
//            NSString  *gifname = @"loading";
//            NSString  *filePath = [[NSBundle mainBundle] pathForResource:gifname ofType:nil];
//            self.juHuaImageView.image = [UIImage sd_animatedGIFNamed:filePath];
            
            
            break;
        }
            
        default:
            break;
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    CGPoint new = [change[@"new"] CGPointValue];
    if (new.y < 0) {
        self.backView.height = self.height-new.y;
        self.backView.y = new.y;
    }
    
}
@end
