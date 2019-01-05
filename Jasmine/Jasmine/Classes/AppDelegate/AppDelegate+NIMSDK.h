//
//  AppDelegate+NIMSDK.h
//  Jasmine
//
//  Created by xujin on 02/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (NIMSDK)<NIMLoginManagerDelegate>

- (void)setupNIMSDK;

@end
