using System;
using System.Diagnostics;


namespace ShibaInu
{
    /// <summary>
    /// 时间相关工具
    /// </summary>
    public static class TimeUtil
    {

        /// 程序启动时间戳
        private static DateTime s_startupTime;

        /// 当前程序已运行时间（秒.毫秒）
        public static float timeSec;
        /// 当前程序已运行时间（毫秒）
        public static uint timeMsec;


        public static void Initialize()
        {
            s_startupTime = DateTime.Now;
        }



        /// <summary>
        /// Updates the time.
        /// </summary>
        public static void Update()
        {
            timeSec = (float)(DateTime.Now - s_startupTime).TotalSeconds;
            timeMsec = (uint)(timeSec * 1000);
        }


        /// <summary>
        /// 更新并返回当前程序已运行时间（秒.毫秒）
        /// </summary>
        /// <returns>The time sec.</returns>
        public static float GetTimeSec()
        {
            Update();
            return timeSec;
        }


        /// <summary>
        /// 更新并返回当前程序已运行时间（毫秒）
        /// </summary>
        /// <returns>The time msec.</returns>
        public static uint GetTimeMsec()
        {
            Update();
            return timeMsec;
        }


        //
    }
}

