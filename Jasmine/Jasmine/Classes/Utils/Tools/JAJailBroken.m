//
//  JAJailBroken.m
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAJailBroken.h"

#import <sys/stat.h>
#import<dlfcn.h>
#import <dlfcn.h>

#define ARRAY_SIZE(a)    sizeof(a)/sizeof(a[0])
#define USER_APP_PATH    @"/User/Applications/"
#define CYDIA_APP_PATH   "/Applications/Cydia.app"
#define APT_APP_PATH     "/private/var/lib/apt/"

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/etc/apt",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    "/Applications/Absinthe.app",
};

@implementation JAJailBroken

/**
 *  1. 判定常见的越狱文件
 */
+ (BOOL)isJailBrokenOne
{
    for (int i = 0; i < ARRAY_SIZE(jailbreak_tool_pathes); i++)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}

/**
 *  2. 判断cydia的URL scheme
 */
+ (BOOL)isJailBrokenTwo
{
    return ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]);
}

/**
 *  3. 读取系统所有应用的名称
 */
+ (BOOL)isJailBrokenThree
{
    return [[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH];
}

/**
 *  4. 使用stat方法来判定cydia是否存在
 */
+ (BOOL)isJailBrokenFour
{
    if (checkCydia())
    {
        
        return YES;
    }
    
    return NO;
}

/**
 *  5. 读取环境变量
 */
+ (BOOL)isJailBrokenFive
{
    if (printEnv())
    {
        
        return YES;
    }
    
    return NO;
}



#pragma mark - Private

int checkInject()
{
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char*, struct stat*) = stat;
    
    if ((ret = dladdr(func_stat, &dylib_info)))
    {
        return 0;
    }
    return 1;
}

int checkCydia()
{
    // first ,check whether library is inject
    struct stat stat_info;
    
    if (!checkInject())
    {
        if (0 == stat(CYDIA_APP_PATH, &stat_info) ||(0 == stat(APT_APP_PATH, &stat_info))) {
            return 1;
        }
    } else {
        return 1;
    }
    return 0;
}

char* printEnv(void)
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    return env;
}


+ (BOOL)isJailBreak
{
    return ([self isJailBrokenOne] ||
            [self isJailBrokenTwo] ||
            [self isJailBrokenThree] ||
            [self isJailBrokenFour] ||
            [self isJailBrokenFive] );
}

@end
