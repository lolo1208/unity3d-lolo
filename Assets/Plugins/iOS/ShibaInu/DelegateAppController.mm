//
//  DelegateAppController.mm
//
//  实现处理 iOS 系统的关键事件的控制器，
//  并持有一个实现 AppControllerProtocol 协议的对象，在对应的事件中会调用他。
//  Created by LOLO on 2021/03/15.
//

#import "NativeUtil.h"
#import "UnityAppController.h"
#import "AppControllerProtocol.h"



#pragma mark -

// 日志前缀常量
static NSString * const LOG_TAG = @"[DelegateAppController]";

@interface DelegateAppController : UnityAppController
@end

// Unity 用来替换 AppController 的宏
IMPL_APP_CONTROLLER_SUBCLASS (DelegateAppController)



#pragma mark -

// 用于持有实现了 AppControllerProtocol 的代理对象
static id<AppControllerProtocol> protocol;

@implementation DelegateAppController


/**
 * 在类加载时，注册一个一次性的通知观察者。
 * 当有代理对象通过发送通知来注册自己时，捕获它。
 */
+ (void)load {
    NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
    id __block token = [center addObserverForName:APP_CTR_PROT_NOTIF_NAME
                                           object:nil
                                            queue:[NSOperationQueue mainQueue]
                                       usingBlock:^(NSNotification *notification) {
        // 获取通知中传递的代理对象
        if ([[notification object] conformsToProtocol:@protocol(AppControllerProtocol)]) {
            protocol = [notification object];
            NSLog(@"%@ 已接收并注册代理对象: %@", LOG_TAG, protocol);
        }
        // 移除观察者，确保只执行一次
        [center removeObserver:token];
    }];
}


- (id)init {
    self = [super init];
    if (self) {
        @try {
            if ([protocol respondsToSelector:@selector(onInit)]) {
                [protocol onInit];
            }
        } @catch (NSException *e) {
            NSLog(@"%@ [protocol onInit] 方法执行异常: %@", LOG_TAG, e);
        }
    }
    return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    @try {
        if ([protocol respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
            [protocol application:application didFinishLaunchingWithOptions:launchOptions];
        }
    } @catch (NSException *e) {
        NSLog(@"%@ [protocol didFinishLaunchingWithOptions] 方法执行异常: %@", LOG_TAG, e);
    }
    
    // 确保调用父类的实现，这是 Unity 启动的关键
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


/**
 * 实现新的 openURL 方法，以消除废弃警告。
 * 这个方法会取代旧的 handleOpenURL 和 openURL:sourceApplication:annotation:。
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL handledByProtocol = NO;
    
    @try {
        // 检查 protocol 是否实现了新方法，如果实现了就调用它
        if ([protocol respondsToSelector:@selector(application:openURL:options:)]) {
            handledByProtocol = [protocol application:app openURL:url options:options];
        }
    } @catch (NSException *e) {
        NSLog(@"%@ [protocol application:openURL:options:] 方法执行异常: %@", LOG_TAG, e);
    }
    
    // 如果代理已经处理了 URL，就直接返回 YES
    if (handledByProtocol) {
        return YES;
    }
    
    // 如果代理没有处理，那么就把机会给父类 (UnityAppController)，它可能也需要处理 URL
    if ([super respondsToSelector:@selector(application:openURL:options:)]) {
        return [super application:app openURL:url options:options];
    }
    
    // 如果都没有人处理，返回 NO
    return NO;
}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    BOOL handledByProtocol = NO;
    
    @try {
        if ([protocol respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            handledByProtocol = [protocol application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        }
    } @catch (NSException *e) {
        NSLog(@"%@ [protocol continueUserActivity] 方法执行异常: %@", LOG_TAG, e);
    }
    
    if (handledByProtocol) {
        return YES;
    }
    
    if ([super respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
        return [super application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    
    return NO;
}

@end
