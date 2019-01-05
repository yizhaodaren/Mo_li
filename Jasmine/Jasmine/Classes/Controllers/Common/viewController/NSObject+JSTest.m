//
//  NSObject+JSTest.m
//  Jasmine
//
//  Created by xujin on 07/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NSObject+JSTest.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation NSObject (JSTest)

- (void)webView:(id)unuse didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateContextNotification" object:ctx];
}

@end
