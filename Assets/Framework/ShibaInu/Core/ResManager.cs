using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using LuaInterface;
using UnityEngine;
using UnityEngine.U2D;


namespace ShibaInu
{

    /// <summary>
    /// C# 层的加载资源事件对象
    /// </summary>
    public struct LoadResEvent
    {
        /// 事件类型
        public string type;
        /// 资源路径
        public string path;
        /// 资源数据
        public UnityEngine.Object data;
    }



    public static class ResManager
    {
        #region 常量/ 变量

        /// lua 列表[ key = 文件原始路径（不带框架路径和后缀），value = 包内文件名 ]
        private static readonly Dictionary<string, string> s_luaMap = new Dictionary<string, string>();
        /// 直接拷贝的文件列表[ key = 文件原始路径（不带 Assets/Res 或 Assets/StreamingAssets），value = 包内文件名 ]
        private static readonly Dictionary<string, string> s_bytesMap = new Dictionary<string, string>();
        /// 场景列表[ key = 场景名称（不带路径和后缀），value = AssetInfo 对象 ]
        private static readonly Dictionary<string, AssetInfo> s_sceneMap = new Dictionary<string, AssetInfo>();
        /// AssetInfo 列表[ key = AB文件名，value = AssetInfo 对象 ]
        private static readonly Dictionary<string, AssetInfo> s_infoMap = new Dictionary<string, AssetInfo>();
        /// 资源文件列表[ key = 资源路径，value = AssetInfo 对象 ]
        private static readonly Dictionary<string, AssetInfo> s_resMap = new Dictionary<string, AssetInfo>();

        /// 需要被延迟卸载到资源组列表
        private static readonly HashSet<string> s_delayedUnloadList = new HashSet<string>();

        /// 抛出 EVENT_ALL_COMPLETE 事件的协程对象
        private static Coroutine s_coAllComplete;

        /// 异步加载资源完成时的回调列表
        [NoToLua]
        public static readonly MultiCall<LoadResEvent> LoadCompleteHandler = new MultiCall<LoadResEvent>();
        private static LoadResEvent s_loadCompleteEvent = new LoadResEvent { type = EVENT_COMPLETE };


        /// 当前默认使用的资源加载组名称
        public static string CurrentAssetGroup
        {
            set
            {
                if (currentAssetGroup == Constants.DefaultAssetGroup && value != currentAssetGroup)
                    Unload(currentAssetGroup);
                currentAssetGroup = value;
            }

            get => currentAssetGroup;
        }

        private static string currentAssetGroup;

        #endregion



        #region 初始化 / 预加载

        /// <summary>
        /// 初始化
        /// </summary>
        [NoToLua]
        public static void Initialize()
        {
            if (Common.IsDebug) return;

            string updateVerCfgPath = Constants.UpdateDir + Constants.VerCfgFileName;// 更新目录的版本信息文件路径
            bool hasUpdate = FileHelper.Exists(updateVerCfgPath);// 是否有更新过

            string insVer = FileHelper.GetText(Constants.PackageDir + Constants.VerCfgFileName);// 底包版本信息
            string verStr = Common.VersionInfo.CoreVersion + "|" + insVer;// 当前版本信息
            string recVer = PlayerPrefs.GetString(Constants.VerInfoPPK, "");// 已记录的版本信息

            // 当前版本信息 与 记录的版本信息 不一致
            if (verStr != recVer)
            {
                PlayerPrefs.SetString(Constants.VerInfoPPK, verStr);
                if (hasUpdate)
                {
                    hasUpdate = false;
                    UpdateManager.Repair();
                }
            }


            // 获取并解析版本号
            string fullVersion = hasUpdate ? FileHelper.GetText(updateVerCfgPath) : insVer;
            Debug.LogFormat("[ShibaInu.ResManager] Full Version: {0}", fullVersion);
            Common.VersionInfo.FullVersion = fullVersion;

            string[] verStrArr = fullVersion.Split('.');
            Common.VersionInfo.PackID = verStrArr[verStrArr.Length - 1];
            Common.VersionInfo.BuildNumber = verStrArr[verStrArr.Length - 2];

            Common.VersionInfo.ResVersion = "";
            for (int i = 0; i < verStrArr.Length - 2; i++)
            {
                if (i != 0) Common.VersionInfo.ResVersion += ".";
                Common.VersionInfo.ResVersion += verStrArr[i];
            }


            // 解析资源清单文件
            string manifestFilePath = (hasUpdate ? Constants.UpdateDir : Constants.PackageDir) + fullVersion + ".manifest";
            using (StreamReader file = new StreamReader(new MemoryStream(FileHelper.GetBytes(manifestFilePath))))
            {
                string line;
                AssetInfo info = new AssetInfo("");
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
                                s_luaMap.Add(line, file.ReadLine());
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

                        // scene
                        case 3:
                            if (count == 0)
                                count = int.Parse(line);
                            else
                            {
                                s_sceneMap.Add(line, new AssetInfo(file.ReadLine()));
                                if (++index == count)
                                {
                                    count = index = 0;
                                    phase++;
                                }
                            }
                            break;

                        // AssetBundle（只能放在最后阶段）
                        case 4:
                            if (count == 0)
                            {
                                count = int.Parse(line);
                            }
                            else
                            {
                                if (index == 0)
                                {
                                    info = new AssetInfo(line);
                                    s_infoMap.Add(info.name, info);

                                    // 解析依赖列表
                                    int num = int.Parse(file.ReadLine());
                                    for (int i = 0; i < num; i++)
                                        info.pedList.Add(file.ReadLine());
                                }
                                else
                                {
                                    s_resMap.Add(line, info);
                                }

                                if (++index == count)
                                {
                                    count = index = 0;
                                }
                            }
                            break;
                    }
                }
            }
        }


        /// <summary>
        /// 预热 Shaders
        /// </summary>
        public static void WarmUpShaders(string svcPath = Constants.SvcFilePath)
        {
            if (Common.IsDebug) return;

            DateTime dateTime = DateTime.Now;
            AssetInfo info = GetAssetInfoWithAssetPath(svcPath);
            AssetLoader.Load(info, Constants.CoreAssetGroup);
            info.ab.LoadAllAssets();
            ShaderVariantCollection svc = info.ab.LoadAsset<ShaderVariantCollection>(Constants.ResDirPath + Constants.SvcFilePath);
            svc.WarmUp();
            Debug.LogFormat("[ShibaInu.ResManager] Shaders Preload and WarmUp: {0}", (DateTime.Now - dateTime).Milliseconds / 1000f);
        }

        #endregion



        #region 资源加载

        /// <summary>
        /// 同步加载资源
        /// </summary>
        /// <returns>The asset with type.</returns>
        /// <param name="path">Path.</param>
        /// <param name="groupName">Group name.</param>
        /// <typeparam name="T">The 1st type parameter.</typeparam>
        private static T LoadAssetWithType<T>(string path, string groupName) where T : UnityEngine.Object
        {
            if (groupName == null) groupName = currentAssetGroup;
            string fullPath = Constants.ResDirPath + path;

#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                if (!File.Exists(fullPath))
                    throw new Exception(string.Format(Constants.E5001, path));

                if (!FileHelper.IsPathCaseMatch(path))
                    throw new Exception(string.Format(Constants.E5002, path));

                return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(fullPath);
            }
#endif

            s_delayedUnloadList.Remove(groupName);

            if (s_resMap.TryGetValue(path, out AssetInfo info))
            {
                AssetLoader.Load(info, groupName);
                return info.ab.LoadAsset<T>(fullPath);
            }

            Debug.LogWarningFormat(Constants.E5001, path);
            return null;
        }


        /// <summary>
        /// 异步加载资源
        /// </summary>
        /// <param name="path">Path.</param>
        /// <param name="groupName">Group name.</param>
        /// <typeparam name="T">The 1st type parameter.</typeparam>
        private static void LoadAssetWithTypeAsync<T>(string path, string groupName) where T : UnityEngine.Object
        {
            if (groupName == null) groupName = currentAssetGroup;
            string fullPath = Constants.ResDirPath + path;

#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                if (!File.Exists(fullPath))
                    throw new Exception(string.Format(Constants.E5001, path));

                if (!FileHelper.IsPathCaseMatch(path))
                    throw new Exception(string.Format(Constants.E5002, path));

                DispatchEvent(EVENT_START, path);
                Common.looper.StartCoroutine(DispatchCompleteEvent(path,
                    UnityEditor.AssetDatabase.LoadAssetAtPath<T>(fullPath)
                ));
                return;
            }
#endif

            s_delayedUnloadList.Remove(groupName);

            if (s_resMap.TryGetValue(path, out AssetInfo info))
            {
                info.AddAsyncAsset(path, typeof(T));
                AssetLoader.LoadAsync(info, groupName);
            }
            else
                throw new Exception(string.Format(Constants.E5001, path));
        }


#if UNITY_EDITOR

        /// <summary>
        /// 延迟抛出资源异步加载完成事件
        /// </summary>
        /// <returns>The complete event.</returns>
        /// <param name="path">Path.</param>
        /// <param name="data">Data.</param>
        private static IEnumerator DispatchCompleteEvent(string path, UnityEngine.Object data)
        {
            if (s_coAllComplete != null)
            {
                Common.looper.StopCoroutine(s_coAllComplete);
                s_coAllComplete = null;
            }

            yield return new WaitForSeconds(0.1f);
            DispatchEvent(EVENT_COMPLETE, path, data);

            if (s_coAllComplete != null) Common.looper.StopCoroutine(s_coAllComplete);
            s_coAllComplete = Common.looper.StartCoroutine(DispatchAllCompleteEvent());
        }


        /// <summary>
        /// 延迟抛出所有资源异步加载完成事件
        /// </summary>
        /// <returns>The all complete event.</returns>
        private static IEnumerator DispatchAllCompleteEvent()
        {
            yield return new WaitForSeconds(0.1f);
            s_coAllComplete = null;
            DispatchEvent(EVENT_ALL_COMPLETE);
        }

#endif


        /// <summary>
        /// 获取当前异步加载总进度 0~1
        /// </summary>
        /// <returns>The progress.</returns>
        public static float GetProgress()
        {
            return AssetLoader.GetProgress();
        }

        #endregion



        #region 同步 / 异步 加载资源的对外实现

        public static string LoadText(string path, string groupName = null)
        {
            TextAsset asset = LoadAssetWithType<TextAsset>(path, groupName);
            return asset.text;
        }


        public static UnityEngine.Object LoadAsset(string path, string groupName = null)
        {
            return LoadAssetWithType<UnityEngine.Object>(path, groupName);
        }
        public static void LoadAssetAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<UnityEngine.Object>(path, groupName);
        }


        public static Sprite LoadSprite(string path, string groupName = null)
        {
            return LoadAssetWithType<Sprite>(path, groupName);
        }
        public static void LoadSpriteAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<Sprite>(path, groupName);
        }


        public static SpriteAtlas LoadSpriteAtlas(string path, string groupName = null)
        {
            return LoadAssetWithType<SpriteAtlas>(path, groupName);
        }
        public static void LoadSpriteAtlasAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<SpriteAtlas>(path, groupName);
        }


        public static AnimationClip LoadAnimationClip(string path, string groupName = null)
        {
            return LoadAssetWithType<AnimationClip>(path, groupName);
        }
        public static void LoadAnimationClipAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<AnimationClip>(path, groupName);
        }


        public static RuntimeAnimatorController LoadAnimatorController(string path, string groupName = null)
        {
            return LoadAssetWithType<RuntimeAnimatorController>(path, groupName);
        }
        public static void LoadAnimatorControllerAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<RuntimeAnimatorController>(path, groupName);
        }


        public static Shader LoadShader(string path, string groupName = null)
        {
            return LoadAssetWithType<Shader>(path, groupName);
        }
        public static void LoadShaderAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<Shader>(path, groupName);
        }


        public static AudioClip LoadAudioClip(string path, string groupName = null)
        {
            return LoadAssetWithType<AudioClip>(path, groupName);
        }
        public static void LoadAudioClipAsync(string path, string groupName = null)
        {
            LoadAssetWithTypeAsync<AudioClip>(path, groupName);
        }

        #endregion



        #region 卸载资源

        /// <summary>
        /// 卸载资源
        /// </summary>
        /// <param name="groupName">Group name.</param>
        /// <param name="delay">Delay.</param>
        public static void Unload(string groupName, float delay = 0)
        {
#if UNITY_EDITOR
            if (Common.IsDebug) return;
#endif

            if (delay > 0)
                Common.looper.StartCoroutine(DelayedUnload(groupName, delay));
            else
                AssetLoader.RemoveReference(groupName);
        }


        private static IEnumerator DelayedUnload(string groupName, float delay)
        {
            // 先添加到需要被延迟卸载到列表中，以防 delay 过程中该 groupName 又进行了加载
            s_delayedUnloadList.Add(groupName);

            yield return new WaitForSeconds(delay);

            if (s_delayedUnloadList.Contains(groupName))
            {
                s_delayedUnloadList.Remove(groupName);
                AssetLoader.RemoveReference(groupName);
            }
        }

        #endregion



        #region 其他

        /// <summary>
        /// 返回：path 对应的资源文件是否存在
        /// </summary>
        /// <param name="path">资源路径。例："Prefabs/Core/UICanvas.prefab"</param>
        /// <returns></returns>
        public static bool ResFileExists(string path)
        {
            string fullPath = Constants.ResDirPath + path;
#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                if (!File.Exists(fullPath)) return false;

                if (!FileHelper.IsPathCaseMatch(path))
                    throw new Exception(string.Format(Constants.E5002, path));

                return true;
            }
#endif
            return s_resMap.ContainsKey(path);
        }

        /// <summary>
        /// 通过 AssetBundle 的文件名来获取对应的 AssetInfo
        /// </summary>
        /// <returns>The AssetInfo with AssetBundle file name.</returns>
        /// <param name="fileName">File name.</param>
        [NoToLua]
        public static AssetInfo GetAssetInfoWithABName(string fileName)
        {
            s_infoMap.TryGetValue(fileName, out AssetInfo info);
            return info;
        }

        /// <summary>
        /// 通过 资源路径 来获取对应的 AssetInfo
        /// </summary>
        /// <returns>The AssetInfo with asset path.</returns>
        /// <param name="path">资源路径。例："Prefabs/Core/UICanvas.prefab"</param>
        [NoToLua]
        public static AssetInfo GetAssetInfoWithAssetPath(string path)
        {
            s_resMap.TryGetValue(path, out AssetInfo info);
            return info;
        }

        /// <summary>
        /// 通过 场景名称 来获取对应的 AssetInfo
        /// </summary>
        /// <returns>The AssetInfo with scene name.</returns>
        /// <param name="sceneName">Scene name.</param>
        [NoToLua]
        public static AssetInfo GetAssetInfoWithSceneName(string sceneName)
        {
            s_sceneMap.TryGetValue(sceneName, out AssetInfo info);
            return info;
        }



        /// <summary>
        /// 返回：path 对应的 lua 文件是否存在
        /// </summary>
        /// <param name="path">lua 路径。例："Module.Core.launcher" 或 "Module/Core/launcher"</param>
        /// <returns></returns>
        public static bool LuaFileExists(string path)
        {
            string fullPath = path.Replace(".", "/");
#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                fullPath = LuaFileUtils.Instance.FindFile(fullPath); // value: "Module/Core/launcher.lua"
                if (string.IsNullOrEmpty(fullPath) || !File.Exists(fullPath)) return false;

                if (!FileHelper.IsPathCaseMatch(fullPath))
                    throw new Exception(string.Format(Constants.E5002, path.Replace(".", "/") + ".lua"));

                return true;
            }
#endif
            return s_luaMap.ContainsKey(fullPath);
        }

        /// <summary>
        /// 获取 Lua 文件的字节内容
        /// </summary>
        /// <returns>The lua file bytes.</returns>
        /// <param name="path">lua 路径（不带后缀）。例："Module/Core/launcher"</param>
        [NoToLua]
        public static byte[] GetLuaFileBytes(string path)
        {
            // 不需要后缀名
            path = path.Replace(".lua", "");

            if (s_luaMap.TryGetValue(path, out string fileName))
                return FileHelper.GetBytes(AssetLoader.GetFilePath(fileName));

            throw new Exception(string.Format(Constants.E1002, path));
        }



        /// <summary>
        /// 返回：path 对应的 Bytes 文件是否存在
        /// </summary>
        /// <param name="path">Res 或 StreamingAssets 目录下的文件路径。例："Prefabs/Config.binary" 或 "myAudio.bank"</param>
        /// <returns></returns>
        public static bool BytesFileExists(string path)
        {
#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                string resPath = Constants.ResDirPath + path;
                string saPath = Constants.StreamingAssetsDirPath + path;
                bool isResExists = File.Exists(resPath);
                bool isSAExists = File.Exists(saPath);
                if (!isResExists && !isSAExists) return false;

                if (isResExists && isSAExists)
                    throw new Exception(string.Format(Constants.E5003, path));

                if ((isResExists && !FileHelper.IsPathCaseMatch(resPath))
                    || (isSAExists && !FileHelper.IsPathCaseMatch(saPath)))
                    throw new Exception(string.Format(Constants.E5002, path));

                return true;
            }
#endif
            return s_bytesMap.ContainsKey(path);
        }

        /// <summary>
        /// 获取 Bytes 文件的路径。
        /// 在 Unity Editor，将返回传入的 path。
        /// 在设备上（AB 模式），将返回完整真实路径（已确定文件在 原始包目录 还是 更新目录）。
        /// 如果文件不存在，将返回 null。
        /// </summary>
        /// <param name="path">Res 或 StreamingAssets 目录下的文件路径。例："Prefabs/Config.binary" 或 "myAudio.bank"</param>
        /// <returns></returns>
        public static string GetBytesFilePath(string path)
        {
#if UNITY_EDITOR
            if (Common.IsDebug)
                return BytesFileExists(path) ? path : null;
#endif
            string fileName;
            if (!s_bytesMap.TryGetValue(path, out fileName))
                return null;

            string fullPath = Constants.PackageDir + fileName;
            if (!FileHelper.Exists(fullPath))
                fullPath = Constants.UpdateDir + fileName;
            return fullPath;
        }

        /// <summary>
        /// 或取 Bytes 文件的字节内容
        /// </summary>
        /// <param name="path">Res 或 StreamingAssets 目录下的文件路径。例："Prefabs/Config.binary" 或 "myAudio.bank"</param>
        /// <returns></returns>
        public static byte[] GetBytesFileContent(string path)
        {
#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                if (!BytesFileExists(path)) return null;

                string resPath = Constants.ResDirPath + path;
                if (File.Exists(resPath)) return File.ReadAllBytes(resPath);

                return File.ReadAllBytes(Constants.StreamingAssetsDirPath + path);
            }
#endif
            if (!s_bytesMap.ContainsKey(path)) return null;

            return FileHelper.GetBytes(GetBytesFilePath(path));
        }

        #endregion



        #region 在 lua 层抛出事件

        [NoToLua]
        public const string EVENT_START = "ResEvent_LoadStart";
        [NoToLua]
        public const string EVENT_COMPLETE = "ResEvent_LoadComplete";
        [NoToLua]
        public const string EVENT_ALL_COMPLETE = "ResEvent_LoadAllComplete";

        /// 在 lua 层抛出 ResEvent 的方法。 - Events/ResEvent.lua
        private static LuaFunction s_dispatchEvent;

        /// <summary>
        /// 在 lua 层抛出事件
        /// </summary>
        /// <param name="type">Type.</param>
        /// <param name="path">Path.</param>
        /// <param name="data">Data.</param>
        [NoToLua]
        public static void DispatchEvent(string type, string path = null, UnityEngine.Object data = null)
        {
            // C# 层的回调
            if (type == EVENT_COMPLETE)
            {
                s_loadCompleteEvent.path = path;
                s_loadCompleteEvent.data = data;
                LoadCompleteHandler.Call(s_loadCompleteEvent);
            }

            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("ResEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(type);
            if (path != null)
                s_dispatchEvent.Push(path);
            if (data != null)
                s_dispatchEvent.Push(data);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion



        #region 卸载所有资源，清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void UnloadAll()
        {
            // 卸载资源 AssetBundle
            foreach (var item in s_infoMap)
            {
                AssetInfo info = item.Value;
                if (info.ab != null) info.ab.Unload(true);
            }

            // 卸载场景 AssetBundle
            foreach (var item in s_sceneMap)
            {
                AssetInfo info = item.Value;
                if (info.ab != null) info.ab.Unload(true);
            }

            // 卸载 Resources 资源
            Resources.UnloadUnusedAssets();

            s_dispatchEvent = null;
            s_delayedUnloadList.Clear();
            s_luaMap.Clear();
            s_bytesMap.Clear();
            s_sceneMap.Clear();
            s_infoMap.Clear();
            s_resMap.Clear();

            AssetLoader.Clear();
        }

        #endregion


        //
    }

}
