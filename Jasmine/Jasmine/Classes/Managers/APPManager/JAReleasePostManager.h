//
//  JAReleasePostManager.h
//  Jasmine
//
//  Created by xujin on 19/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAPostDraftModel.h"

//@protocol JAReleasePostDelegate <NSObject>
//
//@optional
//- (void)releasePostProgress:(CGFloat)progress;
//
//@end

@interface JAReleasePostManager : NSObject

//@property (nonatomic, weak) id<JAReleasePostDelegate> delegate;
@property (nonatomic, strong) JAPostDraftModel *postDraftModel;

+ (JAReleasePostManager *)shareInstance;

- (void)asyncReleasePost:(JAPostDraftModel *)draftModel method:(NSInteger)method; //0重发1新建
- (NSArray *)getPostInDraft;
- (void)removeDraft:(JAPostDraftModel *)model;

@end
