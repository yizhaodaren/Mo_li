//
//  JAInviteModel.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteModel.h"
#import "JAVoiceCommonApi.h"
#import "JAConsumerGroupModel.h"

@interface JAInviteModel ()

@property (nonatomic, strong) NSMutableArray *recommendArray;
@property (nonatomic, strong) NSMutableArray *friendArray;

@property (nonatomic, assign) NSInteger recommendCurrentPage;
@property (nonatomic, assign) NSInteger friendCurrentPage;

@property (nonatomic, assign) BOOL recommendRequesting;
@property (nonatomic, assign) BOOL friendRequesting;

@end


@implementation JAInviteModel


- (id)init
{
    self = [super init];
    if (self)
    {
        self.recommendArray = [NSMutableArray new];
        self.friendArray = [NSMutableArray new];
    }
    return self;
}


- (void)inviteUserWithIndexPath:(NSIndexPath *)indexPath type:(NSInteger)type success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    JAConsumer *data;
   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if (type == 1) {
        data = [self friendDataAtIndex:indexPath.row];
        params[@"inviteId"] = data.userId;

    } else {
        data = [self recommendDataAtIndex:indexPath.row];
        params[@"inviteId"] = data.userId;

    }
    params[@"typeId"] = self.typeId;
    params[@"type"] = @"story";
    
    [[JAVoiceCommonApi shareInstance] voice_inviteAddWithParas:params success:^(NSDictionary *result) {
        
        data.inviteStatus = @"1";
        if (type == 1) {
            [self updateFriend:data atIndex:indexPath.row];
        } else {
            [self updateRecommend:data atIndex:indexPath.row];
        }
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (void)getRecommendListWithLoadMore:(BOOL)isLoadMore success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    if (self.recommendRequesting) {
        return;
    }
    self.recommendRequesting = YES;
    if (!isLoadMore) {
        self.recommendCurrentPage = 1;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"typeId"] = self.typeId;
    params[@"inviteType"] = @"story";
    
    [[JAVoiceCommonApi shareInstance] voice_inviteRecommentWithParas:params success:^(NSDictionary *result) {
        self.recommendRequesting = NO;

       [self.recommendArray removeAllObjects];
        NSArray *arr = [JAConsumer mj_objectArrayWithKeyValuesArray:result[@"userList"]];
        [self.recommendArray addObjectsFromArray:arr];
      
        self.recommendCount = self.recommendArray.count;
            
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        self.recommendRequesting = NO;
        if (failure) {
            failure(error);
        }
    }];
    
}

- (void)getFriendListWithLoadMore:(BOOL)isLoadMore success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    if (self.friendRequesting) {
        return;
    }
    self.friendRequesting = YES;
    if (!isLoadMore) {
        self.friendCurrentPage = 1;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"uid"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"type"] = @"0";
    params[@"pageSize"] = @"10";
    params[@"pageNum"] = @(self.friendCurrentPage);
    params[@"inviteType"] = @"story";
    params[@"typeId"] = self.typeId;
    [[JAVoiceCommonApi shareInstance] voice_inviteFocusWithParas:params success:^(NSDictionary *result) {
        self.friendRequesting = NO;
        JAConsumerGroupModel *data = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"friendList"]];
        if (data) {
            if (data.result.count) {
                if (!isLoadMore) {
                    [self.friendArray removeAllObjects];
                    // 显示footer
                }
                self.friendCurrentPage++;//如果服务器返回页面，重新赋值
                [self.friendArray addObjectsFromArray:data.result];
            } else {
                if (!isLoadMore) {
                    [self.friendArray removeAllObjects];
                    // 隐藏footer，如果有nodataview,可以不用
                }
            }
            
            if (self.friendArray.count == data.totalCount) {
                self.friendNoMoreData = YES;
            } else {
                self.friendNoMoreData = NO;
            }
            self.friendCount = self.friendArray.count;
            
        }
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        self.friendRequesting = NO;
        if (failure) {
            failure(error);
        }
    }];

}


- (JAConsumer *)recommendDataAtIndex:(NSUInteger)index
{
    if (index < self.recommendCount)
    {
        return self.recommendArray[index];
    }
    return nil;
}

- (JAConsumer *)friendDataAtIndex:(NSUInteger)index
{
    if (index < self.friendCount)
    {
        return self.friendArray[index];
    }
    return nil;
}

- (void)updateRecommend:(JAConsumer *)data atIndex:(NSUInteger)index
{
    [self.recommendArray replaceObjectAtIndex:index withObject:data];
}

- (void)updateFriend:(JAConsumer *)data atIndex:(NSUInteger)index
{
    [self.friendArray replaceObjectAtIndex:index withObject:data];
}

@end
