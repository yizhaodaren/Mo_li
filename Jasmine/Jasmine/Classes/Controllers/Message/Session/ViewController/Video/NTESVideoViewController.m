//
//  NTESVideoViewController.m
//  NIM
//
//  Created by chris on 15/4/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESVideoViewController.h"
#import "UIView+Toast.h"
#import "Reachability.h"
#import "UIAlertView+NTESBlock.h"

@interface NTESVideoViewController ()

@property (nonatomic,strong) NIMVideoObject *videoObject;
@property (nonatomic,strong) UIButton *closeButton;

@end

@implementation NTESVideoViewController
@synthesize moviePlayer = _moviePlayer;

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (instancetype)initWithVideoObject:(NIMVideoObject *)videoObject{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _videoObject = videoObject;
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].resourceManager cancelTask:_videoObject.path];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.navigationItem.title = @"视频短片";
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    [self.view addSubview:coverImageView];
    if (self.videoObject.coverPath.length) {
        coverImageView.image = [UIImage imageWithContentsOfFile:self.videoObject.coverPath];
    } else {
        if (self.videoObject.coverUrl.length) {
            [coverImageView ja_setImageWithURLStr:self.videoObject.coverUrl];
        }
    }
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(0, 20, 40, 44);
    [self.closeButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoObject.path]) {
        [self startPlay];
    }else{
        __weak typeof(self) wself = self;
        [self downLoadVideo:^(NSError *error) {
            if (!error) {
                [wself startPlay];
            }else{
                [wself.view makeToast:@"下载失败，请检查网络"
                             duration:2
                             position:CSToastPositionCenter];
            }
        }];
    }
}

- (void)popVC {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.375];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [MBProgressHUD hideHUD];
    if (![[self.navigationController viewControllers] containsObject: self])
    {
        [self topStatusUIHidden:NO];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.moviePlayer stop];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {//不要调用.get方法，会过早的初始化播放器
        [self topStatusUIHidden:YES];
    }else{
        [self topStatusUIHidden:NO];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.moviePlayer.view.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT);
}

- (void)downLoadVideo:(void(^)(NSError *error))handler{
    [MBProgressHUD showMessage:nil];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].resourceManager download:self.videoObject.url filepath:self.videoObject.path progress:^(float progress) {
//        [SVProgressHUD showProgress:progress];
    } completion:^(NSError *error) {
        if (wself) {
            [MBProgressHUD hideHUD];
            if (handler) {
                handler(error);
            }
        }
    }];
}




- (void)startPlay{
    self.moviePlayer.view.frame = CGRectMake(0, -64, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT);
//    self.moviePlayer.view.frame = self.view.bounds;
//    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.moviePlayer play];
    [self.view addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayer];
    
    
    CGRect bounds = self.moviePlayer.view.bounds;
    CGRect tapViewFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    UIView *tapView = [[UIView alloc]initWithFrame:tapViewFrame];
    [tapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    tapView.backgroundColor = [UIColor clearColor];
    [self.moviePlayer.view addSubview:tapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [tapView  addGestureRecognizer:tap];
}

- (void)moviePlaybackComplete: (NSNotification *)aNotification
{
    if (self.moviePlayer == aNotification.object)
    {
        [self topStatusUIHidden:NO];
        NSDictionary *notificationUserInfo = [aNotification userInfo];
        NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        MPMovieFinishReason reason = [resultValue intValue];
        if (reason == MPMovieFinishReasonPlaybackError)
        {
            NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
            NSString *errorTip = [NSString stringWithFormat:@"播放失败: %@", [mediaPlayerError localizedDescription]];
            [self.view makeToast:errorTip
                        duration:2
                        position:CSToastPositionCenter];
        }
    }
    
}

- (void)moviePlayStateChanged: (NSNotification *)aNotification
{
    if (self.moviePlayer == aNotification.object)
    {
        switch (self.moviePlayer.playbackState)
        {
            case MPMoviePlaybackStatePlaying:
                [self topStatusUIHidden:YES];
                break;
            case MPMoviePlaybackStatePaused:
            case MPMoviePlaybackStateStopped:
            case MPMoviePlaybackStateInterrupted:
                [self topStatusUIHidden:NO];
            case MPMoviePlaybackStateSeekingBackward:
            case MPMoviePlaybackStateSeekingForward:
                break;
        }
        
    }
}

- (void)topStatusUIHidden:(BOOL)isHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:isHidden];
//    self.navigationController.navigationBar.hidden = isHidden;
//    NTESNavigationHandler *handler = (NTESNavigationHandler *)self.navigationController.delegate;
//    handler.recognizer.enabled = !isHidden;
    
    if (isHidden) {
        [self.view bringSubviewToFront:self.moviePlayer.view];
        [self.closeButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateNormal];
    } else {
        [self.view bringSubviewToFront:self.closeButton];
        [self.closeButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    }
}

- (void)onTap: (UIGestureRecognizer *)recognizer
{
    switch (self.moviePlayer.playbackState)
    {
        case MPMoviePlaybackStatePlaying:
            [self.moviePlayer pause];
            break;
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStateInterrupted:
            [self.moviePlayer play];
            break;
        default:
            break;
    }
}


- (MPMoviePlayerController*)moviePlayer{
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.videoObject.path]];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.fullscreen = YES;
    }
    return _moviePlayer;
}


@end
