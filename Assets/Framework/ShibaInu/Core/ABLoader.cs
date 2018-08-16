using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{


	/// <summary>
	/// AssetBundle Info Object
	/// </summary>
	public class ABI
	{
		/// 已加载好的 AssetBundle，值为null，表示未加载
		public AssetBundle ab;

		/// （异步）加载 AssetBundle 完成后，需要异步加载的资源路径列表
		public List<string> loadAssetsAsync = new List<string> ();

		/// 文件路径
		public string path;
		/// 文件 MD5
		public string md5;
		/// 已拼接好的文件完整真实路径，路径包括文件 MD5 以及 后缀名（加载ab包用这个路径）
		public string filePath;

		/// 依赖的 AB文件路径MD5 列表
		public List<string> pedList = new List<string> ();

		/// 引用了该 AssetBundle 的资源组列表，值为 groupName
		public HashSet<string> groupList = new HashSet<string> ();


		public ABI (string path, string md5, string dir)
		{
			this.path = dir + path;
			this.md5 = md5;
		}

		/// <summary>
		/// 添加一个需要异步加载的资源
		/// </summary>
		/// <param name="path">Path.</param>
		public void AddAssetAsync (string path)
		{
			if (!loadAssetsAsync.Contains (path) && !ABLoader.LoadAssetListContains (path)) {
				ABLoader.assetCount++;
				loadAssetsAsync.Add (path);
			}
		}
	}



	/// <summary>
	/// AssetBundle 资源加载器
	/// </summary>
	public class ABLoader
	{
		// lua 层的事件类型
		public const string EVENT_START = "LoadResEvent_Start";
		public const string EVENT_COMPLETE = "LoadResEvent_Complete";
		public const string EVENT_ALL_COMPLETE = "LoadResEvent_All_Complete";

		/// 在 lua 层抛出 LoadResEvent 的方法。 - Events/LoadResEvent.lua
		private static LuaFunction s_dispatchEvent;

		/// 需加载的 AssetBundle 列表
		private static Queue<ABI> s_loadABList = new Queue<ABI> ();
		/// 需加载的资源路径列表
		private static Queue<string> s_loadAssetList = new Queue<string> ();

		/// 当前正在加载 AssetBundle 的 ABI
		private static ABI s_abi;
		/// 当前正在加载的资源
		private static AssetBundleRequest s_abr;
		/// 需要加载的资源总数
		public static int assetCount = 0;

		/// groupName 引用的 ABI 列表
		private static Dictionary<string, HashSet<ABI>> s_groupMap = new Dictionary<string, HashSet<ABI>> ();
		/// 卸载资源的协程对象
		private static Coroutine s_unloadCoroutine;
		/// 需要被卸载的 groupName 列表
		private static HashSet<string> s_unloadList = new HashSet<string> ();


		#region 同步加载

		/// <summary>
		/// 同步加载指定的 AssetBundle
		/// </summary>
		/// <param name="abi">ABI 对象</param>
		public static void Load (ABI abi, string groupName = null)
		{
			// 添加引用关系
			if (groupName != null) {
				AddReference (abi, groupName);
				s_unloadList.Remove (groupName);
			}

			// AssetBundle 文件已加载
			if (abi.ab != null)
				return;

			// 先加载依赖的 AssetBundle
			foreach (string pathMD5 in abi.pedList) {
				ABI pedABI = ResManager.GetAbi (pathMD5);
				if (pedABI.ab == null) {
					Load (pedABI);
				}
			}

			ParseFilePath (abi);
			abi.ab = AssetBundle.LoadFromFile (abi.filePath);
		}


		/// <summary>
		/// 根据 AssetBundle 文件路径和文件md5，查找是在包目录下还是更新目录下，将真实路径保存在 abi.filePath
		/// </summary>
		/// <param name="abi">Abi.</param>
		public static void ParseFilePath (ABI abi)
		{
			if (abi.filePath != null)
				return;

			string realPath = abi.path + "_" + abi.md5 + Constants.AbExtName;
			string filePath = Constants.PackageDir + realPath;
			if (!FileHelper.Exists (filePath))
				filePath = Constants.UpdateDir + realPath;
			abi.filePath = filePath;
		}

		#endregion



		#region 异步加载

		/// <summary>
		/// 异步加载指定的 AssetBundle
		/// </summary>
		/// <param name="abi">ABI 对象</param>
		public static void LoadAsync (ABI abi, string groupName = null)
		{
			// 添加引用关系
			if (groupName != null) {
				AddReference (abi, groupName);
				s_unloadList.Remove (groupName);
			}

			// abi 已在加载队列
			if (s_loadABList.Contains (abi))
				return;

			// AssetBundle 文件已加载
			if (abi.ab != null) {
				LoadAssetAsync (abi);
				return;
			}

			// 先加载依赖的 AssetBundle
			foreach (string pathMD5 in abi.pedList) {
				ABI pedABI = ResManager.GetAbi (pathMD5);
				// 还没加载，并且不在加载队列中
				if (pedABI.ab == null && !s_loadABList.Contains (pedABI)) {
					LoadAsync (pedABI);
				}
			}
			s_loadABList.Enqueue (abi);

			if (s_abi == null) {
				Common.looper.StartCoroutine (LoadNextAsync ());
			}
		}


		/// <summary>
		/// 协程加载下一个 AssetBundle
		/// </summary>
		/// <returns>The next async.</returns>
		private static IEnumerator LoadNextAsync ()
		{
			s_abi = s_loadABList.Dequeue ();
			if (s_abi.ab == null) {
				ParseFilePath (s_abi);
				AssetBundleCreateRequest abcr = AssetBundle.LoadFromFileAsync (s_abi.filePath);
				yield return abcr;
				s_abi.ab = abcr.assetBundle;
			}
			LoadAssetAsync (s_abi);

			if (s_loadABList.Count > 0) {
				Common.looper.StartCoroutine (LoadNextAsync ());
			} else {
				s_abi = null;
			}
		}


		/// <summary>
		/// 将 abi 中需异步加载的资源路径 添加到 _loadAssetList，并启动异步加载
		/// </summary>
		/// <param name="abi">Abi.</param>
		private static void LoadAssetAsync (ABI abi)
		{
			if (abi.loadAssetsAsync.Count == 0)
				return;
			
			foreach (string path in abi.loadAssetsAsync) {
				s_loadAssetList.Enqueue (path);
			}
			abi.loadAssetsAsync.Clear ();

			if (s_abr == null)
				Common.looper.StartCoroutine (LoadNexAssetAsync ());
		}


		/// <summary>
		/// 协程加载下个资源
		/// </summary>
		/// <returns>The nex asset async.</returns>
		private static IEnumerator LoadNexAssetAsync ()
		{
			string path = s_loadAssetList.Dequeue ();
			DispatchLuaEvent (EVENT_START, path);

			ABI abi = ResManager.GetAbiWithAssetPath (path);
			s_abr = abi.ab.LoadAssetAsync (Constants.ResDirPath + path);
			yield return s_abr;

			DispatchLuaEvent (EVENT_COMPLETE, path, s_abr.asset);

			if (s_loadAssetList.Count > 0) {
				Common.looper.StartCoroutine (LoadNexAssetAsync ());
			} else {
				s_abr = null;
				// 当前没有 AssetBundle 在加载了
				if (s_abi == null && s_loadABList.Count == 0) {
					ABLoader.assetCount = 0;
					DispatchLuaEvent (EVENT_ALL_COMPLETE);
				}
			}
		}


		/// <summary>
		/// 在 lua 层抛出事件
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="path">Path.</param>
		/// <param name="data">Data.</param>
		public static void DispatchLuaEvent (string type, string path = null, UnityEngine.Object data = null)
		{
			// 不能在 Initialize() 时获取该函数，因为相互依赖
			if (s_dispatchEvent == null)
				s_dispatchEvent = Common.luaMgr.state.GetFunction ("LoadResEvent.DispatchEvent");

			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (type);
			if (path != null)
				s_dispatchEvent.Push (path);
			if (data != null)
				s_dispatchEvent.Push (data);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}


		/// <summary>
		/// 获取当前异步加载总进度 0~1
		/// </summary>
		/// <returns>The progress.</returns>
		public static float GetProgress ()
		{
			if (assetCount == 0)
				return 1;// 没有在加载的资源
			
			// 正在加载的队列
			float count = s_loadAssetList.Count;

			// 还没加载的 ABI
			foreach (ABI abi in s_loadABList)
				count += abi.loadAssetsAsync.Count;
			
			// 正在加载的 ABI
			if (s_abi != null)
				count += s_abi.loadAssetsAsync.Count;

			// 正在加载的资源
			if (s_abr != null)
				count += 1 - s_abr.progress;

			return (assetCount - count) / assetCount;
		}


		/// <summary>
		/// 需加载的资源路径列表是否已存在 path
		/// </summary>
		/// <returns><c>true</c>, if asset list contains was loaded, <c>false</c> otherwise.</returns>
		/// <param name="path">Path.</param>
		public static bool LoadAssetListContains (string path)
		{
			return s_loadAssetList.Contains (path);
		}

		#endregion



		#region 引用与销毁

		/// <summary>
		/// 添加引用关系
		/// </summary>
		/// <param name="abi">Abi.</param>
		/// <param name="groupName">Group name.</param>
		private static void AddReference (ABI abi, string groupName)
		{
			// 标记 abi 被 groupName 引用
			abi.groupList.Add (groupName);

			// 标记 groupName 引用了 abi
			HashSet<ABI> abiList;
			if (!s_groupMap.TryGetValue (groupName, out abiList)) {
				s_groupMap.Add (groupName, new HashSet<ABI> ());
				abiList = s_groupMap [groupName];
			}
			abiList.Add (abi);

			// abi 依赖的其他 abi 也要标记被该 groupName 引用
			foreach (string pathMD5 in abi.pedList)
				AddReference (ResManager.GetAbi (pathMD5), groupName);
		}


		/// <summary>
		/// 移除 groupName 对应的引用关系，并卸载没有任何引用的资源
		/// </summary>
		/// <param name="groupName">Group name.</param>
		public static void RemoveReference (string groupName)
		{
			s_unloadList.Add (groupName);
			if (s_unloadCoroutine == null)
				s_unloadCoroutine = Common.looper.StartCoroutine (DoRemoveReference ());
		}


		private static IEnumerator DoRemoveReference ()
		{
			// 等待异步资源加载完成
			while (GetProgress () != 1) {
				yield return new WaitForEndOfFrame ();
			}
			s_unloadCoroutine = null;

			foreach (string groupName in s_unloadList) {
				HashSet<ABI> abiList;
				if (!s_groupMap.TryGetValue (groupName, out abiList))
					continue;
				s_groupMap.Remove (groupName);

				foreach (ABI abi in abiList) {
					// 移除引用
					abi.groupList.Remove (groupName);

					// 可以卸载了
					if (abi.groupList.Count == 0) {
						abi.ab.Unload (true);
						abi.ab = null;
						Debug.Log ("[Unload] Path: " + abi.path + ",  GroupName: " + groupName);
					}
				}
			}
			s_unloadList.Clear ();
		}

		#endregion




		//
	}
}

