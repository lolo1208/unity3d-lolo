using System.Collections.Generic;
using System.IO;
using UnityEngine;


namespace App
{
    public static class Manifest
    {

        /// 版本信息文件名称
        public const string VerCfgFileName = "version.cfg";


#if UNITY_ANDROID && !UNITY_EDITOR
        /// APP 包体内容根目录 - Android
        public static readonly string PackageDir = Application.dataPath + "!assets/";
#else
        /// APP 包体内容根目录
        public static readonly string PackageDir = Application.streamingAssetsPath + "/";
#endif
        /// 更新内容根目录
        public static readonly string UpdateDir = Application.persistentDataPath + "/update/";

        /// 进入 AssetBundle 模式的标志文件
        public static readonly string ABModeFilePath = Application.streamingAssetsPath + "/AssetBundleMode.flag";

        /// 是否在编辑器中运行，并且在开发模式下
        private static bool IsDebug = false;
        /// 是否已经初始化
        private static bool s_initialized = false;
        /// 直接拷贝的文件列表[ key = 文件原始路径（不带 Assets/Res 或 Assets/StreamingAssets），value = 包内文件名 ]
        private static readonly Dictionary<string, string> s_bytesMap = new Dictionary<string, string>();



        /// <summary>
        /// 初始化
        /// </summary>
        private static void Initialize()
        {
            if (s_initialized) return;
            s_initialized = true;

#if UNITY_EDITOR
            IsDebug = !File.Exists(ABModeFilePath);
            if (IsDebug) return;
#endif

            // 获取版本信息文件路径
            string verCfgFilePath = UpdateDir + VerCfgFileName;
            bool hasUpdate = FileExists(verCfgFilePath);// 是否有更新过
            if (!hasUpdate)// 从未更新过
                verCfgFilePath = PackageDir + VerCfgFileName;

            // 获取并解析版本号
            string fullVersion = GetFileText(verCfgFilePath);

            // 解析资源清单文件
            string manifestFilePath = (hasUpdate ? UpdateDir : PackageDir) + fullVersion + ".manifest";
            using (StreamReader file = new StreamReader(new MemoryStream(GetFileBytes(manifestFilePath))))
            {
                string line;
                int phase = 1, index = 0, count = 0;
                while ((line = file.ReadLine()) != null)
                {
                    switch (phase)
                    {
                        // lua
                        case 1:
                            if (count == 0)
                                count = int.Parse(line);
                            else
                            {
                                file.ReadLine();
                                if (++index == count)
                                {
                                    count = index = 0;
                                    phase++;
                                }
                            }
                            break;

                        // bytes
                        case 2:
                            if (count == 0)
                            {
                                count = int.Parse(line);
                                if (count == 0) phase++;
                            }
                            else
                            {
                                s_bytesMap.Add(line, file.ReadLine());
                                if (++index == count)
                                {
                                    count = index = 0;
                                    phase++;
                                }
                            }
                            break;
                    }
                    if (phase > 2) break;
                }
            }

        }


        /// <summary>
        /// 获取 Bytes 文件的路径。
        /// 在 Unity Editor，将返回传入的 path。
        /// 在设备上（AB 模式），将返回完整真实路径（已确定文件在 原始包目录 还是 更新目录）。
        /// 如果文件不存在，将返回 null。
        /// </summary>
        /// <param name="path">Res 或 StreamingAssets 目录下的文件路径。例："Prefabs/Config.binary" 或 "myAudio.bank"</param>
        /// <param name="dir">需要被替换的目录</param>
        /// <returns></returns>
        public static string GetBytesFilePath(string path, string dir = "")
        {
            Initialize();

#if UNITY_EDITOR
            if (IsDebug) return path;
#endif

            // FMOD 路径中会传入目录
            if (dir != "")
                path = path.Replace(dir + "/", "");

            string fileName;
            if (!s_bytesMap.TryGetValue(path, out fileName))
                return null;

            string fullPath = PackageDir + fileName;
            if (!FileExists(fullPath))
                fullPath = UpdateDir + fileName;
            return fullPath;
        }



        #region ShibaInu - FileHelper.cs

#if UNITY_ANDROID && !UNITY_EDITOR
        private static readonly AndroidJavaClass m_androidStreamingAssets = new AndroidJavaClass ("shibaInu.util.StreamingAssets");
#endif

        /// <summary>
        /// 文件是否存在
        /// </summary>
        /// <returns><c>true</c>, if exists was filed, <c>false</c> otherwise.</returns>
        /// <param name="path">文件路径</param>
        public static bool FileExists(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            if(path.StartsWith(PackageDir))
                return m_androidStreamingAssets.CallStatic<bool> ("exists", path.Replace(PackageDir, ""));
            else
                return File.Exists (path);
#else
            return File.Exists(path);
#endif
        }


        /// <summary>
        /// 获取文件的字节内容
        /// </summary>
        /// <returns>The file bytes.</returns>
        /// <param name="path">文件路径</param>
        public static byte[] GetFileBytes(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            if (path.StartsWith(PackageDir))
                return m_androidStreamingAssets.CallStatic<byte[]>("getBytes", path.Replace(PackageDir, ""));
            else
                return File.ReadAllBytes(path);
#else
            return File.ReadAllBytes(path);
#endif
        }


        /// <summary>
        /// 获取文件的字符串内容
        /// </summary>
        /// <returns>The file bytes.</returns>
        /// <param name="path">文件路径</param>
        public static string GetFileText(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            if (path.StartsWith(PackageDir))
                return m_androidStreamingAssets.CallStatic<string>("getText", path.Replace(PackageDir, ""));
            else
                return File.ReadAllText(path);
#else
            return File.ReadAllText(path);
#endif
        }

        #endregion



        #region 清空所有引用（在动更结束后重启 app 时）

        public static void ClearReference()
        {
            s_bytesMap.Clear();
        }

        #endregion


        //
    }
}
