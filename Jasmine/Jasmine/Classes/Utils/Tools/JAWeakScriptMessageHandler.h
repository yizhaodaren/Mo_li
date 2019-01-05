//
//  JAWeakScriptMessageHandler.h
//  Jasmine
//
//  Created by xujin on 13/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol JAScriptMessageHandler <NSObject>

@optional
- (void)ja_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface JAWeakScriptMessageHandler : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<JAScriptMessageHandler> ja_handler;
- (instancetype)initWithHandler:(id<JAScriptMessageHandler>)ja_handler;

@end
