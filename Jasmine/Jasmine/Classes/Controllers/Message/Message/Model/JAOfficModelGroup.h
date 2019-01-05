//
//  JAOfficModelGroup.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAOfficModelGroup : NSObject
@property (nonatomic, strong) NSString *currentPageNo;
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *previousPage;
@property (nonatomic, strong) NSString *totalCount;
@property (nonatomic, strong) NSString *totalPageCount;
@property (nonatomic, strong) NSArray *result;
@end
