using System;
using UnityEngine;

namespace ShibaInu
{
	public class Constants
	{
		
		/// 目标帧频
		public const int FrameRate = 60;
		/// 不销毁的根节点
		public const string GameObjectName = "[ShibaInu]";
		/// 启动场景的名称
		public const string LauncherSceneName = "Launcher";

		/// lua 文件后缀名
		public const string LuaExtName = ".lua";
		/// AssetBundle（以及场景文件）后缀名
		public const string AbExtName = ".unity3d";

		/// APP包内容根目录
		public static readonly string PackageDir = Application.streamingAssetsPath + "/";
		/// 更新内容根目录
		public static readonly string UpdateDir = Application.persistentDataPath + "/";

		/// ToLua 框架根目录
		public static readonly string ToLuaRootPath = Application.dataPath + "/Framework/ToLua/";
		/// ShibaInu 框架根目录
		public static readonly string ShibaInuRootPath = Application.dataPath + "/Framework/ShibaInu/";


		// -- errors --

		public const string E1001 = "[ERROR] 资源文件不存在 path: {0}";
		public const string E1002 = "[ERROR] AssetBundle文件不存在 pathMD5: {0}";
		public const string E1003 = "[ERROR] lua文件不存在 path: {0}";

		public const string E9001 = "[ERROR] 编码 lua 出现错误 path: {0}";

	}
}

