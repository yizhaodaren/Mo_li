//
//  NSMutableDictionary+Safely.h
//  Common
//
//  Created by Biys on 15/3/6.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safely)

- (id)objectForKeyWithNilForNull:(id)aKey;

- (int64_t)longLongForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (BOOL) boolForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForNumberKey:(NSString *)key;
- (NSDictionary *)dictForKey:(NSString *)key;
- (int64_t)longForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (id)objectForKeySafely:(id)aKey;

@end

@interface NSMutableDictionary (Safely)
- (void)removeObjectSafelyForKey:(id)aKey;
- (void)setObjectSafely:(id)anObject forKey:(id <NSCopying>)aKey;


//- (void)setObjectSafely:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0); //想个好办法让下标方法也安全

@end
