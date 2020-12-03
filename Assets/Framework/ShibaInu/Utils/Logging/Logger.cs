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
            switch (type)
            {
                case LogType.Exception:
                case LogType.Assert:
                    string logType = type.ToString();
                    stackTrace = string.Format("\nstack traceback:\n\t{0}", stackTrace.TrimEnd().Replace("\n", "\n\t"));
                    LogData.Append(logType, condition, stackTrace);
                    UncaughtExceptionHandler(logType, condition, stackTrace);
                    break;

                case LogType.Warning:
                    // 将 DoTween 回调中的报错从 Warning 转为 Error
                    int idx = condition.IndexOf("An error inside a tween callback");
                    if (idx != -1)
                    {
                        condition = condition.Substring(condition.IndexOf('►', idx) + 1);
                        int idx1 = condition.IndexOf('\n');
                        int idx2 = condition.IndexOf("\n\n", idx1);
                        stackTrace = condition.Substring(idx1, idx2 - idx1);
                        condition = condition.Substring(0, idx1);
                        condition = "[tween callback]" + condition;
                        LogError(condition, stackTrace);
                        UncaughtExceptionHandler(LogData.TYPE_ERROR, condition, stackTrace);
                    }
                    break;
            }
        }


        /// <summary>
        /// 调用异常收集回调
        /// </summary>
        /// <param name="type"></param>
        /// <param name="msg"></param>
        /// <param name="stackTrace"></param>
        private static void UncaughtExceptionHandler(string type, string msg, string stackTrace)
        {
            if (s_uncaughtExceptionHandler != null)
            {
                s_uncaughtExceptionHandler.BeginPCall();
                s_uncaughtExceptionHandler.Push(type);
                s_uncaughtExceptionHandler.Push(msg);
                s_uncaughtExceptionHandler.Push(stackTrace);
                s_uncaughtExceptionHandler.PCall();
                s_uncaughtExceptionHandler.EndPCall();
            }
        }


        /// <summary>
        /// 设置异常收集回调
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

