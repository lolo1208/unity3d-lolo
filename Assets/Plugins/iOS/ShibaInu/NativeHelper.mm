//
// Unity 与 Native 通信相关工具类
// Created by LOLO on 2020/08/08.
//

#import "NativeHelper.h"


#pragma mark -

NSString * const UNITY_MSG_NOTIF_NAME = @"OnReceiveUnityMessage";
NSString * const UNITY_MSG_KEY_ACT = @"action";
NSString * const UNITY_MSG_KEY_MSG = @"msg";


#pragma mark -

void SendMessageToUnity(NSString *action, NSString *msg)
{
    UnitySendMessage("[ShibaInu]", "OnReceiveNativeMessage",
                     [[NSString stringWithFormat:@"%@#%@", action, msg] UTF8String]
                     );
}
void SendMessageToUnity(NSString *action)
{
    SendMessageToUnity(action, @"");
}

void SendMessageToUnity(const char* action, const char* msg)
{
    SendMessageToUnity([NSString stringWithUTF8String:action],
                       [NSString stringWithUTF8String:msg]
                       );
}
void SendMessageToUnity(const char* action)
{
    SendMessageToUnity([NSString stringWithUTF8String:action], @"");
}


#pragma mark -

extern "C" void OnReceiveUnityMessageImpl(const char* action, const char* msg)
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UNITY_MSG_NOTIF_NAME object:@{
         UNITY_MSG_KEY_ACT:[NSString stringWithUTF8String:action],
         UNITY_MSG_KEY_MSG:[NSString stringWithUTF8String:msg]
     }];
}

