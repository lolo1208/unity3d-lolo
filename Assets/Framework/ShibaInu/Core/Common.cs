using System;
using UnityEngine;


namespace ShibaInu
{
	public class Common
	{

		/// 是否在编辑器中运行，并且在开发模式下
		public static bool isDebug;

		/// 不会被销毁的 GameObject
		public static GameObject go;

		public static ThreadManager threadMgr;
		public static LuaManager luaMgr;
		public static TimerManager timerMgr;
		public static StageLooper looper;

	}
}

