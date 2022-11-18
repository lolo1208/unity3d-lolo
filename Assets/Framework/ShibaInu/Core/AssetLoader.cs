using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{

    public static class AssetLoader
    {
        #region 常量/ 变量

        /// groupName 引用的 AssetInfo 列表
        private static readonly Dictionary<string, HashSet<AssetInfo>> s_groupMap = new Dictionary<string, HashSet<AssetInfo>>();
        /// 需要被卸载的 groupName 列表
        private static readonly HashSet<string> s_unloadList = new HashSet<string>();

        /// 卸载资源的协程对象
        private static Coroutine s_coUnload;

        /// 需加载 AssetBundle 的 AssetInfo 列表
        private static readonly List<AssetInfo> s_loadInfoList = new List<AssetInfo>();
        /// 需加载的资源路径列表
        private static readonly Queue<string> s_loadAssetList = new Queue<string>();
        /// s_loadAssetList 对应的类型列表
        private static readonly Queue<Type> s_loadAssetTypeList = new Queue<Type>();

        /// 当前正在加载 AssetBundle 的 AssetInfo
        private static AssetInfo s_info;
        /// 当前正在加载的资源
        private static AssetBundleRequest s_abr;
        /// 需要加载的资源总数
        public static int assetCount;

        #endregion



        #region 资源加载

        /// <summary>
        /// 同步加载指定的 AssetBundle
        /// </summary>
        /// <param name="info">Info.</param>
        /// <param name="groupName">Group name.</param>
        /// <param name="infos">Infos.</param>
        public static void Load(AssetInfo info, string groupName = null, HashSet<AssetInfo> infos = null)
        {
            // 建立 infos，防止循环依赖导致无限递归
            if (infos == null) infos = new HashSet<AssetInfo>();
            else if (infos.Contains(info)) return;
            infos.Add(info);

            // 添加引用关系
            if (groupName != null)
            {
                AddReference(info, groupName);
                s_unloadList.Remove(groupName);
            }

            // AssetBundle 已加载
            if (info.ab != null) return;

            // 先加载依赖的 AssetBundle
            foreach (string pedFileName in info.pedList)
            {
                AssetInfo pedInfo = ResManager.GetAssetInfoWithABName(pedFileName);
                if (pedInfo.ab == null) Load(pedInfo, groupName, infos);
            }

            GetFilePath(info);
            info.ab = AssetBundle.LoadFromFile(info.path);
        }



        /// <summary>
        /// 异步加载指定的 AssetBundle
        /// </summary>
        /// <param name="info">Info.</param>
        /// <param name="groupName">Group name.</param>
        /// <param name="startCoroutine">If set to <c>true</c> start coroutine.</param>
        public static void LoadAsync(AssetInfo info, string groupName = null, bool startCoroutine = true)
        {
            // 添加引用关系
            if (groupName != null)
            {
                AddReference(info, groupName);
                s_unloadList.Remove(groupName);
            }

            // info 已在加载队列
            if (s_loadInfoList.Contains(info))
                return;

            // AssetBundle 文件已加载，可以异步加载资源了
            if (info.ab != null)
            {
                LoadAssetAsync(info);
                return;
            }

            // 先加入队列，用于判重
            s_loadInfoList.Add(info);
            // 加载依赖的 AssetBundle
            foreach (string pedFileName in info.pedList)
            {
                AssetInfo pedInfo = ResManager.GetAssetInfoWithABName(pedFileName);
                // 还没加载，并且不在加载队列中
                if (pedInfo.ab == null && !s_loadInfoList.Contains(pedInfo))
                    LoadAsync(pedInfo, groupName, false);
            }
            // 将 info 移至末尾，先加载依赖
            s_loadInfoList.Remove(info);
            s_loadInfoList.Add(info);

            // 启动加载 AB 协程
            if (s_info == null && startCoroutine)
                Common.looper.StartCoroutine(LoadNextAsync());
        }


        /// <summary>
        /// 协程加载下一个 AssetBundle
        /// </summary>
        /// <returns>The next async.</returns>
        private static IEnumerator LoadNextAsync()
        {
            s_info = s_loadInfoList[0];
            s_loadInfoList.RemoveAt(0);

            if (s_info.ab == null)
            {
                GetFilePath(s_info);
                AssetBundleCreateRequest abcr = AssetBundle.LoadFromFileAsync(s_info.path);
                yield return abcr;

                // 可能在异步加载过程中，该 AB 已经被同步加载好了，会报错（无需理会）。报错内容：
                // The AssetBundle 'xxx' can't be loaded because another AssetBundle with the same files is already loaded.
                if (s_info.ab == null)
                    s_info.ab = abcr.assetBundle;
            }

            LoadAssetAsync(s_info);
            s_info = null;

            if (s_loadInfoList.Count > 0)
                Common.looper.StartCoroutine(LoadNextAsync());
        }


        /// <summary>
        /// 将 AssetInfo 中需异步加载的资源路径添加到 _loadAssetList，并启动异步加载
        /// </summary>
        /// <param name="info">Info.</param>
        private static void LoadAssetAsync(AssetInfo info)
        {
            if (info.loadAssetsAsync.Count == 0)
                return;

            // 资源路径
            foreach (string path in info.loadAssetsAsync)
                s_loadAssetList.Enqueue(path);
            info.loadAssetsAsync.Clear();
            // 对应的类型
            foreach (Type type in info.loadAssetsTypeAsync)
                s_loadAssetTypeList.Enqueue(type);
            info.loadAssetsTypeAsync.Clear();

            if (s_abr == null)
                Common.looper.StartCoroutine(LoadNextAssetAsync());
        }


        /// <summary>
        /// 协程加载下个资源
        /// </summary>
        /// <returns>The nex asset async.</returns>
        private static IEnumerator LoadNextAssetAsync()
        {
            string path = s_loadAssetList.Dequeue();
            Type type = s_loadAssetTypeList.Dequeue();
            ResManager.DispatchEvent(ResManager.EVENT_START, path);

            AssetInfo info = ResManager.GetAssetInfoWithAssetPath(path);
            s_abr = info.ab.LoadAssetAsync(Constants.ResDirPath + path, type);
            yield return s_abr;
            ResManager.DispatchEvent(ResManager.EVENT_COMPLETE, path, s_abr.asset);
            s_abr = null;

            if (s_loadAssetList.Count > 0)
                Common.looper.StartCoroutine(LoadNextAssetAsync());
            else
            {
                // 当前没有 AssetBundle 在加载了
                if (s_info == null && s_loadInfoList.Count == 0)
                {
                    assetCount = 0;
                    ResManager.DispatchEvent(ResManager.EVENT_ALL_COMPLETE);
                }
            }
        }


        /// <summary>
        /// 获取当前异步加载总进度 0~1
        /// </summary>
        /// <returns>The progress.</returns>
        public static float GetProgress()
        {
            // 没有在加载的资源
            if (assetCount == 0)
                return 1;

            // 正在加载的队列
            float count = s_loadAssetList.Count;

            // 还没加载的 AssetInfo
            foreach (AssetInfo info in s_loadInfoList)
                count += info.loadAssetsAsync.Count;

            // 正在加载的 AssetInfo
            if (s_info != null)
                count += s_info.loadAssetsAsync.Count;

            // 正在加载的资源
            if (s_abr != null)
                count += 1 - s_abr.progress;

            return (assetCount - count) / assetCount;
        }



        /// <summary>
        /// 获取文件的完整真实路径（已确定文件在 原始包目录 还是 更新目录）
        /// </summary>
        /// <param name="info">Info.</param>
        public static string GetFilePath(AssetInfo info)
        {
            if (info.path == null)
                info.path = GetFilePath(info.name);
            return info.path;
        }


        public static string GetFilePath(string fileName)
        {
            string path = Constants.PackageDir + fileName;
            if (!FileHelper.Exists(path))
                path = Constants.UpdateDir + fileName;
            return path;
        }


        /// <summary>
        /// 需加载的资源路径列表是否已存在 path
        /// </summary>
        /// <returns><c>true</c>, if asset list contains was loaded, <c>false</c> otherwise.</returns>
        /// <param name="path">Path.</param>
        public static bool LoadAssetListContains(string path)
        {
            return s_loadAssetList.Contains(path);
        }

        #endregion



        #region 引用与卸载

        /// <summary>
        /// 添加引用关系
        /// </summary>
        /// <param name="info">Info.</param>
        /// <param name="groupName">Group name.</param>
        /// <param name="infos">Infos.</param>
        private static void AddReference(AssetInfo info, string groupName, HashSet<AssetInfo> infos = null)
        {
            // 建立 infos，防止循环依赖导致无限递归
            if (infos == null) infos = new HashSet<AssetInfo>();
            else if (infos.Contains(info)) return;
            infos.Add(info);

            // 标记 info 被 groupName 引用
            info.groupList.Add(groupName);

            // 标记 groupName 引用了 info
            if (!s_groupMap.TryGetValue(groupName, out HashSet<AssetInfo> infoList))
            {
                s_groupMap.Add(groupName, new HashSet<AssetInfo>());
                infoList = s_groupMap[groupName];
            }
            infoList.Add(info);

            // info 依赖的其他 info 也要标记被该 groupName 引用
            foreach (string pedFileName in info.pedList)
                AddReference(ResManager.GetAssetInfoWithABName(pedFileName), groupName, infos);
        }


        /// <summary>
        /// 移除 groupName 对应的引用关系，并卸载没有任何引用的资源
        /// </summary>
        /// <param name="groupName">Group name.</param>
        public static void RemoveReference(string groupName)
        {
            s_unloadList.Add(groupName);
            if (s_coUnload == null)
                s_coUnload = Common.looper.StartCoroutine(DoUnload());
        }


        private static IEnumerator DoUnload()
        {
            // 等待异步资源加载完成
            while (GetProgress() < 1)
            {
                yield return new WaitForEndOfFrame();
            }
            s_coUnload = null;

            foreach (string groupName in s_unloadList)
            {
                if (!s_groupMap.TryGetValue(groupName, out HashSet<AssetInfo> infoList))
                    continue;

                s_groupMap.Remove(groupName);
                foreach (AssetInfo info in infoList)
                {
                    // 移除引用
                    info.groupList.Remove(groupName);

                    // 可以卸载了
                    if (info.groupList.Count == 0)
                    {
                        info.ab.Unload(true);
                        info.ab = null;
                        // Debug.LogFormat("[ShibaInu.AssetLoader] Unload AssetBundle: {0}", info.name);
                    }
                }
            }
            s_unloadList.Clear();
        }

        #endregion



        #region 停止加载，清空加载队列（在动更结束后重启 app 时）

        public static void Clear()
        {
            s_groupMap.Clear();
            s_unloadList.Clear();
            s_loadInfoList.Clear();
            s_loadAssetList.Clear();
            s_loadAssetTypeList.Clear();
            assetCount = 0;
            s_info = null;
            s_abr = null;
        }

        #endregion


        //
    }




    /// <summary>
    /// 资源信息对象
    /// </summary>
    public class AssetInfo
    {
        /// 已加载好的 AssetBundle，值为 null 时，表示还未加载
        public AssetBundle ab;

        /// （异步）加载 AssetBundle 完成后，需要异步加载的资源路径列表
        public List<string> loadAssetsAsync = new List<string>();
        /// loadAssetsAsync 对应的类型列表
        public List<Type> loadAssetsTypeAsync = new List<Type>();


        /// 文件名称
        public string name;
        /// 文件完整真实路径（已确定文件在原始包目录还是更新目录）
        public string path;

        /// 依赖的 AssetBundle 文件名列表
        public List<string> pedList = new List<string>();

        /// 引用了该 AssetBundle 的资源组列表，值为 groupName
        public HashSet<string> groupList = new HashSet<string>();


        public AssetInfo(string name)
        {
            this.name = name;
        }


        /// <summary>
        /// 添加一个需要异步加载的资源
        /// </summary>
        /// <param name="path">Path.</param>
        public void AddAsyncAsset(string path, Type type)
        {
            if (!loadAssetsAsync.Contains(path) && !AssetLoader.LoadAssetListContains(path))
            {
                AssetLoader.assetCount++;
                loadAssetsAsync.Add(path);
                loadAssetsTypeAsync.Add(type);
            }
        }


        //
    }
}

