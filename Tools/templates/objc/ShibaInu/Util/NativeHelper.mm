//
//  NativeHelper.mm
//
//  Unity 与 Native 通信相关工具类
//  Created by LOLO on 2020/08/08.
//

#import "NativeHelper.h"
#import <UnityFramework/UnityFramework.h>



#pragma mark -

NSString * const APP_CTR_PROT_NOTIF_NAME = @"OnReceiveAppControllerProtocol";
NSString * const UNITY_MSG_NOTIF_NAME = @"OnReceiveUnityMessage";
NSString * const UNITY_MSG_KEY_ACT = @"action";
NSString * const UNITY_MSG_KEY_MSG = @"msg";
NSString * const UNITY_MSG_SEPARATOR = @"‖";



#pragma mark -
extern "C" {

void SendMessageToUnity(NSString *action, NSString *msg)
{
    [[UnityFramework getInstance] sendMessageToGOWithName:"[ShibaInu]" functionName:"OnReceiveNativeMessage" message:[[NSString stringWithFormat:@"%@#%@", action, msg] UTF8String]];
}

void SendMessageToUnityAction(NSString *action)
{
    SendMessageToUnity(action, @"");
}


void SendMessageToUnity_CString(const char* action, const char* msg)
{
    SendMessageToUnity([NSString stringWithUTF8String:action],
                       [NSString stringWithUTF8String:msg]
                       );
}

void SendMessageToUnityAction_CString(const char* action)
{
    SendMessageToUnity([NSString stringWithUTF8String:action], @"");
}

}

