using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 网络相关
    /// </summary>
    public static class NetHelper
    {
        private const int NET_TYPE_NOT = 0; // 无网络
        private const int NET_TYPE_WIFI = 1; // WiFi
        private const int NET_TYPE_MOBILE = 2; // 4G

        private const string EVENT_NET_TYPE_CHANGED = "NetEvent_NetTypeChanged"; // 网络类型有变化
        private const string EVENT_PING = "NetEvent_Ping"; // 有新的 ping 值

        private static bool s_watchNetTypeChange;
        private static int s_curNetType;
        private static int s_lastNetType;
        private static float s_wntcInterval;
        private static float s_wntcLastTime; // 上次获取网络状态的时间

        private static bool s_pinging;
        private static Ping s_ping;
        private static float s_pingValue; // 得到的 ping 值（毫秒）
        private static string s_pingAddress;
        private static float s_pingInterval;
        private static int s_pingCount;
        private static int s_pingTimes; // 已 send ping 次数
        private static float s_pingLastTime; // 上次 send ping 的时间



        [NoToLua]
        public static void Update()
        {
            if (s_watchNetTypeChange && TimeUtil.timeSec - s_wntcLastTime >= s_wntcInterval)
            {
                s_wntcLastTime = TimeUtil.timeSec;
                // 网络类型有改变
                int netType = GetNetType();
                if (netType != s_curNetType)
                {
                    s_lastNetType = s_curNetType;
                    s_curNetType = netType;
                    DispatchEvent(EVENT_NET_TYPE_CHANGED);
                }
            }

            if (s_pinging)
            {
                bool pinged = false;

                // 获取 ping 值
                if (s_ping != null && s_ping.isDone)
                {
                    s_pingValue = s_ping.time;
                    s_ping = null;
                    pinged = true;
                }

                // 达到了 ping 间隔
                if (TimeUtil.timeSec - s_pingLastTime >= s_pingInterval)
                {
                    // timeout
                    if (s_ping != null)
                    {
                        s_pingValue = -1;
                        pinged = true;
                    }

                    if (s_pingCount == 0 || s_pingTimes < s_pingCount)
                    {
                        s_pingTimes++;
                        s_ping = new Ping(s_pingAddress);
                        s_pingLastTime = TimeUtil.timeSec;
                    }
                }

                if (pinged)
                {
                    s_pinging = s_pingCount == 0 || s_pingTimes < s_pingCount;
                    DispatchEvent(EVENT_PING);
                }
            }
        }



        #region 网络类型

        /// <summary>
        /// 监听网络类型，在有变化时，抛出对应事件
        /// </summary>
        /// <returns>Current net type.</returns>
        /// <param name="interval">获取网络状态间隔（秒）</param>
        public static int WatchNetTypeChange(float interval = 2)
        {
            s_watchNetTypeChange = true;
            s_curNetType = GetNetType();
            s_wntcInterval = interval;
            s_wntcLastTime = TimeUtil.GetTimeSec() - interval;
            return s_curNetType;
        }


        /// <summary>
        /// 不再监听网络类型变化
        /// </summary>
        /// <returns>Current net type.</returns>
        public static int UnwathNetTypeChange()
        {
            s_watchNetTypeChange = false;
            return GetNetType();
        }


        /// <summary>
        /// 获取当前网络类型
        /// </summary>
        /// <returns>The net type.</returns>
        public static int GetNetType()
        {
            switch (Application.internetReachability)
            {
                case NetworkReachability.ReachableViaLocalAreaNetwork:
                    return NET_TYPE_WIFI;
                case NetworkReachability.ReachableViaCarrierDataNetwork:
                    return NET_TYPE_MOBILE;
            }
            return NET_TYPE_NOT;
        }

        #endregion



        #region Ping

        /// <summary>
        /// 开始向指定主机发送 ping，获取 ping 值
        /// </summary>
        /// <param name="address">目标主机地址</param>
        /// <param name="count">ping 多少次，0 表示无限次</param>
        /// <param name="interval">ping 间隔（秒），也是超时时间</param>
        public static void StartPing(string address, int count = 0, float interval = 1)
        {
            s_pinging = true;
            s_pingAddress = address;
            s_pingCount = count;
            s_pingInterval = interval;
            s_pingLastTime = TimeUtil.GetTimeSec() - interval;
            s_pingTimes = 0;
        }


        /// <summary>
        /// 停止向目标主机发送 ping
        /// </summary>
        public static void StopPing()
        {
            s_pinging = false;
        }

        #endregion



        #region lua 相关

        // lua NetEvent.DispatchEvent()
        private static LuaFunction s_dispatchEvent;


        /// <summary>
        /// 在 lua 层抛出 NetEvent
        /// </summary>
        /// <param name="type">Type.</param>
        private static void DispatchEvent(string type)
        {
            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("NetEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(type);
            if (type == EVENT_NET_TYPE_CHANGED)
            {
                s_dispatchEvent.Push(s_curNetType);
                s_dispatchEvent.Push(s_lastNetType);
                s_dispatchEvent.Push(0);
            }
            else
            {
                s_dispatchEvent.Push(0);
                s_dispatchEvent.Push(0);
                s_dispatchEvent.Push(s_pingValue);
            }
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_dispatchEvent = null;
            s_watchNetTypeChange = false;
            s_pinging = false;
        }

        #endregion


        //
    }
}
