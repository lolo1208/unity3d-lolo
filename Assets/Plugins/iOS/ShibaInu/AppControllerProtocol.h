//
// 项目相关的一些常量，公共方法等
// Created by LOLO on 2021/03/15.
//

#pragma once

#import <UIKit/UIKit.h>


@protocol AppControllerProtocol

@optional

- (void) onInit;

- (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler;

@end

