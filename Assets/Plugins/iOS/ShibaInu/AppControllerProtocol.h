//
// 项目相关的一些常量，公共方法等
// Created by LOLO on 2021/03/15.
//

#pragma once

#import <UIKit/UIKit.h>


@protocol AppControllerProtocol

@optional

- (void) onInit;

- (void) application:(UIApplication *_Nullable)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions;

- (BOOL) application:(UIApplication *_Nullable)application handleOpenURL:(NSURL *_Nullable)url;

- (BOOL) application:(UIApplication *_Nullable)application openURL:(NSURL *_Nullable)url sourceApplication:(NSString *_Nullable)sourceApplication annotation:(id _Nullable )annotation;

- (BOOL) application:(UIApplication *_Nullable)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(void(^_Nullable)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler;

@end

