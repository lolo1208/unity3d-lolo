#pragma once



// 接收 Unity 发来的消息：
// --
// #include "NativeHelper.h"
// [[NSNotificationCenter defaultCenter]
//  addObserverForName:UNITY_MSG_NOTIF_NAME object:nil queue:[NSOperationQueue mainQueue]
//  usingBlock:^(NSNotification *notification){
//     NSDictionary *data = [notification object];
//     NSLog(@"action = %@", [data objectForKey:UNITY_MSG_KEY_ACT]);
//     NSLog(@"msg = %@", [data objectForKey:UNITY_MSG_KEY_MSG]);
// }];
// --
// 不使用匿名函数接收通知，或移除通知侦听，可参见：
// https://developer.apple.com/documentation/foundation/nsnotificationcenter
// --
// lua 层向 Native 发送消息可调用全局函数：
// SendMessageToNative("unitySay", "hello你好")
//

// 收到 Unity 发来的消息时，会用该名称在 NSNotificationCenter 派发通知
extern NSString *const UNITY_MSG_NOTIF_NAME;
extern NSString *const UNITY_MSG_KEY_ACT;
extern NSString *const UNITY_MSG_KEY_MSG;



// 向 Unity 发送消息：
// ---
// #include "NativeHelper.h"
// SendMessageToUnity(@"action", @"NSString 字符串");
// SendMessageToUnity("action", "char* 字符串");
// ---
// 向 Unity 发送消息后，lua 层会派发 NativeEvent，可在 Stage 上侦听：
// AddEventListener(Stage, NativeEvent.RECEIVE_MESSAGE, fun(event))

void SendMessageToUnity(NSString* action, NSString* msg);
void SendMessageToUnity(const char* action, const char* msg);

