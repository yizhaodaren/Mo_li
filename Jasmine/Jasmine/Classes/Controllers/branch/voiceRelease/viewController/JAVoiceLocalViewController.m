//
//  JAVoiceLocalViewController.m
//  Jasmine
//
//  Created by xujin on 27/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceLocalViewController.h"
#import "JAVoiceLocalTableViewCell.h"
//#import "HTTPServer.h"
//#import "HttpServerControl.h"
//#import "UIDevice-Reachability.h"

#define kDefaultPort  80
#define kBackupPort   6969

static NSString *const kVoiceLocalCellIdentifier = @"JAVoiceLocalCellIdentifier";

@interface JAVoiceLocalViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *voices;

//@property (nonatomic, strong)HTTPServer *httpServer;

@end

@implementation JAVoiceLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"音频列表"];
    [self setupTableView];
}

- (void)setupTableView {
    self.voices = [NSMutableArray new];
    
//    JAVoiceFollowGroupModel *model = [JAVoiceFollowGroupModel searchSingleWithWhere:nil orderBy:nil];
//    if (model.result.count) {
//        [self.follows addObjectsFromArray:model.result];
//    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.voices.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JAVoiceLocalModel *model = self.voices[indexPath.row];
    JAVoiceLocalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceLocalCellIdentifier];
    if (!cell) {
        cell = [[JAVoiceLocalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVoiceLocalCellIdentifier];
    }
    cell.data = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JAVoiceLocalModel *model = self.voices[indexPath.row];
    model.isSelected = !model.isSelected;
    [self.tableView reloadData];
}

#pragma mark - WIFI导入方法

- (void)setupHttpServer
{
    
//    NSString *documentRoot = [[[NSBundle mainBundle] pathForResource:@"lizhi_wifi" ofType:@"html" inDirectory:@"Web"] stringByDeletingLastPathComponent];
    
    [self stopHttpServer];
    
    [self addHttpObserver];
    
//    _httpServer = [[HTTPServer alloc] init];
//    [_httpServer setType:@"_http._tcp."];
//    [_httpServer setPort:kDefaultPort];
//    [_httpServer setDocumentRoot:documentRoot];
//    [_httpServer setConnectionClass:[HttpServerControl class]];
//
    Reachability *r = [Reachability reachabilityForInternetConnection];
    
    if ([r currentReachabilityStatus] == ReachableViaWiFi) {
        
//        NSError *error = nil;
//        if([_httpServer start:&error] == NO)
//        {
//            NSLog(@"Error starting HTTP Server: %@", error);
//            [_httpServer setPort:kBackupPort];
//            if([_httpServer start:&error] == NO)
//            {
//                NSLog(@"Error starting HTTP Server: %@", error);
////                [_popupView.wifiView stateWifiSetupFail];
//            }
//        }
    }
    else
    {
//        [_popupView.wifiView stateWifiSetupFail];
    }
}

- (void)stopHttpServer
{
    [self removeHttpObserver];
    
//    if (_httpServer) {
//        [_httpServer stop];
//        _httpServer = nil;
//    }
}

- (void)serviceDidPublish:(id)sender
{
//    NSString *display = [NSString stringWithFormat:@"http://%@", [[UIDevice currentDevice] getIPAddress]];
//    if ([_httpServer listeningPort] != 80) {
//        display = [NSString stringWithFormat:@"%@:%d", display, [_httpServer listeningPort]];
//    }
    
//    [_popupView.wifiView stateWifiSetupWithIp:display];
}

- (void)serviceDidNotPublish:(id)sender
{
//    [_popupView.wifiView stateWifiSetupFail];
}

- (void)addHttpObserver
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serviceDidPublish:)
//                                  name:kServiceDidPublish
//                                object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serviceDidNotPublish:)
//                                  name:kServiceDidNotPublish
//                                object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serverUploadStart:)
//                                  name:kServerUploadStart
//                                object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serverUploadding:)
//                                  name:kServerUploadding
//                                object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serverUploadFinish:)
//                                  name:kServerUploadFinish
//                                object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                              selector:@selector(serverDeleted:)
//                                  name:kServerDeleted
//                                object:nil];
}

- (void)removeHttpObserver
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServiceDidPublish
//                                   object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServiceDidNotPublish
//                                   object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServerUploadStart
//                                   object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServerUploadding
//                                   object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServerUploadFinish
//                                   object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                     name:kServerDeleted
//                                   object:nil];
}

- (void)serverUploadStart:(NSNotification *)sender
{
//    NSString *fileName = sender.object;
    
//    [_popupView.wifiView stateWifiUploadding:0
//                                    fileName:fileName];
}

- (void)serverUploadding:(NSNotification *)sender
{
//    NSNumber *percentNum = sender.object;
//    float percent = [percentNum floatValue];
//    percent *= 100;
//    [_popupView.wifiView stateWifiUploadding:percent
//                                    fileName:@""];
}

- (void)serverUploadFinish:(NSNotification *)sender
{
//    NSString *fileName = [sender object];
//    [_popupView.wifiView stateWifiUploadding:100
//                                    fileName:fileName];
//    [self addAudioWithName:fileName];
//
//    [mTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
//              withRowAnimation:UITableViewRowAnimationFade];
}

- (void)serverDeleted:(NSNotification *)sender
{
//    NSArray *filesName = [sender object];
//
//    for (NSString *fileName in filesName)
//    {
//        [self removeAudioWithName:fileName section:0];
//    }
//
//    [mTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
//              withRowAnimation:UITableViewRowAnimationFade];
}

@end
