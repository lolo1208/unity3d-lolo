using System;
using UnityEngine;

namespace ShibaInu
{
	public class Constants
	{
		
		/// 目标帧频
		public const int FrameRate = 60;
		/// 固定宽度
		public const int FixedWidth = 1136;
		/// 是否按 FixedWidth 等比降低分辨率
		public static bool OptimizeResolution = false;
		/// 是否永不休眠
		public static bool NeverSleep = true;



		/// 不销毁的根节点
		public const string GameObjectName = "[ShibaInu]";
		/// 启动场景的名称
		public const string LauncherSceneName = "Launcher";
		/// 空场景的名称
		public const string EmptySceneName = "Empty";

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

		/// 资源文件夹路径
		public const string ResDirPath = "Assets/Res/";


		// -- runtime errors --
		public const string E1002 = "[C# ERROR] lua文件不存在 path: {0}";

		// -- editor play mode errors --
		public const string E5001 = "[C# ERROR] 资源文件不存在 path: {0}";

		// -- packager errors --
		public const string E9001 = "[C# ERROR] 编码 lua 出现错误 path: {0}";

	}
}

