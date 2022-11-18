using UnityEngine;


namespace ShibaInu
{
    public static class Common
    {

        public static VersionInfo VersionInfo = new VersionInfo
        {
            CoreVersion = "0.0.0", // C# 程序版本号（手动维护）
            FullVersion = "0.0.0.0.0",
            ResVersion = "0.0.0",
            BuildNumber = "0",
            PackID = "0"
        };


        /// 是否在编辑器中运行，并且在开发模式下
        public static bool IsDebug = true;

        /// 不会被销毁的 GameObject
        public static GameObject go;
        /// 游戏循环
        public static Looper looper;
        /// lua 管理器
        public static LuaManager luaMgr;


        /// 初始化是否已经完成（项目已启动）
        public static bool Initialized
        {
            get
            {
#if UNITY_EDITOR
                return Application.isPlaying && s_initialized;
#else
				return s_initialized;
#endif
            }
            set { s_initialized = value; }
        }
        private static bool s_initialized;



        /// <summary>
        /// 项目帧率
        /// </summary>
        /// <value>The frame rate.</value>
        public static int FrameRate
        {
            set { Application.targetFrameRate = value; }
            get { return Application.targetFrameRate; }
        }



        /// <summary>
        /// 是否永不休眠
        /// </summary>
        /// <param name="value">If set to <c>true</c> value.</param>
        public static bool IsNeverSleep
        {
            set
            {
                Screen.sleepTimeout = value ? SleepTimeout.NeverSleep : SleepTimeout.SystemSetting;
            }
            get { return Screen.sleepTimeout == SleepTimeout.NeverSleep; }
        }



        /// <summary>
        /// 是否按照固定值来等比缩放分辨率
        /// </summary>
        /// <value><c>true</c> if is optimize resolution; otherwise, <c>false</c>.</value>
        public static bool IsOptimizeResolution
        {
            set
            {
                if (value != s_isOptimizeResolution)
                {
                    s_isOptimizeResolution = value;
                    if (value) OptimizeResolution();

#if UNITY_EDITOR
                    if (looper != null)
                    {
                        if (value)
                            looper.ResizeHandler.Add(OptimizeResolution);
                        else
                            looper.ResizeHandler.Remove(OptimizeResolution);
                    }
#endif
                }
            }
            get { return s_isOptimizeResolution; }
        }
        private static bool s_isOptimizeResolution = false;


        /// <summary>
        /// 按照固定值来等比缩放辨率
        /// </summary>
        /// <param name="ignored">Ignored.</param>
        public static void OptimizeResolution(object ignored = null)
        {
            if (Stage.uiCanvasScaler == null) return;

            int screenWidth = Screen.width;
            int screenHeight = Screen.height;
            float scale = GetFixedScreenScale();
            Vector2 resolution = Stage.uiCanvasScaler.referenceResolution;
            int width, height;
            if (resolution.x / screenWidth > resolution.y / screenHeight)
            {
                width = Mathf.CeilToInt(resolution.x);
                height = Mathf.CeilToInt(screenHeight * scale);
            }
            else
            {
                width = Mathf.CeilToInt(screenWidth * scale);
                height = Mathf.CeilToInt(resolution.y);
            }
            Screen.SetResolution(width, height, true); // 更改分辨率时，Looper 会调用 DeviceHelper.UpdateSafeInsets()
            Debug.LogFormat("[ShibaInu.Common] screen: {0}x{1},  scale: {2},  set resolution: {3}x{4}", screenWidth, screenHeight, scale, width, height);
        }



        /// <summary>
        /// 获取 固定值 / 屏幕尺寸 的缩放比例
        /// </summary>
        /// <returns>The scale.</returns>
        public static float GetFixedScreenScale()
        {
            Vector2 resolution = Stage.uiCanvasScaler.referenceResolution;
            float rw = resolution.x / Screen.width;
            float rh = resolution.y / Screen.height;
            return rw > rh ? rw : rh;
        }


        //
    }


    public struct VersionInfo
    {
        public string CoreVersion; /// C# 程序版本号（手动维护）
        public string FullVersion; /// 完整版本号（自动获取）
        public string ResVersion; /// 资源版本号（自动获取）
        public string BuildNumber; /// 打包编号（自动获取）
        public string PackID; /// 打包唯一标识符（自动获取）
    };

}