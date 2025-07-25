//
// Unity 与 Native 通信相关工具类
// Created by LOLO on 2020/08/08.
//

#import "NativeUtil.h"



#pragma mark -

// 这里与 NativeHelper 相比，像是重复定义。
// NativeUtil 是给 UnityFramework 使用的，NativeHelper 供 Target 使用。

NSString * const APP_CTR_PROT_NOTIF_NAME = @"OnReceiveAppControllerProtocol";
NSString * const UNITY_MSG_NOTIF_NAME = @"OnReceiveUnityMessage";
NSString * const UNITY_MSG_KEY_ACT = @"action";
NSString * const UNITY_MSG_KEY_MSG = @"msg";



#pragma mark -
extern "C" void OnReceiveUnityMessageImpl(const char* action, const char* msg)
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UNITY_MSG_NOTIF_NAME object:@{
         UNITY_MSG_KEY_ACT:[NSString stringWithUTF8String:action],
         UNITY_MSG_KEY_MSG:[NSString stringWithUTF8String:msg]
     }];
}

