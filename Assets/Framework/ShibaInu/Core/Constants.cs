using UnityEngine;


namespace ShibaInu
{
    public static class Constants
    {
        /// APP 包体内容根目录
        public static readonly string PackageDir = Application.streamingAssetsPath + "/";
        /// 更新内容根目录
        public static readonly string UpdateDir = Application.persistentDataPath + "/update/";
        /// 更新包储存目录
        public static readonly string PatchDir = Application.persistentDataPath + "/patch/";


#if UNITY_EDITOR
        /// ToLua 框架根目录
        public static readonly string ToLuaRootPath = Application.dataPath + "/Framework/ToLua/";
        /// ShibaInu 框架根目录
        public static readonly string ShibaInuRootPath = Application.dataPath + "/Framework/ShibaInu/";

        /// 进入 AssetBundle 模式的标志文件
        public static readonly string ABModeFilePath = Application.streamingAssetsPath + "/AssetBundleMode.flag";

        /// StreamingAssets 文件夹路径
        public const string StreamingAssetsDirPath = "Assets/StreamingAssets/";
#endif


        /// 不销毁的根节点名称
        public const string GameObjectName = "[ShibaInu]";
        /// 场景根节点名称
        public const string SceneRootName = "[Root]";
        /// 空场景的名称
        public const string EmptySceneName = "Empty";
        /// 版本信息文件名称
        public const string VerCfgFileName = "version.cfg";
        /// 版本信息记录在 PlayerPrefs 中使用的 key
        public const string VerInfoPPK = "INSTALLED_VERSION";
        /// Shaders 变体信息文件路径
        public const string SvcFilePath = "Shaders/Shaders.shadervariants";
        /// 资源文件夹路径
        public const string ResDirPath = "Assets/Res/";
        /// 默认资源组名称（仅在启动时使用，随后会销毁）
        public const string DefaultAssetGroup = "Default";
        /// 核心资源组名称（不会被销毁）
        public const string CoreAssetGroup = "Core";



        // 资源后缀
        public const string EXT_LUA = ".lua";
        public const string EXT_SCENE = ".scene";
        public const string EXT_AB = ".ab";
        public const string EXT_BYTES = ".bytes";


        // -- runtime errors --
        public const string E1002 = "[C# ERROR] lua 文件不存在: {0}";
        public const string E1003 = "[C# ERROR] 动画不存在，id: {0}";
        public const string E1004 = "[C# ERROR] 文件不存在: {0}";

        public const string W1001 = "[C# WARNING] 在执行 {0} 函数时，Camera.main 的值为 null";

        // -- editor play mode errors --
        public const string E5001 = "[C# ERROR] 资源文件不存在: {0}"; // editor error & runtime warning
        public const string E5002 = "[C# ERROR] 文件路径大小写不匹配: {0}";
        public const string E5003 = "[C# ERROR] Res 与 StreamingAssets 目录存在相同路径的文件: {0}";


    }
}

