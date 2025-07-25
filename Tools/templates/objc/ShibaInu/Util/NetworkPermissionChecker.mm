//
//  NetworkPermissionChecker.mm
//  用于网络权限检查，在网络权限未授予时，弹窗引导用户去设置。
//  依赖 Network.framework
//  Created by LOLO on 2025/07/25.
//

#import <UIKit/UIKit.h>
#import <Network/Network.h>
#import "NetworkPermissionChecker.h"


#pragma mark - Static State

static NSString * const LOG_TAG = @"[NetworkPermissionChecker]";
static NSString * const kNetworkCheckPassedKey = @"NetworkCheckPassed";

// 静态变量
static nw_path_monitor_t _pathMonitor = nil;
static nw_path_status_t _currentPathStatus = nw_path_status_invalid;
static BOOL _isCheckingNetwork = NO;
static __weak UIAlertController *_networkErrorAlert = nil;

// 用于存储当前检查任务的回调和 Alert UI 文本
static void (^_completionBlock)(void);
static NSString *_alertTitle;
static NSString *_alertMessage;
static NSString *_settingsButtonTitle;
static NSString *_retryButtonTitle;


@implementation NetworkPermissionChecker


#pragma mark - Public API

+ (void)checkWithCompletion:(void (^)(void))completionBlock {
    // 调用全功能的检查方法，并传入默认的英文文本
    [self checkWithTitle:@"Network Error"
                 message:@"Unable to connect to the server. Please check your network connection or allow network access in Settings."
          settingsButton:@"Settings"
             retryButton:@"Retry"
              completion:completionBlock];
}


+ (void)checkWithTitle:(NSString *)title
               message:(NSString *)message
        settingsButton:(NSString *)settingsButton
           retryButton:(NSString *)retryButton
            completion:(void (^)(void))completionBlock {

    // 如果之前已检查通过，直接执行回调并返回
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kNetworkCheckPassedKey]) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    
    // 存储本次检查的参数和回调
    _completionBlock = [completionBlock copy];
    _alertTitle = [title copy];
    _alertMessage = [message copy];
    _settingsButtonTitle = [settingsButton copy];
    _retryButtonTitle = [retryButton copy];
    
    // 开始内部检查流程
    [self startInternalCheck];
}


#pragma mark - Internal Logic

+ (void)startInternalCheck {
    if (_isCheckingNetwork) {
        return;
    }
    _isCheckingNetwork = YES;

    // 懒加载：只在监视器不存在时才创建和启动
    if (_pathMonitor == nil) {
        NSLog(@"%@ 正在创建并启动网络监视器...", LOG_TAG);
        _pathMonitor = nw_path_monitor_create();
        
        if (_pathMonitor == NULL) {
            NSLog(@"%@ [!!! CRITICAL ERROR !!!] nw_path_monitor_create() 失败。", LOG_TAG);
            [self showNetworkErrorAlert];
            _isCheckingNetwork = NO;
            return;
        }

        dispatch_queue_t queue = dispatch_queue_create("networkpermissionchecker.monitor", NULL);
        nw_path_monitor_set_queue(_pathMonitor, queue);

        nw_path_monitor_set_update_handler(_pathMonitor, ^(nw_path_t path) {
            _currentPathStatus = nw_path_get_status(path);
            NSLog(@"%@ [NWPathMonitor] 网络状态更新: %d", LOG_TAG, (int)_currentPathStatus);

            if (_currentPathStatus == nw_path_status_satisfied) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleNetworkSuccess];
                });
            }
        });
        nw_path_monitor_start(_pathMonitor);
    }
    
    // 延迟一小段时间，让监视器有时间报告初始状态，然后根据当前状态决定是否弹窗
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isCheckingNetwork = NO;
        if (_currentPathStatus != nw_path_status_satisfied) {
            NSLog(@"%@ 延迟检查后，网络状态仍不满足，准备显示提示。", LOG_TAG);
            [self showNetworkErrorAlert];
        }
    });
}

+ (void)handleNetworkSuccess {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kNetworkCheckPassedKey]) {
        return;
    }
    NSLog(@"%@ 网络状态检查结果: Satisfied (通畅)。", LOG_TAG);
    
    if (_networkErrorAlert) {
        NSLog(@"%@ 检测到错误弹窗正在显示，主动关闭它。", LOG_TAG);
        [_networkErrorAlert dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self cancelNetworkMonitor];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNetworkCheckPassedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isCheckingNetwork = NO;
    
    if (_completionBlock) {
        _completionBlock();
        _completionBlock = nil; // 执行后清空，防止重复调用
    }
}

+ (void)cancelNetworkMonitor {
    if (_pathMonitor) {
        NSLog(@"%@ 停止并销毁网络监视器。", LOG_TAG);
        nw_path_monitor_cancel(_pathMonitor);
        _pathMonitor = nil;
    }
}

+ (void)showNetworkErrorAlert {
    if (_networkErrorAlert) {
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_alertTitle
                                                                     message:_alertMessage
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:_settingsButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@ 用户选择跳转到设置。", LOG_TAG);
        _isCheckingNetwork = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAppDidBecomeActiveAfterSettings)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:_retryButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@ 用户选择重试网络连接。", LOG_TAG);
        _isCheckingNetwork = NO;
        [self startInternalCheck]; // 重试时使用已存储的参数
    }];
    
    [alert addAction:settingsAction];
    [alert addAction:retryAction];
    
    _networkErrorAlert = alert;
    
    UIViewController *rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rootVC presentViewController:_networkErrorAlert animated:YES completion:nil];
}

+ (void)handleAppDidBecomeActiveAfterSettings {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    NSLog(@"%@ 从设置返回应用，重新触发网络检查。", LOG_TAG);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startInternalCheck];
    });
}

@end
