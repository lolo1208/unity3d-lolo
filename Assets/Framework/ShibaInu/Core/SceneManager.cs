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
        private const string MainCameraName = "Main Camera";

        /// 已加载 或 正在加载 的场景列表
        private static readonly List<string> s_scenes = new List<string>();
        /// 需要（异步）加载的场景队列
        private static readonly List<string> s_needLoadScenes = new List<string>();
        /// 无需卸载 AssetBundle 的场景列表
        private static readonly HashSet<string> s_dontUnloadSceneNames = new HashSet<string>();
        /// 总异步加载场景数（用于统计进度）
        private static int s_totalCount = 0;

        /// 异步加载场景的协程对象（editor mode 环境下为抛出异步加载场景事件的协程对象）
        private static Coroutine s_coScene;
        /// 异步加载场景对应的 AssetBundle 的请求对象
        private static AssetBundleCreateRequest s_crScene;
        /// 异步载入场景的操作对象
        private static AsyncOperation s_aoScene;

        /// Empty 场景下的 "Main Camera" 节点，用于挂载一个空（不渲染）Camera 和一个 AudioListener 组件
        private static GameObject s_emptyCam;



        /// <summary>
        /// 异步加载场景
        /// </summary>
        /// <param name="sceneName"></param>
        public static void LoadScene(string sceneName)
        {
            if (HasScene(sceneName))
                return;

            s_needLoadScenes.Add(sceneName);

            if (s_coScene == null)
                LoadNextScene();
        }


        /// <summary>
        /// 继续加载下个场景
        /// </summary>
        private static void LoadNextScene()
        {
            if (s_needLoadScenes.Count == 0)
            {
                s_totalCount = 0;
                return;
            }

            string sceneName = s_needLoadScenes[0];
            s_scenes.Add(sceneName);
            s_needLoadScenes.RemoveAt(0);

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

            if (s_scenes.Contains(sceneName))
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

        /// 异步加载场景完成
        private static void LoadSceneComplete(string sceneName)
        {
            if (s_scenes.Contains(sceneName))
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

                DispatchEvent(EVENT_COMPLETE, sceneName);
            }
            else
                USceneMgr.UnloadSceneAsync(sceneName); // 有可能场景已被（逻辑）卸载

            s_coScene = null;
            LoadNextScene();
        }



        /// <summary>
        /// 卸载指定名称的场景（异步）
        /// </summary>
        /// <param name="sceneName"></param>
        public static void UnloadScene(string sceneName)
        {
            s_needLoadScenes.Remove(sceneName);

            if (s_scenes.Contains(sceneName))
            {
                s_scenes.Remove(sceneName);
                DispatchEvent(EVENT_UNLOAD, sceneName);
                Common.looper.StartCoroutine(DoUnloadScene(sceneName));
            }
        }


        private static IEnumerator DoUnloadScene(string sceneName)
        {
            // 等待异步场景加载完成
            while (s_coScene != null)
                yield return new WaitForEndOfFrame();
            if (HasScene(sceneName)) yield break;// 场景又被加载了

            // 没有已加载的场景，显示 Empty 场景的相机
            if (s_scenes.Count == 0 && s_emptyCam != null && !s_emptyCam.activeSelf)
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
                if (HasScene(sceneName)) yield break;// 场景又被加载了

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
                    Debug.Log("[SceneManager] Unload Scene AssetBundle: " + sceneName);
                }

            }
        }


        /// <summary>
        /// 卸载所有场景（异步）
        /// </summary>
        public static void UnloadAllScenes()
        {
            string[] scenes = s_scenes.ToArray();
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
        /// 获取当前 异步加载资源 和 异步加载场景 的总进度，值：0~1
        /// </summary>
        /// <returns>The progress.</returns>
        public static float GetProgress()
        {
            float pRes = AssetLoader.GetProgress();

            // 没有在异步加载场景
            if (s_coScene == null)
                return pRes;

            // 正在加载的场景 AssetBundle 与 加载场景本身 的进度
            float pScene = (s_crScene != null)
                ? s_crScene.progress * 0.9f
                : Mathf.Min(s_aoScene.progress + 0.1f, 1f) * 0.1f + 0.9f;
            pScene = (pScene + pRes) / 2f;

            if (s_aoScene != null && !s_aoScene.isDone)
                pScene -= 0.05f;

            if (s_totalCount == 0)
                s_totalCount = s_needLoadScenes.Count + 1;

            return (s_totalCount - s_needLoadScenes.Count - 1 + pScene) / s_totalCount;
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
        /// 场景是否 已加载，正在加载，需要加载
        /// </summary>
        /// <param name="sceneName"></param>
        /// <returns></returns>
        private static bool HasScene(string sceneName)
        {
            return s_scenes.Contains(sceneName) || s_needLoadScenes.Contains(sceneName);
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
            s_scenes.Clear();
            s_needLoadScenes.Clear();
            s_dontUnloadSceneNames.Clear();
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

