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

		private static readonly Vector3 sceneLayerPos = new Vector3 (0, 0, 750);
		private static readonly Vector3 uiLayerPos = new Vector3 (0, 0, 650);
		private static readonly Vector3 windowLayerPos = new Vector3 (0, 0, 550);
		private static readonly Vector3 uiTopLayerPos = new Vector3 (0, 0, 450);
		private static readonly Vector3 alertLayerPos = new Vector3 (0, 0, 350);
		private static readonly Vector3 guideLayerPos = new Vector3 (0, 0, 250);
		private static readonly Vector3 topLayerPos = new Vector3 (0, 0, 150);

		/// 在 lua 层抛出 LoadResEvent 的方法。 - Events/LoadSceneEvent.lua
		private static LuaFunction _dispatchEvent;

		public static Transform uiCanvas;
		public static Transform sceneLayer;
		public static Transform uiLayer;
		public static Transform windowLayer;
		public static Transform uiTopLayer;
		public static Transform alertLayer;
		public static Transform guideLayer;
		public static Transform topLayer;

		/// 不需要被销毁的对象列表 [ key = 对象本身, value = 层级列表（从对象父级[0] 到根图层） ]
		private static readonly Dictionary<GameObject, List<string>> _dontDestroyMap = new Dictionary<GameObject, List<string>> ();

		/// 当前所在场景名称
		private static string _sceneName = Constants.LauncherSceneName;

		private static AssetBundleCreateRequest _abcr = null;
		private static AsyncOperation _ao = null;
		/// 异步加载场景的协程对象
		private static Coroutine _alcCoroutine = null;

		#if UNITY_EDITOR
		/// 抛出 EVENT_COMPLETE 事件的协程对象
		private static Coroutine _dceCoroutine = null;
		#endif


		#region 清空与销毁

		/// <summary>
		/// 初始化，（重新）创建所有图层
		/// </summary>
		public static void Initialize ()
		{
			sceneLayer = LuaHelper.CreateGameObject ("scene", uiCanvas, false).transform;
			sceneLayer.localPosition = sceneLayerPos;

			uiLayer = LuaHelper.CreateGameObject ("ui", uiCanvas, false).transform;
			uiLayer.localPosition = uiLayerPos;

			windowLayer = LuaHelper.CreateGameObject ("window", uiCanvas, false).transform;
			windowLayer.localPosition = windowLayerPos;

			uiTopLayer = LuaHelper.CreateGameObject ("uiTop", uiCanvas, false).transform;
			uiTopLayer.localPosition = uiTopLayerPos;

			alertLayer = LuaHelper.CreateGameObject ("alert", uiCanvas, false).transform;
			alertLayer.localPosition = alertLayerPos;

			guideLayer = LuaHelper.CreateGameObject ("guide", uiCanvas, false).transform;
			guideLayer.localPosition = guideLayerPos;

			topLayer = LuaHelper.CreateGameObject ("top", uiCanvas, false).transform;
			topLayer.localPosition = topLayerPos;
		}


		/// <summary>
		/// 清空场景
		/// </summary>
		public static void Clean ()
		{
			// 保留不被销毁的对象
			foreach (var item in _dontDestroyMap) {
				Transform trans = item.Key.transform;
				// 记录层级列表
				Transform parent = trans.parent;
				item.Value.Clear ();
				while (parent != uiCanvas) {
					item.Value.Add (parent.name);
					parent = parent.parent;
				}
				// 移到 uiCanvas 节点
				trans.SetParent (uiCanvas);
			}

			// 销毁所有图层。改名是因为使用 Destroy() 不会立即销毁，接下来还是会 Find() 到该对象
			sceneLayer.name = uiLayer.name = windowLayer.name = uiTopLayer.name = alertLayer.name = guideLayer.name = topLayer.name = "Destroying";
			GameObject.Destroy (sceneLayer.gameObject);
			GameObject.Destroy (uiLayer.gameObject);
			GameObject.Destroy (windowLayer.gameObject);
			GameObject.Destroy (uiTopLayer.gameObject);
			GameObject.Destroy (alertLayer.gameObject);
			GameObject.Destroy (guideLayer.gameObject);
			GameObject.Destroy (topLayer.gameObject);

			// 重新创建图层
			Initialize ();

			// 重新建立保留对象的层级列表
			foreach (var item in _dontDestroyMap) {
				Transform parent = uiCanvas;
				for (int i = item.Value.Count - 1; i >= 0; i--) {
					Transform trans = parent.Find (item.Value [i]);
					if (trans == null) {
						trans = new GameObject (item.Value [i]).transform;
						trans.parent = parent;
					}
					parent = trans;
				}
				item.Key.transform.SetParent (parent);
			}
		}


		/// <summary>
		/// 添加一个在清除场景时，不需被销毁的 GameObject
		/// </summary>
		/// <param name="go">Go.</param>
		public static void AddDontDestroy (GameObject go)
		{
			if (!_dontDestroyMap.ContainsKey (go)) {
				_dontDestroyMap.Add (go, new List<string> ());
			}
		}

		/// <summary>
		/// 移除一个在清除场景时，不需被销毁的 GameObject
		/// </summary>
		/// <param name="go">Go.</param>
		public static void RemoveDontDestroy (GameObject go)
		{
			if (_dontDestroyMap.ContainsKey (go)) {
				_dontDestroyMap.Remove (go);
			}
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
			if (Common.isDebug) {
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
					abi.ab = AssetBundle.LoadFromFile (abi.filePath);
				}
			}

			if (_sceneName != Constants.LauncherSceneName && _sceneName != Constants.EmptySceneName)
				Common.looper.StartCoroutine (UnloadSceneAssetBundle (_sceneName));
			
			_sceneName = sceneName;
			SceneManager.LoadScene (sceneName);
		}



		/// <summary>
		/// 异步加载场景
		/// </summary>
		/// <param name="scenePath">Scene path.</param>
		public static void LoadSceneAsync (string sceneName)
		{
			#if UNITY_EDITOR
			if (Common.isDebug) {
				DispatchLuaEvent (EVENT_START, sceneName);

				if (_dceCoroutine != null)
					Common.looper.StopCoroutine (_dceCoroutine);
				_dceCoroutine = Common.looper.StartCoroutine (DispatchCompleteEvent (sceneName));
				return;
			}
			#endif

			if (_alcCoroutine != null)
				Common.looper.StopCoroutine (_alcCoroutine);
			
			_abcr = null;
			_ao = null;
			_alcCoroutine = Common.looper.StartCoroutine (DoLoadSceneAsync (sceneName));
		}


		private static IEnumerator DoLoadSceneAsync (string sceneName)
		{
			DispatchLuaEvent (EVENT_START, sceneName);
			ABI abi = ResManager.GetAbi (ResManager.GetPathMD5 (sceneName));
			if (abi.ab == null) {
				// 异步加载场景对应的 AssetBundle
				ABLoader.ParseFilePath (abi);
				_abcr = AssetBundle.LoadFromFileAsync (abi.filePath);
				yield return _abcr;
				abi.ab = _abcr.assetBundle;
				_abcr = null;
			}

			// 异步加载场景
			_ao = SceneManager.LoadSceneAsync (sceneName);
			yield return _ao;
			_ao = null;
			_alcCoroutine = null;

			Common.looper.StartCoroutine (UnloadSceneAssetBundle (_sceneName));

			_sceneName = sceneName;
			DispatchLuaEvent (EVENT_COMPLETE, sceneName);
		}


		#if UNITY_EDITOR
		/// <summary>
		/// 在 editor play mode 状态下，延迟零点几秒后抛出场景异步加载完成事件
		/// </summary>
		/// <returns>The all complete event.</returns>
		private static IEnumerator DispatchCompleteEvent (string sceneName)
		{
			yield return new WaitForSeconds (0.2f);
			_dceCoroutine = null;
			_sceneName = sceneName;
			SceneManager.LoadScene (sceneName);
			DispatchLuaEvent (EVENT_COMPLETE, sceneName);
		}
		#endif


		/// <summary>
		/// 在 lua 层抛出事件
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="sceneName">Scene Name.</param>
		public static void DispatchLuaEvent (string type, string sceneName)
		{
			// 不能在 Initialize() 时获取该函数，因为相互依赖
			if (_dispatchEvent == null)
				_dispatchEvent = Common.luaMgr.state.GetFunction ("LoadSceneEvent.DispatchEvent");

			_dispatchEvent.BeginPCall ();
			_dispatchEvent.Push (type);
			_dispatchEvent.Push (sceneName);
			_dispatchEvent.PCall ();
			_dispatchEvent.EndPCall ();
		}


		/// <summary>
		/// 获取当前异步加载进度 0~1
		/// </summary>
		/// <returns>The progress.</returns>
		public static float GetProgress ()
		{
			// 没有在加载场景
			if (_abcr == null && _ao == null)
				return 1;

			// 正在加载场景对应的 AssetBundle
			if (_abcr != null)
				return _abcr.progress * 0.9f;

			// 正在异步加载场景本身
			return Mathf.Min (_ao.progress + 0.1f, 1f) * 0.1f + 0.9f;
		}

		#endregion



		/// <summary>
		/// 延迟卸载包含场景的 AssetBundle
		/// </summary>
		/// <returns>The scene.</returns>
		/// <param name="sceneName">Scene name.</param>
		private static IEnumerator UnloadSceneAssetBundle (string sceneName)
		{
			yield return new WaitForSeconds (2f);

			// 等待异步场景加载完成
			while (_alcCoroutine != null) {
				yield return new WaitForEndOfFrame ();
			}

			if (_sceneName == sceneName)
				yield break;
			
			ABI abi = ResManager.GetAbi (ResManager.GetPathMD5 (sceneName));
			if (abi.ab != null) {
				abi.ab.Unload (true);
				abi.ab = null;
				Debug.Log ("[Unload] Scene: " + sceneName);
			}
		}

		//
	}
}

