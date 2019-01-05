//
//  JABanner.h
//  Jasmine
//
//  Created by xujin on 03/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JABanner : NSObject

@property (nonatomic, copy) NSString *bannerId;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
/// 如果是内链，此值是内链内容的ID，如是外链：是外链地址
@property (nonatomic, copy) NSString *url;
/// 1：内链，2：外链
@property (nonatomic, copy) NSString *inside;
/// 内链类型：problem|answer|story|publish
@property (nonatomic, copy) NSString *contentType;

@end
