//
// Unity 与 Native 通信相关工具类
// Created by LOLO on 2020/08/08.
//

#import "NativeHelper.h"
#import <UnityFramework/UnityFramework.h>



#pragma mark -

NSString * const APP_CTR_PROT_NOTIF_NAME = @"OnReceiveAppControllerProtocol";
NSString * const UNITY_MSG_NOTIF_NAME = @"OnReceiveUnityMessage";
NSString * const UNITY_MSG_KEY_ACT = @"action";
NSString * const UNITY_MSG_KEY_MSG = @"msg";



#pragma mark -

void SendMessageToUnity(NSString *action, NSString *msg)
{
    [[UnityFramework getInstance] sendMessageToGOWithName:"[ShibaInu]" functionName:"OnReceiveNativeMessage" message:[[NSString stringWithFormat:@"%@#%@", action, msg] UTF8String]];
//    UnitySendMessage("[ShibaInu]", "OnReceiveNativeMessage", [[NSString stringWithFormat:@"%@#%@", action, msg] UTF8String]);
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

