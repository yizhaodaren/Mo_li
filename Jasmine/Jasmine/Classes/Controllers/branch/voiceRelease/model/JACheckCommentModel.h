//
//  JACheckCommentModel.h
//  Jasmine
//
//  Created by xujin on 06/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JACheckCommentModel : NSObject

@property (nonatomic, assign) NSInteger maxNum; // 音频时长区间
@property (nonatomic, assign) NSInteger minNum; // 音频时长区间
@property (nonatomic, assign) NSInteger minText; // 最小文字数
@property (nonatomic, assign) NSInteger recognitionTime; // 前多少秒识别出文字

@property (nonatomic, copy) NSString *type;// comment_examine_success、comment_examine_fail

@end
