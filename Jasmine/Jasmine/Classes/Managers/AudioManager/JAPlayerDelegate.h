//
//  JAPlayerDelegate.h
//  Jasmine
//
//  Created by xujin on 09/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

@protocol JAPlayerDelegate <NSObject>

@optional

- (void)audioPlayerDidCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;

- (void)audioPlayerDidPlayFinished;

-(void)audioPlayerUnexpectedError:(NSError *)error;

@end
