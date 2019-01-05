//
//  JANewPageModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/21.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JANewPageModel : NSObject
@property (nonatomic, assign) NSInteger currentPageNo;
@property (nonatomic, assign) NSInteger nextPage;
@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *previousPage;
@property (nonatomic, strong) NSString *shownumwidth;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSString *totalPageCount;
@property (nonatomic, strong) NSArray *result;

@end
