using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

    /// <summary>
    /// 日志记录
    /// </summary>
    public static class Logger
    {
        private static LuaFunction s_uncaughtExceptionHandler;


        [NoToLua]
        public static void Initialize()
        {
            Application.logMessageReceived += UnityLogCallback;
        }


        /// <summary>
        /// Unity 日志回调
        /// </summary>
        /// <param name="condition">Condition.</param>
        /// <param name="stackTrace">Stack trace.</param>
        /// <param name="type">Type.</param>
        private static void UnityLogCallback(string condition, string stackTrace, LogType type)
        {
            if (type == LogType.Exception || type == LogType.Assert)
            {
                string logType = type.ToString();
                stackTrace = string.Format("\nstack traceback:\n\t{0}", stackTrace.TrimEnd().Replace("\n", "\n\t"));
                LogData.Append(logType, condition, stackTrace);

                if (s_uncaughtExceptionHandler != null)
                {
                    s_uncaughtExceptionHandler.BeginPCall();
                    s_uncaughtExceptionHandler.Push(logType);
                    s_uncaughtExceptionHandler.Push(condition);
                    s_uncaughtExceptionHandler.Push(stackTrace);
                    s_uncaughtExceptionHandler.PCall();
                    s_uncaughtExceptionHandler.EndPCall();
                }
            }
        }


        /// <summary>
        /// 设置出现未捕获异常时的回调
        /// </summary>
        /// <param name="callback">Callback.</param>
        public static void SetUncaughtExceptionHandler(LuaFunction callback)
        {
            s_uncaughtExceptionHandler = callback;
        }



        /// <summary>
        /// 添加一条普通日志
        /// </summary>
        /// <param name="msg">Message.</param>
        /// <param name="type">Type.</param>
        /// <param name="stackTrace">Stack trace.</param>
        public static void Log(string msg, string type = LogData.TYPE_LOG, string stackTrace = null)
        {
            LogData data = LogData.Append(type.Trim(), msg, stackTrace);
            Debug.Log(data);
        }


        /// <summary>
        /// 添加一条警告日志
        /// </summary>
        /// <param name="msg">Message.</param>
        /// <param name="stackTrace">Stack trace.</param>
        public static void LogWarning(string msg, string stackTrace)
        {
            LogData data = LogData.Append(LogData.TYPE_WARNING, msg, stackTrace);
            Debug.LogWarning(data);
        }


        /// <summary>
        /// 添加一条错误日志
        /// </summary>
        /// <param name="msg">Message.</param>
        /// <param name="stackTrace">Stack trace.</param>
        public static void LogError(string msg, string stackTrace)
        {
            LogData data = LogData.Append(LogData.TYPE_ERROR, msg, stackTrace);
            Debug.LogError(data);
        }


        /// <summary>
        /// 添加一条网络日志
        /// </summary>
        /// <param name="msg">Message.</param>
        /// <param name="type">Type.</param>
        /// <param name="info">Info.</param>
        public static void LogNet(string msg, string type, string info)
        {
            LogData.Append(type, msg, "\ninfo: " + info);
        }



        /// <summary>
        /// [C#] 添加一条异常日志
        /// </summary>
        /// <param name="exception">Exception.</param>
        [NoToLua]
        public static void LogException(Exception exception)
        {
            Debug.LogException(exception);
        }

        [NoToLua]
        public static void LogException(string message)
        {
            Debug.LogException(new Exception(message));
        }



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_uncaughtExceptionHandler = null;
        }

        #endregion


        //
    }
}

