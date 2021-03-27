//
// Unity 与 Native 通信相关工具类
// Created by LOLO on 2020/08/08.
//

#pragma once



// 接收 Unity 发来的消息
/*
#import "NativeHelper.h"
NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
id __block token = [center addObserverForName:UNITY_MSG_NOTIF_NAME
                                       object:nil
                                        queue:[NSOperationQueue mainQueue]
                                   usingBlock:^(NSNotification *notification) {
    NSDictionary *data = [notification object];
    NSString *act = [data objectForKey:UNITY_MSG_KEY_ACT];
    NSString *msg = [data objectForKey:UNITY_MSG_KEY_MSG];
    NSLog(@"action=%@, msg=%@", act, msg);
    [center removeObserver:token];
}];
// or
[[NSNotificationCenter defaultCenter] addObserverForName:UNITY_MSG_NOTIF_NAME
                                                  object:nil
                                                   queue:[NSOperationQueue mainQueue]
                                              usingBlock:^(NSNotification *notification) {
    NSDictionary *data = [notification object];
    NSString *act = [data objectForKey:UNITY_MSG_KEY_ACT];
    NSString *msg = [data objectForKey:UNITY_MSG_KEY_MSG];
    NSLog(@"action=%@, msg=%@", act, msg);
}];
*/
// 使用前先了解 NSNotificationCenter:
// https://developer.apple.com/documentation/foundation/nsnotificationcenter
// --
// lua 层向 Native 发送消息可调用全局函数：
// SendMessageToNative("unitySay", "hello你好")
//

// 收到 Unity 发来的消息时，会用该名称在 NSNotificationCenter 派发通知
extern NSString * const UNITY_MSG_NOTIF_NAME;
extern NSString * const UNITY_MSG_KEY_ACT;
extern NSString * const UNITY_MSG_KEY_MSG;

extern NSString * const UN_ACT_BEFORE_LAUNCH;// 程序首次启动前，Unity 发来消息的 action 值



// 向 Unity 发送消息：
// ---
// #include "NativeHelper.h"
// SendMessageToUnity(@"action", @"NSString 字符串");
// SendMessageToUnity("action", "char* 字符串");
// ---
// 向 Unity 发送消息后，lua 层会派发 NativeEvent，可在 Stage 上侦听：
// AddEventListener(Stage, NativeEvent.RECEIVE_MESSAGE, fun(event))

void SendMessageToUnity(NSString *action);
void SendMessageToUnity(NSString *action, NSString *msg);

void SendMessageToUnity(const char* action);
void SendMessageToUnity(const char* action, const char* msg);

