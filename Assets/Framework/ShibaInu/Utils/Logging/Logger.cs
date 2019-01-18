using System;
using System.Text;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

	/// <summary>
	/// 日志记录
	/// </summary>
	public class Logger
	{


		[NoToLuaAttribute]
		public static void Initialize ()
		{
			Application.logMessageReceived += UnityLogCallback;
		}


		/// <summary>
		/// Unity 日志回调
		/// </summary>
		/// <param name="condition">Condition.</param>
		/// <param name="stackTrace">Stack trace.</param>
		/// <param name="type">Type.</param>
		private static void UnityLogCallback (string condition, string stackTrace, LogType type)
		{
			if (type == LogType.Exception || type == LogType.Assert) {
				LogData.Append (
					type.ToString (),
					condition,
					string.Format ("\nstack traceback:\n\t{0}", stackTrace.TrimEnd ().Replace ("\n", "\n\t"))
				);
			}
		}




		/// <summary>
		/// 添加一条普通日志
		/// </summary>
		/// <param name="msg">Message.</param>
		/// <param name="type">Type.</param>
		/// <param name="stackTrace">Stack trace.</param>
		public static void Log (string msg, string type = LogData.TYPE_LOG, string stackTrace = null)
		{
			LogData data = LogData.Append (type.Trim (), msg, stackTrace);
			Debug.Log (data);
		}


		/// <summary>
		/// 添加一条警告日志
		/// </summary>
		/// <param name="msg">Message.</param>
		/// <param name="stackTrace">Stack trace.</param>
		public static void LogWarning (string msg, string stackTrace)
		{
			LogData data = LogData.Append (LogData.TYPE_WARNING, msg, stackTrace);
			Debug.LogWarning (data);
		}


		/// <summary>
		/// 添加一条错误日志
		/// </summary>
		/// <param name="msg">Message.</param>
		/// <param name="stackTrace">Stack trace.</param>
		public static void LogError (string msg, string stackTrace)
		{
			LogData data = LogData.Append (LogData.TYPE_ERROR, msg, stackTrace);
			Debug.LogError (data);
		}


		/// <summary>
		/// 添加一条网络日志
		/// </summary>
		/// <param name="msg">Message.</param>
		/// <param name="type">Type.</param>
		/// <param name="info">Info.</param>
		public static void LogNet (string msg, string type, string info)
		{
			LogData.Append (type, msg, "\ninfo: " + info);
		}




		/// <summary>
		/// [C#] 添加一条异常日志
		/// </summary>
		/// <param name="exception">Exception.</param>
		[NoToLuaAttribute]
		public static void LogException (Exception exception)
		{
			Debug.LogException (exception);
		}

		[NoToLuaAttribute]
		public static void LogException (string message)
		{
			Debug.LogException (new Exception (message));
		}


		//
	}
}

