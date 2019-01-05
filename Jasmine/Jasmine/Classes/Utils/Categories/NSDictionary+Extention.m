//
//  NSMutableDictionary+Safely.m
//  Common
//
//  Created by Biys on 15/3/6.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "NSDictionary+Extention.h"

@implementation NSDictionary (Safely)

- (id)objectForKeyWithNilForNull:(id)aKey {
    id obj = [self objectForKey:aKey];
    return obj == [NSNull null] ? nil : obj;
}

- (int64_t)longLongForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return 0;
    }
    int64_t value = 0;
    @try {
        value = [[self objectForKeyWithNilForNull:key] longLongValue];
    }
    @catch (NSException *exception) {
        value = 0;
    }
    @finally {
        
    }
    return value;
}


- (int)intForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return 0;
    }
    int value = 0;
    @try {
        value = [[self objectForKeyWithNilForNull:key] intValue];
    }
    @catch (NSException *exception) {
        value = 0;
    }
    @finally {
        
    }
    return value;
}

- (BOOL)boolForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return NO;
    }
    BOOL value = NO;
    @try {
        value = [[self objectForKeyWithNilForNull:key] boolValue];
    }
    @catch (NSException *exception) {
        value = NO;
    }
    @finally {
        
    }
    return value;
}

- (CGFloat)floatForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return 0;
    }
    CGFloat value = 0;
    @try {
        value = [[self objectForKeyWithNilForNull:key] doubleValue];
    }
    @catch (NSException *exception) {
        value = 0;
    }
    @finally {
        
    }
    return value;
}

- (int64_t)longForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return 0;
    }
    int64_t value = 0;
    @try {
        value = [[self objectForKeyWithNilForNull:key] longLongValue];
    }
    @catch (NSException *exception) {
        value = 0;
    }
    @finally {
        
    }
    return value;
}



- (NSString *)stringForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return nil;
    }
    NSString * value = [self objectForKeyWithNilForNull:key];
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    return value;
}

- (NSString *)stringForNumberKey:(NSString *)key{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return nil;
    }

    NSNumber * value = [self objectForKeyWithNilForNull:key];
    if (![value isKindOfClass:[NSNumber class]]) {
        return nil;
    }

    return [value stringValue];
}

- (NSDictionary *)dictForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return nil;
    }
    NSDictionary * value = [self objectForKeyWithNilForNull:key];
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return value;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    BOOL contain = [[self allKeys] containsObject:key];
    if (!contain) {
        return nil;
    }
    NSArray * value = [self objectForKeyWithNilForNull:key];
    if (![value isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return value;
}



- (id)objectForKeySafely:(id)aKey
{
    if (![self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [self objectForKeyWithNilForNull:aKey];
}


@end

@implementation NSMutableDictionary (Safely)

- (void)removeObjectSafelyForKey:(id)aKey
{
    if (aKey) {
        [self removeObjectForKey:aKey];
    }
}

- (void)setObjectSafely:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (aKey && anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
