//
// 项目相关的一些常量，公共方法等
// Created by LOLO on 2021/03/15.
//

#import "NativeUtil.h"
#import "UnityAppController.h"
#import "AppControllerProtocol.h"



#pragma mark -
@interface DelegateAppController : UnityAppController

@end

IMPL_APP_CONTROLLER_SUBCLASS (DelegateAppController)



#pragma mark -

static id<AppControllerProtocol> protocol;

@implementation DelegateAppController


+ (void) load
{
    NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
    id __block token = [center addObserverForName:APP_CTR_PROT_NOTIF_NAME
                                           object:nil
                                            queue:[NSOperationQueue mainQueue]
                                       usingBlock:^(NSNotification *notification) {
        protocol = [notification object];
        [center removeObserver:token];
    }];
}



- (id) init
{
    self = [super init];
    try {
        [protocol onInit];
    } catch (NSException *e) {
    }
    return self;
}


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    try {
        [protocol application:application didFinishLaunchingWithOptions:launchOptions];
    } catch (NSException *e) {
    }
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    try {
        return [protocol application:application handleOpenURL:url];
    } catch (NSException *e) {
    }
    return YES;
}


- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    try {
        return [protocol application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    } catch (NSException *e) {
    }
    return YES;
}


- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    try {
        return [protocol application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    } catch (NSException *e) {
    }
    return YES;
}


@end

