//
//  JAReuploadView.m
//  Jasmine
//
//  Created by xujin on 22/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAReuploadView.h"
#import "JAReleasePostManager.h"
#import "JAAPPManager.h"

@implementation JAReuploadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *voiceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 18, 16)];
        voiceIcon.image = [UIImage imageNamed:@"voice_file_upload"];
        [self addSubview:voiceIcon];
        voiceIcon.centerY = frame.size.height/2.0;
        
        UILabel *failLabel = [[UILabel alloc] initWithFrame:CGRectMake(voiceIcon.right+5, 0, 100, 14)];
        failLabel.font = JA_REGULAR_FONT(12);
        failLabel.textColor = HEX_COLOR(0xFF7054);
        failLabel.text = @"上传失败";
        [self addSubview:failLabel];
        [failLabel sizeToFit];
        failLabel.centerY = frame.size.height/2.0;

        UILabel *saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(failLabel.left, failLabel.bottom+5, 100, 14)];
        saveLabel.font = JA_REGULAR_FONT(13);
        saveLabel.textColor = HEX_COLOR(0xc6c6c6);
        saveLabel.text = @"已保存至草稿箱";
        [self addSubview:saveLabel];
        [saveLabel sizeToFit];
        saveLabel.left = failLabel.right+10;
        saveLabel.centerY = frame.size.height/2.0;

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 22, 22);
        [closeButton setImage:[UIImage imageNamed:@"voice_reupload_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        closeButton.right = frame.size.width-20;
        closeButton.centerY = frame.size.height/2.0;

        UIButton *reuploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        reuploadButton.frame = CGRectMake(0, 0, 60, 22);
        reuploadButton.backgroundColor = [UIColor whiteColor];
        reuploadButton.titleLabel.font = JA_REGULAR_FONT(11);
        [reuploadButton setTitle:@"重新上传" forState:UIControlStateNormal];
        [reuploadButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [reuploadButton addTarget:self action:@selector(reuploadAction) forControlEvents:UIControlEventTouchUpInside];
        reuploadButton.layer.cornerRadius = 11;
        reuploadButton.layer.masksToBounds = YES;
        reuploadButton.layer.borderColor = [HEX_COLOR(JA_Green) CGColor];
        reuploadButton.layer.borderWidth = 1.0;
        [self addSubview:reuploadButton];
        reuploadButton.right = closeButton.left-20;
        reuploadButton.centerY = frame.size.height/2.0;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-1, frame.size.width, 1)];
        lineView.backgroundColor = HEX_COLOR(0xf4f4f4);
        [self addSubview:lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)reuploadAction {
    if (![JAAPPManager isConnect]) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
        return;
    }
    [[JAReleasePostManager shareInstance] asyncReleasePost:nil method:0];
}

- (void)closeAction {
    self.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.y = - self.height;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
