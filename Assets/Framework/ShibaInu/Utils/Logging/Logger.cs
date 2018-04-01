using System;
using UnityEngine;


namespace ShibaInu
{

	/// <summary>
	/// 日志相关
	/// </summary>
	public class Logger
	{
		public Logger ()
		{
		}


		public static void AddErrorLog (string msg)
		{
			Debug.Log ("[C#ERROR]" + msg);
		}

		public static void AddErrorLog (Exception e)
		{
			AddErrorLog (e.ToString ());
		}


		//
	}
}

