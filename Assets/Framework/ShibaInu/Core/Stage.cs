using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using LuaInterface;


namespace ShibaInu
{

    public static class Stage
    {
        /// UI Canvas
        public static Canvas uiCanvas;
        public static RectTransform uiCanvasTra;
        // Layers
        public static RectTransform sceneLayer;
        public static RectTransform uiLayer;
        public static RectTransform windowLayer;
        public static RectTransform uiTopLayer;
        public static RectTransform alertLayer;
        public static RectTransform guideLayer;
        public static RectTransform topLayer;

        /// 不需要被销毁的对象列表
        private static readonly HashSet<Transform> s_dontDestroyList = new HashSet<Transform>();

        /// 当前所在场景名称
        private static string s_sceneName = Constants.LauncherSceneName;
        /// 当前已加载的 SubScene 名称列表
        private static readonly HashSet<string> s_subSceneNames = new HashSet<string>();
        /// 无需卸载 AssetBundle 的场景名称列表（包括 SubScene）
        public static readonly HashSet<string> s_dontUnloadSceneNames = new HashSet<string>();

        /// 加载场景对应 AssetBundle 的请求对象
        private static AssetBundleCreateRequest s_abcr = null;
        /// 载入场景的异步操作对象
        private static AsyncOperation s_ao = null;
        /// 异步加载场景的协程对象
        private static Coroutine s_coAlc = null;
        /// 异步加载 SubScene 的协程对象
        private static Coroutine s_coSub = null;

#if UNITY_EDITOR
        /// 抛出 EVENT_COMPLETE 事件的协程对象
        private static Coroutine s_coDce = null;
#endif



        #region UI初始化与清空销毁

        /// <summary>
        /// 初始化
        /// </summary>
        [NoToLuaAttribute]
        public static void Initialize()
        {
            s_dontDestroyList.Clear();
            s_dontUnloadSceneNames.Clear();
            s_dontUnloadSceneNames.Add(Constants.LauncherSceneName);
            s_dontUnloadSceneNames.Add(Constants.EmptySceneName);

            GameObject go = (GameObject)UnityEngine.Object.Instantiate(ResManager.LoadAsset("Prefabs/Core/UICanvas.prefab", "Core"), Common.go.transform);
            go.name = "UICanvas";
            uiCanvasTra = (RectTransform)go.transform;

            uiCanvas = go.GetComponent<Canvas>();
            sceneLayer = (RectTransform)uiCanvasTra.Find("scene");
            uiLayer = (RectTransform)uiCanvasTra.Find("ui");
            windowLayer = (RectTransform)uiCanvasTra.Find("window");
            uiTopLayer = (RectTransform)uiCanvasTra.Find("uiTop");
            alertLayer = (RectTransform)uiCanvasTra.Find("alert");
            guideLayer = (RectTransform)uiCanvasTra.Find("guide");
            topLayer = (RectTransform)uiCanvasTra.Find("top");
        }


        /// <summary>
        /// 清空UI（切换场景时）
        /// </summary>
        public static void CleanUI()
        {
            for (int i = 0; i < uiCanvasTra.childCount; i++)
            {
                Transform layer = uiCanvasTra.GetChild(i);
                for (int n = 0; n < layer.childCount; n++)
                    DestroyChildUI(layer.GetChild(n));
            }
        }

        /// <summary>
        /// 销毁子UI
        /// </summary>
        /// <returns><c>true</c>, if child U was destroyed, <c>false</c> otherwise.</returns>
        /// <param name="tra">Tra.</param>
        private static bool DestroyChildUI(Transform tra)
        {
            if (s_dontDestroyList.Contains(tra))
                return false;// 本身不可销毁

            bool canDestroy = true;
            for (int i = tra.childCount - 1; i >= 0; i--)
            {
                // 子节点不可销毁
                Transform child = tra.GetChild(i);
                if (s_dontDestroyList.Contains(child))
                {
                    canDestroy = false;
                }
                else
                {
                    if (!DestroyChildUI(child))
                        canDestroy = false;
                }
            }
            if (canDestroy)
            {
                UnityEngine.Object.Destroy(tra.gameObject);
            }
            return canDestroy;
        }


        /// <summary>
        /// 添加一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
        /// </summary>
        /// <param name="go">Go.</param>
        public static void AddDontDestroy(GameObject go)
        {
            s_dontDestroyList.Add(go.transform);
        }

        /// <summary>
        /// 移除一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
        /// </summary>
        /// <param name="go">Go.</param>
        public static void RemoveDontDestroy(GameObject go)
        {
            s_dontDestroyList.Remove(go.transform);
        }

        #endregion



        #region 加载/卸载 场景

        /// <summary>
        /// 同步加载场景
        /// </summary>
        /// <param name="sceneName">Scene path.</param>
        public static void LoadScene(string sceneName)
        {
            UnloadSubSceneAssetBundle();

#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                // [ Editor Play Mode ] 请将要加载的场景（在 Assets/Res/Scene/ 目录下）加入到 [ Build Settings -> Scenes In Build ] 中
                SceneManager.LoadScene(sceneName);
                return;
            }
#endif

            // 这两个是随包走的场景
            if (sceneName != Constants.LauncherSceneName && sceneName != Constants.EmptySceneName)
            {
                AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
                if (info.ab == null)
                {
                    AssetLoader.GetFilePath(info);
                    info.ab = AssetBundle.LoadFromFile(info.path);// 先加载场景对应的 AssetBundle
                }
            }

            Common.looper.StartCoroutine(UnloadSceneAssetBundle(s_sceneName));
            s_sceneName = sceneName;
            SceneManager.LoadScene(sceneName);// 再载入场景
        }


        /// <summary>
        /// 异步加载场景
        /// </summary>
        /// <param name="sceneName">Scene name.</param>
        public static void LoadSceneAsync(string sceneName)
        {
            UnloadSubSceneAssetBundle();

#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                s_sceneName = sceneName;
                DispatchEvent(EVENT_START, sceneName);
                if (s_coDce != null)
                    Common.looper.StopCoroutine(s_coDce);
                s_coDce = Common.looper.StartCoroutine(DispatchCompleteEvent(sceneName));
                return;
            }
#endif

            Common.looper.StartCoroutine(UnloadSceneAssetBundle(s_sceneName));
            s_sceneName = sceneName;

            if (s_coAlc != null)
                Common.looper.StopCoroutine(s_coAlc);

            s_abcr = null;
            s_ao = null;
            s_coAlc = Common.looper.StartCoroutine(DoLoadSceneAsync());
        }


        private static IEnumerator DoLoadSceneAsync()
        {
            DispatchEvent(EVENT_START, s_sceneName);
            AssetInfo info = ResManager.GetAssetInfoWithSceneName(s_sceneName);
            if (info.ab == null)
            {
                // 先异步加载场景对应的 AssetBundle
                AssetLoader.GetFilePath(info);
                s_abcr = AssetBundle.LoadFromFileAsync(info.path);
                yield return s_abcr;
                info.ab = s_abcr.assetBundle;
                s_abcr = null;
            }

            // 再异步加载场景
            s_ao = SceneManager.LoadSceneAsync(s_sceneName);
            yield return s_ao;
            s_ao = null;
            s_coAlc = null;
            DispatchEvent(EVENT_COMPLETE, s_sceneName);
        }


#if UNITY_EDITOR

        /// <summary>
        /// 在 editor play mode 状态下，模拟异步加载，延迟一会抛出场景异步加载完成事件
        /// </summary>
        /// <returns>The all complete event.</returns>
        private static IEnumerator DispatchCompleteEvent(string sceneName)
        {
            yield return new WaitForSeconds(0.2f);
            s_coDce = null;
            SceneManager.LoadScene(sceneName);
            DispatchEvent(EVENT_COMPLETE, sceneName);
        }

#endif


        /// <summary>
        /// 延迟卸载包含场景的 AssetBundle
        /// </summary>
        /// <returns>The scene.</returns>
        /// <param name="sceneName">Scene name.</param>
        private static IEnumerator UnloadSceneAssetBundle(string sceneName)
        {
            yield return new WaitForSeconds(5f);

            // 等待异步场景加载完成
            while (s_coAlc != null)
            {
                yield return new WaitForEndOfFrame();
            }

            if (sceneName == s_sceneName)
                yield break;

            if (s_dontUnloadSceneNames.Contains(sceneName))
                yield break;

            AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
            if (info.ab != null)
            {
                info.ab.Unload(true);
                info.ab = null;
                Debug.Log("[Unload] Scene: " + sceneName);
            }
            ResManager.Unload(sceneName);
        }

        #endregion



        #region 加载/卸载 Sub 场景

        /// <summary>
        /// 同步加载 Sub 场景
        /// </summary>
        /// <param name="sceneName">Scene name.</param>
        public static void LoadSubScene(string sceneName)
        {
            s_subSceneNames.Add(sceneName);

#if UNITY_EDITOR
            if (Common.IsDebug)
            {
                SceneManager.LoadScene(sceneName, LoadSceneMode.Additive);
                return;
            }
#endif

            // 先加载场景对应的 AssetBundle
            AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
            if (info.ab == null)
            {
                AssetLoader.GetFilePath(info);
                info.ab = AssetBundle.LoadFromFile(info.path);
            }
            // 再载入场景
            SceneManager.LoadScene(sceneName);
        }


        /// <summary>
        /// 异步加载 Sub 场景
        /// </summary>
        /// <param name="sceneName">Scene name.</param>
        public static void LoadSubSceneAsync(string sceneName)
        {
            s_subSceneNames.Add(sceneName);

            DispatchEvent(EVENT_SUB_START, sceneName);
            if (s_coSub != null)
                Common.looper.StopCoroutine(s_coSub);

            s_abcr = null;
            s_ao = null;
            s_coSub = Common.looper.StartCoroutine(DoLoadSubSceneAsync(sceneName));
        }


        private static IEnumerator DoLoadSubSceneAsync(string sceneName)
        {
            if (!Common.IsDebug)
            {
                // 先异步加载场景对应的 AssetBundle
                AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
                if (info.ab == null)
                {
                    AssetLoader.GetFilePath(info);
                    s_abcr = AssetBundle.LoadFromFileAsync(info.path);
                    yield return s_abcr;
                    info.ab = s_abcr.assetBundle;
                    s_abcr = null;
                }
            }

            // 再异步加载 SubScene
            s_ao = SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
            s_ao.allowSceneActivation = false;
            while (!s_ao.isDone)
            {
                if (s_ao.progress >= 0.9f)
                    s_ao.allowSceneActivation = true;
                yield return null;
            }
            s_ao = null;
            s_coSub = null;
            DispatchEvent(EVENT_SUB_COMPLETE, sceneName);
        }


        /// <summary>
        /// 卸载包含 Sub 场景的 AssetBundle，并取消正在异步加载的 Sub 场景。
        /// </summary>
        private static void UnloadSubSceneAssetBundle()
        {
            if (s_coSub != null)
            {
                Common.looper.StopCoroutine(s_coSub);
                s_coSub = null;
            }

            if (!Common.IsDebug)
            {
                foreach (string sceneName in s_subSceneNames)
                {
                    if (s_dontUnloadSceneNames.Contains(sceneName))
                        continue;

                    AssetInfo info = ResManager.GetAssetInfoWithSceneName(sceneName);
                    if (info.ab != null)
                    {
                        info.ab.Unload(true);
                        info.ab = null;
                        Debug.Log("[Unload] SubScene: " + sceneName);
                    }
                }
            }
            s_subSceneNames.Clear();
        }

        #endregion



        #region 其他

        /// <summary>
        /// 获取当前异步加载进度 0~1
        /// </summary>
        /// <returns>The progress.</returns>
        public static float GetProgress()
        {
            // 没有在加载场景
            if (s_abcr == null && s_ao == null)
                return 1;

            // 正在加载场景对应的 AssetBundle
            if (s_abcr != null)
                return s_abcr.progress * 0.9f;

            // 正在异步加载场景本身
            return Mathf.Min(s_ao.progress + 0.1f, 1f) * 0.1f + 0.9f;
        }


        /// <summary>
        /// 获取当前场景的名称
        /// </summary>
        /// <value>The name of the current scene.</value>
        public static string CurrentSceneName
        {
            get { return s_sceneName; }
        }


        /// <summary>
        /// 设置指定的场景名是否需要卸载对应的 AssetBundle。包括 SubScene
        /// </summary>
        /// <param name="sceneName">Scene name.</param>
        /// <param name="dontUnload">true:无需卸载，false:可以卸载</param>
        public static void SetDontUnloadScene(string sceneName, bool dontUnload)
        {
            if (dontUnload)
                s_dontUnloadSceneNames.Add(sceneName);
            else
                s_dontUnloadSceneNames.Remove(sceneName);
        }

        #endregion



        #region 在 lua 层抛出事件

        private const string EVENT_START = "LoadSceneEvent_Start";
        private const string EVENT_COMPLETE = "LoadSceneEvent_Complete";
        private const string EVENT_SUB_START = "LoadSceneEvent_SubStart";
        private const string EVENT_SUB_COMPLETE = "LoadSceneEvent_SubComplete";

        /// 在 lua 层抛出 LoadSceneEvent 的方法。 - Events/LoadSceneEvent.lua
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
                s_dispatchEvent = Common.luaMgr.state.GetFunction("LoadSceneEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(sceneName);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion



        #region 清空所有引用（在动更结束后重启 app 时）

        public static void ClearReference()
        {
            s_dispatchEvent = null;
        }

        #endregion


        //
    }
}