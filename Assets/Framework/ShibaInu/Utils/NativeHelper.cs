using System.Runtime.InteropServices;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

    /// <summary>
    /// 用于和 Native(Java/OC) 互发消息的工具类
    /// </summary>
    public static class NativeHelper
    {


        #region 向 Native 发送消息

        public static void SendMessageToNative(string action, string msg = "")
        {
#if UNITY_ANDROID && !UNITY_EDITOR

            m_androidNativeHelper.CallStatic("onReceiveUnityMessage", action, msg);

#elif UNITY_IOS && !UNITY_EDITOR

            OnReceiveUnityMessageImpl(action, msg);

#endif
        }

        #endregion




        #region 收到 Native 发来的消息时，在 lua 层派发事件

        // lua NativeEvent.DispatchEvent()
        private static LuaFunction s_dispatchEvent;

        public static void OnReceiveNativeMessage(string msg)
        {
            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("NativeEvent.DispatchEvent");

            int sepIdx = msg.IndexOf('#');
            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(msg.Substring(0, sepIdx));
            s_dispatchEvent.Push(msg.Substring(sepIdx + 1));
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion




#if UNITY_ANDROID && !UNITY_EDITOR

        private static readonly AndroidJavaClass m_androidNativeHelper = new AndroidJavaClass("shibaInu.util.NativeHelper");

#endif


#if UNITY_IOS && !UNITY_EDITOR

        [DllImport("__Internal")]
        private static extern void OnReceiveUnityMessageImpl(string action, string msg);

#endif




        #region 清空所有引用（在动更结束后重启 app 时）

        public static void ClearReference()
        {
            s_dispatchEvent = null;
        }

        #endregion


        //
    }
}
