//
//  JAAudioPlayer.h
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface JAAudioPlayer : NSObject

@property (nonatomic, strong, readonly) AVAudioPlayer *player;

+ (JAAudioPlayer *)shareInstance;

- (void)play:(NSURL *)url finishBlock:(void(^)(void))playFinishBlock;

- (void)pause;
- (void)continuePlay;
- (void)stop;

@end
