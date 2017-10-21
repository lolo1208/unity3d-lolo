using System;
using UnityEngine;

namespace ShibaInu
{
	public class Constants
	{
		
#if UNITY_EDITOR
		public const bool isDebug = true;

#elif UNITY_STANDALONE
		public const bool isDebug = true;

#else
		public const bool isDebug = false;

#endif

		public const string GameObjectName = "[ShibaInu]";
		public const string LauncherSceneName = "Launcher";
		public const int FrameRate = 60;



		/// ToLua 框架根目录
		public static string ToLuaRootPath {
			get {
				return Application.dataPath + "/Framework/ToLua/";
			}
		}

		/// ShibaInu 框架根目录
		public static string ShibaInuRootPath {
			get {
				return Application.dataPath + "/Framework/ShibaInu/";
			}
		}


	}
}

