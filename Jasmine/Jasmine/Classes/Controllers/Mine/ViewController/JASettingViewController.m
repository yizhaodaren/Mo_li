//
//  JASettingViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/26.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASettingViewController.h"
#import "JABaseNavigationController.h"
#import "JAWebViewController.h"
#import "JABlackPersonViewController.h"
#import "JAAboutUsViewController.h"
#import "JAAccountActionViewController.h"
#import "JASwitchDefine.h"

#define Kmanager [NSFileManager defaultManager]

typedef void(^ActionBlock)(NSIndexPath *index);

@interface JASettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) void (^actionBlock)();
@property (nonatomic, strong) NSString *fileDataSize; // 缓存
@end

@implementation JASettingViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path1 = [path stringByAppendingPathComponent:@"default"];
        self.fileSize = [self getDataSize:path1];
        
        _fileDataSize = [NSString stringWithFormat:@"%.2fM",self.fileSize/1024.0/1024.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
            cell.detailTextLabel.text = _fileDataSize;
            NSMutableDictionary *dic = [self.dataSourceArray[1] mutableCopy];
            dic[@"subTitle"] = _fileDataSize;
            [self.dataSourceArray replaceObjectAtIndex:1 withObject:dic];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _fileDataSize = @"0.00M";
    
    _dataSourceArray = [NSMutableArray array];
    
    // 操作行为
    @WeakObj(self);
    ActionBlock block1 = ^(NSIndexPath *index){
        @StrongObj(self);
        JAAccountActionViewController *vc = [[JAAccountActionViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    ActionBlock block2 = ^(NSIndexPath *index){
        @StrongObj(self);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"清除系统缓存？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            NSString *path1 = [path stringByAppendingPathComponent:@"default"];
            [self clearDataSize:path1];
            [self.view ja_makeToast:@"清理成功"];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
            cell.detailTextLabel.text = @"0.00M";
            
        }];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:^{
        }];
    };
    
    ActionBlock block3 = ^(NSIndexPath *index){
        @StrongObj(self);
        JABlackPersonViewController *vc = [[JABlackPersonViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    ActionBlock block4 = ^(NSIndexPath *index){
        
        //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/cn/4M0Yjb.i"]];
        //            //跳转到应用页面
        NSString *appid = @"1238059448";
        NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",appid];
        
        //            //跳转到评价页面
        //            NSString *appid1 = @"1238059448";
        //            NSString *str = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id;=%@",
        //                             appid1];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    };
    
    ActionBlock block5 = ^(NSIndexPath *index){
        @StrongObj(self);
        JAAboutUsViewController *vc = [[JAAboutUsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    ActionBlock block6 = ^(NSIndexPath *index){
        @StrongObj(self);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"退出当前账号？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            self.tableView.delegate = nil;
            self.tableView.dataSource = nil;
            // 退出登录
            [JAAPPManager app_loginOut];
            
//            [JAUserInfo userinfo_saveUserLoginState:NO];
//            [JAUserInfo userInfo_deleteUserInfo];
//            [self.navigationController popToRootViewControllerAnimated:NO];
//            // 退出云信
//            [[QYSDK sharedSDK] logout:^(){}];
//            [JAChatMessageManager yx_loginOutYX];
//            
//            // 删除别名
//            [JPUSHService setAlias:nil completion:nil seq:0];
//            
//            [JAAPPManager app_modalLogin];
            
        }];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    };

//#ifdef JA_TEST_HOST
//
//    ActionBlock block7 = ^(NSIndexPath *index){
//        @StrongObj(self);
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"切换服务器需要重启APP" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            [JAUserInfo userinfo_saveUserLoginState:NO];
//            [JAUserInfo userInfo_deleteUserInfo];
//            // 退出云信
//            [[QYSDK sharedSDK] logout:^(){}];
//            [JAChatMessageManager yx_loginOutYX];
//            // 删除别名
//            [JPUSHService setAlias:nil completion:nil seq:0];
//
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"select_host"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                exit(0);
//            });
//
//        }];
//        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        [alertController addAction:okAction];
//        [alertController addAction:cancleAction];
//        [self presentViewController:alertController animated:YES completion:^{
//
//        }];
//    };
//
//    self.dataSourceArray = [@[
//                             @{@"title" : @"账户管理", @"subTitle" : @"", @"action" : block1},
//                             @{@"title" : @"清理缓存", @"subTitle" : _fileDataSize, @"action" : block2},
//                             @{@"title" : @"黑名单管理", @"subTitle" : @"", @"action" : block3},
//                             @{@"title" : @"给个好评", @"subTitle" : @"", @"action" : block4},
//                             @{@"title" : @"关于茉莉", @"subTitle" : @"", @"action" : block5},
//                             @{@"title" : @"退出当前账号", @"subTitle" : @"", @"action" : block6},
//                             @{@"title" : @"切换正式、测试服务器", @"subTitle" : @"", @"action" : block7},
//                             ] mutableCopy];
//#else
    self.dataSourceArray = [@[
                             @{@"title" : @"账户管理", @"subTitle" : @"", @"action" : block1},
                             @{@"title" : @"清理缓存", @"subTitle" : _fileDataSize, @"action" : block2},
                             @{@"title" : @"黑名单管理", @"subTitle" : @"", @"action" : block3},
                             @{@"title" : @"给个好评", @"subTitle" : @"", @"action" : block4},
                             @{@"title" : @"关于茉莉", @"subTitle" : @"", @"action" : block5},
                             @{@"title" : @"退出当前账号", @"subTitle" : @"", @"action" : block6},
                             ] mutableCopy];
//#endif
    
    
    
    [self setCenterTitle:@"设置"];
    [self setNavigationBarColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];

//    UILabel *label = [[UILabel alloc] init];
//    label.textColor = HEX_COLOR(0x9c9ca4);
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = [NSString stringWithFormat:@"Version %@",appVersion];
//    [label sizeToFit];
//    label.width = JA_SCREEN_WIDTH;
//    label.height = 50;
//    self.tableView.tableFooterView = label;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"设置";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 5;
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = HEX_COLOR(JA_Background);
    }
    
    // 获取数据
    NSDictionary *dic = self.dataSourceArray[indexPath.section];
    cell.textLabel.text = dic[@"title"];
    cell.detailTextLabel.text = dic[@"subTitle"];
    
    if (indexPath.section == self.dataSourceArray.count - 1) {
        cell.textLabel.textColor = HEX_COLOR(0x9c9ca4);
    }else{
        cell.textLabel.textColor = HEX_COLOR(0x444444);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataSourceArray[indexPath.section];
    ActionBlock actionBlock = dic[@"action"];
    actionBlock(indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 5)];
    bg.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    return bg;
}

- (void)clearDataSize:(NSString *)fullPath{
    
    // 判断filePath路径下的文件是否存在？是文件夹还是文件
    BOOL directory;
    BOOL ok = [Kmanager fileExistsAtPath:fullPath isDirectory:&directory];
    
    if (!ok || !directory) {
        
        // 判断传进来的是否是一个文件夹的全路径
//        NSException *exp = [NSException exceptionWithName:@"file" reason:@"需要传入一个文件夹的全路径" userInfo:nil];
//
//        [exp raise];
        return;
    }
    
    // 获取该路径下一级目录
    NSArray *subFiles = [Kmanager contentsOfDirectoryAtPath:fullPath error:nil];
    
    //    // 获取该路径下的所有文件及文件夹
    //    NSArray *subFiles = [Kmanager subpathsAtPath:fullPath];
    
    // 遍历该数组获取所有子文件
    for (NSString *subFile in subFiles) {
        
        // 拼接文件的全路径
        NSString *filePath = [fullPath stringByAppendingPathComponent:subFile];
        
        // 移除文件
        [Kmanager removeItemAtPath:filePath error:nil];
    }
    
}

- (NSInteger)getDataSize:(NSString *)fullPath{
    
    // 判断filePath路径下的文件是否存在？是文件夹还是文件
    BOOL directory;
    BOOL ok = [Kmanager fileExistsAtPath:fullPath isDirectory:&directory];
    
    if (!ok || !directory) {
//        // 判断传进来的是否是一个文件夹的全路径
//        NSException *exp = [NSException exceptionWithName:@"file" reason:@"需要传入一个文件夹的全路径" userInfo:nil];
//        [exp raise];
        return 0;
    }
    
    
    
    NSInteger totalSize = 0;
    
    // 获取该路径下的所有文件及文件夹
    NSArray *subFiles = [Kmanager subpathsAtPath:fullPath];
    
    // 遍历该数组获取所有子文件
    for (NSString *subFile in subFiles) {
        
        // 拼接文件的全路径
        NSString *filePath = [fullPath stringByAppendingPathComponent:subFile];
        
        // 判断filePath路径下的文件是否存在？是文件夹还是文件
        BOOL directory;
        BOOL ok = [Kmanager fileExistsAtPath:filePath isDirectory:&directory];
        
        if (ok && !directory) {
            
            NSDictionary *dict = [Kmanager attributesOfItemAtPath:filePath error:nil];
            
            // 取出该文件的大小
            NSInteger filesize = [dict fileSize];
            
            // 计算总大小
            totalSize += filesize;
        }
        
    }
    
    return totalSize;
}

@end
