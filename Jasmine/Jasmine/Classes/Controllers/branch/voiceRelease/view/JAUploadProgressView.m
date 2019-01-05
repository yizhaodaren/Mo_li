//
//  JAUploadProgressView.m
//  Jasmine
//
//  Created by xujin on 22/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAUploadProgressView.h"
#import "JAReleasePostManager.h"

@interface JAUploadProgressView()

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation JAUploadProgressView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = self.bounds;
        progressView.trackTintColor = HEX_COLOR(0xF4F4F4);
        progressView.progressTintColor = HEX_COLOR(0x6BD379);
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, frame.size.height);
        progressView.transform = transform;//设定宽高
        [self addSubview:progressView];
        self.progressView = progressView;
        
        UILabel *uploadLabel = [[UILabel alloc] initWithFrame:self.bounds];
        uploadLabel.font = JA_REGULAR_FONT(10);
        uploadLabel.textAlignment = NSTextAlignmentCenter;
        uploadLabel.textColor = HEX_COLOR(0x4a4a4a);
        uploadLabel.text = @"上传中...";
        [self addSubview:uploadLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgress:) name:@"JAUploadProgress" object:nil];
    }
    return self;
}

- (void)uploadProgress:(NSNotification *)noti {
//    float progress = [[noti object] floatValue];
    JAPostDraftModel *currentDraftModel = [JAReleasePostManager shareInstance].postDraftModel;
    self.progressView.progress = currentDraftModel.progress;
}

@end
