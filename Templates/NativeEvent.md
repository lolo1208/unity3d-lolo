## NativeEvent / NativeHelper
该篇将介绍 Lua(C#) 与 Native(Java/OC) 通信的方式


#### Lua
```lua
-- 向 Native 发送消息
SendMessageToNative("这是action", "这是message")

-- 接收 Native 发来的消息
AddEventListener(Stage, NativeEvent.RECEIVE_MESSAGE, self.OnReceiveNativeMsg, self)

---@param event NativeEvent
function TestScene:OnReceiveNativeMsg(event)
    print("收到 Native 事件：", event.action, event.message)
end
```


#### Java
```java
// 向 Unity 发送消息
shibaInu.util.NativeHelper.sendMessageToUnity("这是action", "这是message");

// 接收 Unity 发来的消息（注册回调）
int handleID = shibaInu.util.NativeHelper.registerUnityMsgCallback(this::unityMsgCallback);
// 移除回调
shibaInu.util.NativeHelper.unregisterUnityMsgCallback(handleID);

// 接收 Unity 发来的消息（匿名方式注册回调）
handleID = shibaInu.util.NativeHelper.registerUnityMsgCallback((action, msg) -> {
    Log.d("UnityMsgCallback", "act=" + action + ", msg=" + msg);
});
```


#### OC
```objc
// 向 Unity 发送消息
#include "NativeHelper.h"
SendMessageToUnity(@"action", @"NSString 字符串");
SendMessageToUnity("action", "char* 字符串");

// 接收 Unity 发来的消息
#include "NativeHelper.h"
[[NSNotificationCenter defaultCenter]
 addObserverForName:UNITY_MSG_NOTIF_NAME object:nil queue:[NSOperationQueue mainQueue]
 usingBlock:^(NSNotification *notification){
    NSDictionary *data = [notification object];
    NSLog(@"action = %@", [data objectForKey:UNITY_MSG_KEY_ACT]);
    NSLog(@"msg = %@", [data objectForKey:UNITY_MSG_KEY_MSG]);
}];

// 不使用匿名函数接收通知，或移除通知侦听，可参见：
// https://developer.apple.com/documentation/foundation/nsnotificationcenter
```

