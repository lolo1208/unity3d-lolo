#import "NativeHelper.h"


NSString *const UNITY_MSG_NOTIF_NAME = @"OnReceiveUnityMessage";
NSString *const UNITY_MSG_KEY_ACT = @"action";
NSString *const UNITY_MSG_KEY_MSG = @"msg";



void SendMessageToUnity(NSString* action, NSString* msg)
{
    UnitySendMessage("[ShibaInu]", "OnReceiveNativeMessage",
                     [[NSString stringWithFormat:@"%@#%@", action, msg] UTF8String]
                     );
}

void SendMessageToUnity(const char* action, const char* msg)
{
    SendMessageToUnity([NSString stringWithUTF8String:action],
                       [NSString stringWithUTF8String:msg]
                       );
}



extern "C" void OnReceiveUnityMessageImpl(const char* action, const char* msg)
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UNITY_MSG_NOTIF_NAME object:@{
         UNITY_MSG_KEY_ACT:[NSString stringWithUTF8String:action],
         UNITY_MSG_KEY_MSG:[NSString stringWithUTF8String:msg]
     }];
}

