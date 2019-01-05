//
//  JAWeakScriptMessageHandler.m
//  Jasmine
//
//  Created by xujin on 13/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAWeakScriptMessageHandler.h"

@implementation JAWeakScriptMessageHandler

- (instancetype)initWithHandler:(id<JAScriptMessageHandler>)ja_handler {
    self = [super init];
    if (self) {
        _ja_handler = ja_handler;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.ja_handler && [self.ja_handler respondsToSelector:@selector(ja_userContentController:didReceiveScriptMessage:)]) {
        [self.ja_handler ja_userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
