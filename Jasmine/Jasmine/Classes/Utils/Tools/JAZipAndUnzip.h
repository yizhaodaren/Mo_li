//
//  JAZipAndUnzip.h
//  Jasmine
//
//  Created by xujin on 09/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAZipAndUnzip : NSObject

- (NSData *)gzipInflate:(NSData*)data;
- (NSData *)gzipDeflate:(NSData*)data;

@end
