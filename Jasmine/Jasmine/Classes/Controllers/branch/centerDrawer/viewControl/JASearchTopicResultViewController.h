//
//  JASearchTopicResultViewController.h
//  Jasmine
//
//  Created by xujin on 2018/5/3.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAVoiceTopicModel.h"

@interface JASearchTopicResultViewController : JABaseViewController<UISearchResultsUpdating>

@property (strong, nonatomic) UINavigationController *nav;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, copy) void (^selectedTopic)(JAVoiceTopicModel *topicModel);
@property (nonatomic, copy) void (^hideSearchBar)(void);

@end
