using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using LuaInterface;


namespace ShibaInu
{
	
	public class Stage
	{
		// lua 层的事件类型
		private const string EVENT_START = "LoadSceneEvent_Start";
		private const string EVENT_COMPLETE = "LoadSceneEvent_Complete";

		/// 在 lua 层抛出 LoadSceneEvent 的方法。 - Events/LoadSceneEvent.lua
		private static LuaFunction s_dispatchEvent;

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
		private static HashSet<Transform> s_dontDestroyList = new HashSet<Transform> ();

		/// 当前所在场景名称
		private static string s_sceneName = Constants.LauncherSceneName;

		/// 加载场景对应 AssetBundle 的请求对象
		private static AssetBundleCreateRequest s_abcr = null;
		/// 载入场景的异步操作对象
		private static AsyncOperation s_ao = null;
		/// 异步加载场景的协程对象
		private static Coroutine s_alcCoroutine = null;

		#if UNITY_EDITOR
		/// 抛出 EVENT_COMPLETE 事件的协程对象
		private static Coroutine s_dceCoroutine = null;
		#endif


		#region UI初始化与清空销毁

		/// <summary>
		/// 初始化，（重新）创建所有图层
		/// </summary>
		[NoToLuaAttribute]
		public static void Initialize ()
		{
			uiCanvas = uiCanvasTra.gameObject.GetComponent<Canvas> ();
			sceneLayer = (RectTransform)uiCanvasTra.Find ("scene");
			uiLayer = (RectTransform)uiCanvasTra.Find ("ui");
			windowLayer = (RectTransform)uiCanvasTra.Find ("window");
			uiTopLayer = (RectTransform)uiCanvasTra.Find ("uiTop");
			alertLayer = (RectTransform)uiCanvasTra.Find ("alert");
			guideLayer = (RectTransform)uiCanvasTra.Find ("guide");
			topLayer = (RectTransform)uiCanvasTra.Find ("top");
		}


		/// <summary>
		/// 清空UI（切换场景时）
		/// </summary>
		public static void CleanUI ()
		{
			for (int i = 0; i < uiCanvasTra.childCount; i++) {
				Transform layer = uiCanvasTra.GetChild (i);
				for (int n = 0; n < layer.childCount; n++)
					DestroyChildUI (layer.GetChild (n));
			}
		}

		/// <summary>
		/// 销毁子UI
		/// </summary>
		/// <returns><c>true</c>, if child U was destroyed, <c>false</c> otherwise.</returns>
		/// <param name="tra">Tra.</param>
		private static bool DestroyChildUI (Transform tra)
		{
			if (s_dontDestroyList.Contains (tra))
				return false;// 本身不可销毁

			bool canDestroy = true;
			for (int i = tra.childCount - 1; i >= 0; i--) {
				// 子节点不可销毁
				Transform child = tra.GetChild (i);
				if (s_dontDestroyList.Contains (child)) {
					canDestroy = false;
				} else {
					if (!DestroyChildUI (child))
						canDestroy = false;
				}
			}
			if (canDestroy) {
				GameObject.Destroy (tra.gameObject);
			}
			return canDestroy;
		}


		/// <summary>
		/// 添加一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
		/// </summary>
		/// <param name="go">Go.</param>
		public static void AddDontDestroy (GameObject go)
		{
			s_dontDestroyList.Add (go.transform);
		}

		/// <summary>
		/// 移除一个在清空（切换）场景时，无需被销毁的对象（UI图层中的对象）
		/// </summary>
		/// <param name="go">Go.</param>
		public static void RemoveDontDestroy (GameObject go)
		{
			s_dontDestroyList.Remove (go.transform);
		}

		#endregion



		#region 加载场景

		/// <summary>
		/// 同步加载场景
		/// </summary>
		/// <param name="sceneName">Scene path.</param>
		public static void LoadScene (string sceneName)
		{
			#if UNITY_EDITOR
			if (Common.IsDebug) {
				// [ Editor Play Mode ] 请将要加载的场景（在 Assets/Res/Scene/ 目录下）加入到 [ Build Settings -> Scenes In Build ] 中
				SceneManager.LoadScene (sceneName);
				return;
			}
			#endif

			// 这两个是随包走的场景
			if (sceneName != Constants.LauncherSceneName && sceneName != Constants.EmptySceneName) {
				ABI abi = ResManager.GetAbi (ResManager.GetPathMD5 (sceneName));
				if (abi.ab == null) {
					ABLoader.ParseFilePath (abi);
					abi.ab = AssetBundle.LoadFromFile (abi.filePath);// 先加载场景对应的 AssetBundle
				}
			}

			Common.looper.StartCoroutine (UnloadSceneAssetBundle (s_sceneName));
			s_sceneName = sceneName;
			SceneManager.LoadScene (sceneName);// 再载入场景
		}



		/// <summary>
		/// 异步加载场景
		/// </summary>
		/// <param name="scenePath">Scene path.</param>
		public static void LoadSceneAsync (string sceneName)
		{
			#if UNITY_EDITOR
			if (Common.IsDebug) {
				DispatchLuaEvent (EVENT_START, sceneName);

				if (s_dceCoroutine != null)
					Common.looper.StopCoroutine (s_dceCoroutine);
				s_dceCoroutine = Common.looper.StartCoroutine (DispatchCompleteEvent (sceneName));
				return;
			}
			#endif

			Common.looper.StartCoroutine (UnloadSceneAssetBundle (s_sceneName));
			s_sceneName = sceneName;

			if (s_alcCoroutine != null)
				Common.looper.StopCoroutine (s_alcCoroutine);
			
			s_abcr = null;
			s_ao = null;
			s_alcCoroutine = Common.looper.StartCoroutine (DoLoadSceneAsync ());
		}


		private static IEnumerator DoLoadSceneAsync ()
		{
			DispatchLuaEvent (EVENT_START, s_sceneName);
			ABI abi = ResManager.GetAbi (ResManager.GetPathMD5 (s_sceneName));
			if (abi.ab == null) {
				// 先异步加载场景对应的 AssetBundle
				ABLoader.ParseFilePath (abi);
				s_abcr = AssetBundle.LoadFromFileAsync (abi.filePath);
				yield return s_abcr;
				abi.ab = s_abcr.assetBundle;
				s_abcr = null;
			}

			// 再异步加载场景
			s_ao = SceneManager.LoadSceneAsync (s_sceneName);
			yield return s_ao;
			s_ao = null;
			s_alcCoroutine = null;

			DispatchLuaEvent (EVENT_COMPLETE, s_sceneName);
		}


		#if UNITY_EDITOR
		/// <summary>
		/// 在 editor play mode 状态下，延迟后抛出场景异步加载完成事件
		/// </summary>
		/// <returns>The all complete event.</returns>
		private static IEnumerator DispatchCompleteEvent (string sceneName)
		{
			yield return new WaitForSeconds (0.2f);
			s_dceCoroutine = null;
			s_sceneName = sceneName;
			SceneManager.LoadScene (sceneName);
			DispatchLuaEvent (EVENT_COMPLETE, sceneName);
		}
		#endif


		/// <summary>
		/// 在 lua 层抛出事件
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="sceneName">Scene Name.</param>
		private static void DispatchLuaEvent (string type, string sceneName)
		{
			// 不能在 Initialize() 时获取该函数，因为相互依赖
			if (s_dispatchEvent == null)
				s_dispatchEvent = Common.luaMgr.state.GetFunction ("LoadSceneEvent.DispatchEvent");

			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (type);
			s_dispatchEvent.Push (sceneName);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}


		/// <summary>
		/// 获取当前异步加载进度 0~1
		/// </summary>
		/// <returns>The progress.</returns>
		public static float GetProgress ()
		{
			// 没有在加载场景
			if (s_abcr == null && s_ao == null)
				return 1;

			// 正在加载场景对应的 AssetBundle
			if (s_abcr != null)
				return s_abcr.progress * 0.9f;

			// 正在异步加载场景本身
			return Mathf.Min (s_ao.progress + 0.1f, 1f) * 0.1f + 0.9f;
		}

		#endregion



		/// <summary>
		/// 获取当前场景的名称
		/// </summary>
		/// <value>The name of the current scene.</value>
		public static string currentSceneName {
			get { return s_sceneName; }
		}



		/// <summary>
		/// 延迟卸载包含场景的 AssetBundle
		/// </summary>
		/// <returns>The scene.</returns>
		/// <param name="sceneName">Scene name.</param>
		private static IEnumerator UnloadSceneAssetBundle (string sceneName)
		{
			yield return new WaitForSeconds (5f);

			// 等待异步场景加载完成
			while (s_alcCoroutine != null) {
				yield return new WaitForEndOfFrame ();
			}

			if (sceneName == s_sceneName)
				yield break;

			ABI abi = ResManager.GetAbi (ResManager.GetPathMD5 (sceneName));
			if (abi != null && abi.ab != null) {
				abi.ab.Unload (true);
				abi.ab = null;
				Debug.Log ("[Unload] Scene: " + sceneName);
			}
		}


		//
	}
}