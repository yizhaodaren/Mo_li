//
//  JAInviteModel.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAInviteModel : NSObject

@property (nonatomic, assign) NSUInteger recommendCount;
@property (nonatomic, assign) NSUInteger friendCount;

@property (nonatomic, assign) BOOL recommendNoMoreData;
@property (nonatomic, assign) BOOL friendNoMoreData;

//@property (nonatomic, copy) NSString *questionId;   // --- 老项目使用
@property (nonatomic, copy) NSString *typeId;


- (void)getRecommendListWithLoadMore:(BOOL)isLoadMore success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void)getFriendListWithLoadMore:(BOOL)isLoadMore success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
//0推荐1好友
- (void)inviteUserWithIndexPath:(NSIndexPath *)indexPath type:(NSInteger)type success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

- (JAConsumer *)recommendDataAtIndex:(NSUInteger)index;

- (JAConsumer *)friendDataAtIndex:(NSUInteger)index;

- (void)updateRecommend:(JAConsumer *)data atIndex:(NSUInteger)index;
- (void)updateFriend:(JAConsumer *)data atIndex:(NSUInteger)index;

@end
