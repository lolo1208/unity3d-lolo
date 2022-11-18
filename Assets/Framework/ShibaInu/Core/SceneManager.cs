using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.SceneManagement;
using USceneMgr = UnityEngine.SceneManagement.SceneManager;


namespace ShibaInu
{

    public static class SceneManager
    {
        /// 场景中 Main Camera 节点的名称
        private const string MainCameraName = "Main Camera";

        /// 已加载完成的场景列表
        private static readonly List<string> s_loadedList = new List<string>();
        /// 需要加载的场景列表
        private static readonly List<string> s_needLoadList = new List<string>();
        /// 需要预加载的场景列表
        private static readonly List<string> s_preloadList = new List<string>();
        /// 正在加载的场景名称
        private static string s_curLoadSceneName;
        /// 正在加载的场景是否为 预加载形式
        private static bool s_curIsPreload = true;
        /// 总加载场景数，用于统计进度，不包含预加载的场景数
        private static int s_totalCount = 0;

        /// 无需卸载 AssetBundle 的场景列表
        private static readonly HashSet<string> s_dontUnloadSceneNames = new HashSet<string>();

        /// 异步加载场景的协程对象（editor mode 环境下为抛出异步加载场景事件的协程对象）
        private static Coroutine s_coScene;
        /// 异步加载场景对应的 AssetBundle 的请求对象
        private static AssetBundleCreateRequest s_crScene;
        /// 异步载入场景的操作对象
        private static AsyncOperation s_aoScene;

        /// Empty 场景下的 "Main Camera" 节点，用于挂载一个空（不渲染）Camera 和一个 AudioListener 组件
        private static GameObject s_emptyCam;



        /// <summary>
        /// 加载场景（异步）
        /// </summary>
        /// <param name="sceneName">场景名称</param>
        /// <param name="preload">是否为预加载</param>
        public static void LoadScene(string sceneName, bool preload = false)
        {
            // 当前正在加载该场景，并且从预加载切换到正常加载
            if (s_curLoadSceneName == sceneName && !preload && s_curIsPreload)
            {
                s_curIsPreload = false;
                s_totalCount++;
            }

            if (HasScene(sceneName)) return;

            if (preload)
            {
                if (!s_preloadList.Contains(sceneName))
                {
                    s_preloadList.Add(sceneName);
                    if (s_needLoadList.Contains(sceneName))
                    {
                        s_needLoadList.Remove(sceneName);
                        s_totalCount--;// 从加载列表移动到预加载列表
                    }
                }
            }
            else
            {
                if (!s_needLoadList.Contains(sceneName))
                {
                    s_needLoadList.Add(sceneName);
                    s_preloadList.Remove(sceneName);
                    s_totalCount++;
                }
            }

            if (s_coScene == null)
                LoadNextScene();
        }


        /// <summary>
        /// 继续加载下个场景
        /// </summary>
        private static void LoadNextScene()
        {
            if (s_needLoadList.Count == 0 && s_preloadList.Count == 0)
                return;

            string sceneName;
            if (s_needLoadList.Count > 0)
            {
                sceneName = s_needLoadList[0];
                s_needLoadList.RemoveAt(0);
                s_curIsPreload = false;
            }
            else
            {
                sceneName = s_preloadList[0];
                s_preloadList.RemoveAt(0);
                s_curIsPreload = true;
            }
            s_curLoadSceneName = sceneName;

            if (!Common.IsDebug)
                s_coScene = Common.looper.StartCoroutine(DoLoadScene(sceneName));
#if UNITY_EDITOR
            else
                s_coScene = Common.looper.StartCoroutine(LoadSceneInEditor(sceneName));
#endif
        }


        /// ab 模式异步加载场景
        private static IEnumerator DoLoadScene(string sceneName)
        {
            DispatchEvent(EVENT_START, sceneName);
            AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
            if (info.ab == null)
            {
                // 先异步加载场景对应的 AssetBundle
                s_crScene = AssetBundle.LoadFromFileAsync(AssetLoader.GetFilePath(info));
                yield return s_crScene;
                info.ab = s_crScene.assetBundle;
                s_crScene = null;
            }

            if (s_curLoadSceneName == sceneName)
            {
                // 再异步加载场景
                s_aoScene = USceneMgr.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
                yield return s_aoScene;
                s_aoScene = null;
            }

            LoadSceneComplete(sceneName);
        }


#if UNITY_EDITOR

        /// 在 editor play mode 状态下异步加载场景
        private static IEnumerator LoadSceneInEditor(string sceneName)
        {
            DispatchEvent(EVENT_START, sceneName);

            s_aoScene = USceneMgr.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
            yield return s_aoScene;
            s_aoScene = null;
            LoadSceneComplete(sceneName);
        }

#endif

        /// 加载场景完成
        private static void LoadSceneComplete(string sceneName)
        {
            if (s_curLoadSceneName == sceneName)
            {
                // 隐藏 Empty 场景的相机
                if (s_emptyCam == null)
                    s_emptyCam = LuaHelper.FindRootObjectInScene(Constants.EmptySceneName, MainCameraName);
                if (s_emptyCam != null && s_emptyCam.activeSelf)
                    s_emptyCam.SetActive(false);

                // 创建 root 节点
                Scene scene = USceneMgr.GetSceneByName(sceneName);
                GameObject rootGO = new GameObject(Constants.SceneRootName);
                USceneMgr.MoveGameObjectToScene(rootGO, scene);

                // 将场景内的 GameObject 全移动到其中
                Transform rootTra = rootGO.transform;
                GameObject[] list = scene.GetRootGameObjects();
                foreach (GameObject go in list)
                    go.transform.SetParent(rootTra);

                s_loadedList.Add(sceneName);
                DispatchEvent(EVENT_COMPLETE, sceneName);
            }
            else
                USceneMgr.UnloadSceneAsync(sceneName); // 有可能场景已被（逻辑）卸载

            if (s_needLoadList.Count == 0)
                s_totalCount = 0;
            s_curIsPreload = true;// GetProgress() 会拿该变量做判断
            s_curLoadSceneName = null;
            s_coScene = null;
            LoadNextScene();
        }



        /// <summary>
        /// 卸载指定名称的场景（异步）
        /// </summary>
        /// <param name="sceneName"></param>
        public static void UnloadScene(string sceneName)
        {
            s_needLoadList.Remove(sceneName);
            s_preloadList.Remove(sceneName);
            if (s_curLoadSceneName == sceneName) s_curLoadSceneName = null;

            if (s_loadedList.Contains(sceneName))
            {
                s_loadedList.Remove(sceneName);
                DispatchEvent(EVENT_UNLOAD, sceneName);
                Common.looper.StartCoroutine(DoUnloadScene(sceneName));
            }
        }


        private static IEnumerator DoUnloadScene(string sceneName)
        {
            // 等待异步场景加载完成
            while (s_coScene != null) yield return new WaitForEndOfFrame();

            // 场景又被加载了
            if (HasScene(sceneName)) yield break;

            // 没有已加载的场景，显示 Empty 场景的相机
            if (s_loadedList.Count == 0 && s_emptyCam != null && !s_emptyCam.activeSelf)
                s_emptyCam.SetActive(true);

            // 销毁场景中的 MainCamera 节点
            GameObject goRoot = LuaHelper.FindRootObjectInScene(sceneName, Constants.SceneRootName);
            if (goRoot != null)
            {
                Transform traCam = goRoot.transform.Find(MainCameraName);
                if (traCam != null)
                    Object.Destroy(traCam.gameObject);
            }

            yield return USceneMgr.UnloadSceneAsync(sceneName);// 异步卸载场景

            if (!Common.IsDebug)
            {
                yield return new WaitForSeconds(5f);// 再延迟一会

                // 场景又被加载了
                if (HasScene(sceneName)) yield break;

                // 卸载以场景名为 groupName 所加载的资源
                ResManager.Unload(sceneName);

                // sceneName 对应的 AssetBundle 无需卸载
                if (s_dontUnloadSceneNames.Contains(sceneName)) yield break;

                // 卸载场景对应的 AssetBundle
                AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
                if (info.ab != null)
                {
                    info.ab.Unload(true);
                    info.ab = null;
                    Debug.LogFormat("[ShibaInu.SceneManager] Unload Scene AssetBundle: {0}", sceneName);
                }

            }
        }


        /// <summary>
        /// 卸载所有已加载的场景（异步）
        /// </summary>
        public static void UnloadAllScenes()
        {
            string[] scenes = s_loadedList.ToArray();
            foreach (string sceneName in scenes)
                UnloadScene(sceneName);
        }


        /// <summary>
        /// 设置 sceneName 对应的场景成激活场景
        /// </summary>
        /// <param name="sceneName"></param>
        /// <returns></returns>
        public static bool SetActiveScene(string sceneName)
        {
            return USceneMgr.SetActiveScene(USceneMgr.GetSceneByName(sceneName));
        }


        /// <summary>
        /// 获取当前 加载资源 和 加载场景 的总进度，值：0~1
        /// </summary>
        /// <returns>The progress.</returns>
        public static float GetProgress()
        {
            // 没有需要加载，或正在加载的场景
            if (s_curIsPreload && s_needLoadList.Count == 0) return 1;

            // 正在加载的 "场景 AssetBundle 资源" 与加载 "场景本身" 的进度
            float pRes = AssetLoader.GetProgress();
            float pScene = (s_crScene != null)
                ? s_crScene.progress * 0.9f
                : Mathf.Min(s_aoScene.progress + 0.1f, 1f) * 0.1f + 0.9f;
            pScene = (pScene + pRes) / 2f;

            if (s_aoScene != null && !s_aoScene.isDone)
                pScene -= 0.05f;

            // (2 - (1~0) - 1 + 0.5) / 2
            return (s_totalCount - s_needLoadList.Count - 1 + pScene) / s_totalCount;
        }


        /// <summary>
        /// 设置 sceneName 对应的 AssetBundle 是否需要被卸载
        /// </summary>
        /// <param name="sceneName"></param>
        /// <param name="dontUnload"></param>
        public static void SetDontUnloadAssetBundle(string sceneName, bool dontUnload)
        {
            if (dontUnload)
                s_dontUnloadSceneNames.Add(sceneName);
            else
                s_dontUnloadSceneNames.Remove(sceneName);
        }



        /// <summary>
        /// 场景是否 需要加载 / 正在加载 / 已加载
        /// </summary>
        /// <param name="sceneName"></param>
        /// <returns></returns>
        private static bool HasScene(string sceneName)
        {
            return s_needLoadList.Contains(sceneName) || s_preloadList.Contains(sceneName)
                || s_curLoadSceneName == sceneName
                || s_loadedList.Contains(sceneName);
        }



        #region 在 lua 层抛出事件

        private const string EVENT_START = "SceneEvent_LoadStart";
        private const string EVENT_COMPLETE = "SceneEvent_LoadComplete";
        private const string EVENT_UNLOAD = "SceneEvent_Unload";

        /// 在 lua 层抛出 SceneEvent 的方法。 - Events/SceneEvent.lua
        private static LuaFunction s_dispatchEvent;


        /// <summary>
        /// 在 lua 层抛出事件
        /// </summary>
        /// <param name="type">Type.</param>
        /// <param name="sceneName">Scene Name.</param>
        private static void DispatchEvent(string type, string sceneName)
        {
            // 不能在 Initialize() 时获取该函数，因为相互依赖
            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("SceneEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(sceneName);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_needLoadList.Clear();
            s_preloadList.Clear();
            s_loadedList.Clear();
            s_dontUnloadSceneNames.Clear();
            s_curIsPreload = true;
            s_curLoadSceneName = null;
            s_dispatchEvent = null;
            s_emptyCam = null;

            if (s_coScene != null)
            {
                Common.looper.StopCoroutine(s_coScene);
                s_coScene = null;
            }
        }

        #endregion


        //
    }
}

