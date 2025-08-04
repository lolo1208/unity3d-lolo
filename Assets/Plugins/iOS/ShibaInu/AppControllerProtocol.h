//
//  AppControllerProtocol.h
//
//  实现处理 iOS 系统的关键事件的协议，
//  DelegateAppController 会在对应的事件中调用他。
//  Created by LOLO on 2021/03/15.
//

#pragma once

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

// 让 AppControllerProtocol 继承自 <NSObject> 协议。
// 这向编译器保证，任何遵循此协议的对象，都将拥有 NSObject 的基础方法，
// 例如 respondsToSelector:, isMemberOfClass: 等。
// 这将解决 'No known instance method for selector' 的编译错误。
@protocol AppControllerProtocol <NSObject>

@optional


/**
 * 在 AppController 初始化时调用。
 */
- (void) onInit;


/**
 * 对应 AppDelegate 的 didFinishLaunchingWithOptions。
 */
- (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


/**
 * 处理 URL 跳转，这是自 iOS 9.0 以来的推荐方法。
 * @return YES 如果 URL 被成功处理。
 */
- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;


/**
 * 处理通用链接 (Universal Links) 等。
 */
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * _Nullable restorableObjects))restorationHandler;


@end

NS_ASSUME_NONNULL_END
