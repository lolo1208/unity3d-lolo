using System;
using UnityEngine;

namespace ShibaInu
{
    public static class Constants
    {


#if UNITY_ANDROID && !UNITY_EDITOR
		/// APP 包体内容根目录 - Android
		public static readonly string PackageDir = Application.dataPath + "!assets/";
#else
        /// APP 包体内容根目录
        public static readonly string PackageDir = Application.streamingAssetsPath + "/";
#endif
        /// 更新内容根目录
        public static readonly string UpdateDir = Application.persistentDataPath + "/";



#if UNITY_EDITOR
        /// ToLua 框架根目录
        public static readonly string ToLuaRootPath = Application.dataPath + "/Framework/ToLua/";
        /// ShibaInu 框架根目录
        public static readonly string ShibaInuRootPath = Application.dataPath + "/Framework/ShibaInu/";

        /// 进入 AssetBundle 模式的标志文件
        public static readonly string ABModeFilePath = Application.streamingAssetsPath + "/AssetBundleMode.tmp";
#endif



        /// 不销毁的根节点名称
        public const string GameObjectName = "[ShibaInu]";
        /// 启动场景的名称
        public const string LauncherSceneName = "Launcher";
        /// 空场景的名称
        public const string EmptySceneName = "Empty";
        /// 版本信息文件名称
        public const string VerCfgFileName = "version.cfg";
        /// 资源文件夹路径
        public const string ResDirPath = "Assets/Res/";
        /// 核心资源组名称（不会被销毁）
        public const string CoreAssetGroup = "Core";



        // -- runtime errors --
        public const string E1002 = "[C# ERROR] lua 文件不存在: {0}";

        // -- editor play mode errors --
        public const string E5001 = "[C# ERROR] 资源文件不存在: {0}";


    }
}

