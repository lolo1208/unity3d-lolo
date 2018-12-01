using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

	/// <summary>
	/// 资源管理器
	/// </summary>
	public class ResManager
	{
		/// lua的包文件夹列表
		private static readonly string[] m_luaPackages = { "ToLua/", "ShibaInu/", "App/" };

		/// 路径 -> 路径MD5 映射列表
		private static Dictionary<string, string> s_pathMD5Dic = new Dictionary<string, string> ();
		/// lua文件路径 -> 真实完整路径 映射列表
		private static Dictionary<string, string> s_luaPathDic = new Dictionary<string, string> ();

		/// lua 文件列表[ key = lua文件路径，value = 文件MD5 ]
		private static Dictionary<string, string> s_luaDic = new Dictionary<string, string> ();
		/// ABI 列表[ key = AB文件路径MD5，value = ABI对象 ]
		private static Dictionary<string, ABI> s_abiDic = new Dictionary<string, ABI> ();
		/// 资源文件列表[ key = 资源文件路径MD5，value = ABI对象 ]
		private static Dictionary<string, ABI> s_resDic = new Dictionary<string, ABI> ();

		/// 抛出 ABLoader.EVENT_ALL_COMPLETE 事件的协程对象
		private static Coroutine s_daceCoroutine;

		/// 需要被延迟卸载到资源组列表
		private static HashSet<string> s_delayedUnloadList = new HashSet<string> ();



		#region 初始化

		[NoToLuaAttribute]
		public static void Initialize ()
		{
			if (!Common.isDebug) {
				ParseResInfo ();
			}
		}


		/// <summary>
		/// 解析资源信息文件
		/// </summary>
		private static void ParseResInfo ()
		{
			string resInfoFilePath = Constants.UpdateDir + "ResInfo";
			if (!FileHelper.Exists (resInfoFilePath))// 从未更新过
				resInfoFilePath = Constants.PackageDir + "ResInfo";


			s_luaDic.Clear ();
			s_abiDic.Clear ();
			s_resDic.Clear ();
			s_luaPathDic.Clear ();

			// 解析资源信息文件
			using (BinaryReader reader = new BinaryReader (new MemoryStream (FileHelper.GetBytes (resInfoFilePath)))) {
				ushort ushort1, ushort2, i, n;
				byte byte1, byte2, pathLen;
				string path, md5, pathMD5;
				ABI abi;

				// 所有lua文件
				ushort1 = reader.ReadUInt16 ();
				for (i = 0; i < ushort1; i++) {
					pathLen = reader.ReadByte ();
					path = new string (reader.ReadChars (pathLen));
					md5 = new string (reader.ReadChars (16));
					s_luaDic.Add (path, md5);
				}

				// 所有场景文件
				byte1 = reader.ReadByte ();
				for (i = 0; i < byte1; i++) {
					pathLen = reader.ReadByte ();
					path = new string (reader.ReadChars (pathLen));// "Loading" or "SceneA"
					md5 = new string (reader.ReadChars (16));

					abi = new ABI (path, md5, "Scenes/");
					pathMD5 = GetPathMD5 (path);
					s_abiDic.Add (pathMD5, abi);
				}

				// 所有 AssetBundle 文件
				ushort1 = reader.ReadUInt16 ();
				for (i = 0; i < ushort1; i++) {
					pathLen = reader.ReadByte ();
					path = new string (reader.ReadChars (pathLen));// "material/test" or "prefab/test/testui" or "texture/test_bar"
					md5 = new string (reader.ReadChars (16));

					abi = new ABI (path, md5, "Res/");
					pathMD5 = GetPathMD5 (path + Constants.AbExtName);
					s_abiDic.Add (pathMD5, abi);

					// 包含的资源文件
					ushort2 = reader.ReadUInt16 ();
					for (n = 0; n < ushort2; n++) {
						pathMD5 = new string (reader.ReadChars (16));
						s_resDic.Add (pathMD5, abi);
					}

					// 依赖的 AssetBundle
					byte2 = reader.ReadByte ();
					for (n = 0; n < byte2; n++) {
						pathMD5 = new string (reader.ReadChars (16));
						abi.pedList.Add (pathMD5);
					}
				}
			}
		}

		#endregion



		#region 加载资源

		/// <summary>
		/// 同步加载 path 对应的 AssetBundle，并返回返回 path 对应的数据
		/// </summary>
		/// <returns>The asset.</returns>
		/// <param name="path">Path.</param>
		/// <param name="path">Group Name.</param>
		public static UnityEngine.Object LoadAsset (string path, string groupName = null)
		{
			return LoadAssetWithType<UnityEngine.Object> (path, groupName);
		}

		public static UnityEngine.Sprite LoadSprite (string path, string groupName = null)
		{
			return LoadAssetWithType<UnityEngine.Sprite> (path, groupName);
		}

		public static UnityEngine.Shader LoadShader (string path, string groupName = null)
		{
			return LoadAssetWithType<UnityEngine.Shader> (path, groupName);
		}

		public static UnityEngine.AudioClip LoadAudioClip (string path, string groupName = null)
		{
			return LoadAssetWithType<UnityEngine.AudioClip> (path, groupName);
		}

		public static string LoadText (string path, string groupName = null)
		{
			TextAsset asset = LoadAssetWithType<UnityEngine.TextAsset> (path, groupName);
			return asset.text;
		}

		private static T LoadAssetWithType<T> (string path, string groupName) where T : UnityEngine.Object
		{
			if (groupName == null)
				groupName = Stage.currentSceneName;

			#if UNITY_EDITOR
			if (Common.isDebug) {
				if (!File.Exists (Constants.ResDirPath + path)) {
					throw new LuaException (string.Format (Constants.E5001, path));
				}
				return UnityEditor.AssetDatabase.LoadAssetAtPath<T> (Constants.ResDirPath + path);
			}

			string pathMD5 = GetPathMD5 (path);
			if (!s_resDic.ContainsKey (pathMD5)) {
				throw new LuaException (string.Format (Constants.E5001, path));
			}
			#endif

			s_delayedUnloadList.Remove (groupName);

			ABI abi = GetAbiWithAssetPath (path);
			ABLoader.Load (abi, groupName);
			return abi.ab.LoadAsset<T> (Constants.ResDirPath + path);
		}



		/// <summary>
		/// 异步加载资源。
		/// 在 lua 层可通过向 Res 注册 LoadEvent 相关事件来跟踪加载状态
		/// </summary>
		/// <param name="path">Path.</param>
		/// <param name="path">Group Name.</param>
		public static void LoadAssetAsync (string path, string groupName = null)
		{
			LoadAssetAsyncWithType<UnityEngine.Object> (path, groupName);
		}

		public static void LoadSpriteAsync (string path, string groupName = null)
		{
			LoadAssetAsyncWithType<UnityEngine.Sprite> (path, groupName);
		}

		public static void LoadShaderAsync (string path, string groupName = null)
		{
			LoadAssetAsyncWithType<UnityEngine.Shader> (path, groupName);
		}

		public static void LoadAudioClipAsync (string path, string groupName = null)
		{
			LoadAssetAsyncWithType<UnityEngine.AudioClip> (path, groupName);
		}

		private static void LoadAssetAsyncWithType<T> (string path, string groupName) where T : UnityEngine.Object
		{
			if (groupName == null)
				groupName = Stage.currentSceneName;
			
			#if UNITY_EDITOR
			if (Common.isDebug) {
				if (!File.Exists (Constants.ResDirPath + path))
					throw new LuaException (string.Format (Constants.E5001, path));

				DispatchLuaEvent (EVENT_START, path);
				Common.looper.StartCoroutine (DispatchCompleteEvent (path,
					UnityEditor.AssetDatabase.LoadAssetAtPath<T> (Constants.ResDirPath + path)
				));
				return;
			}

			string pathMD5 = GetPathMD5 (path);
			if (!s_resDic.ContainsKey (pathMD5)) {
				throw new LuaException (string.Format (Constants.E5001, path));
			}
			#endif

			s_delayedUnloadList.Remove (groupName);

			ABI abi = GetAbiWithAssetPath (path);
			abi.AddAssetAsync (path, typeof(T));
			ABLoader.LoadAsync (abi, groupName);
		}



		#if UNITY_EDITOR

		/// <summary>
		/// 在 editor play mode 状态下，延迟抛出资源异步加载完成事件
		/// </summary>
		/// <returns>The complete event.</returns>
		/// <param name="path">Path.</param>
		/// <param name="data">Data.</param>
		private static IEnumerator DispatchCompleteEvent (string path, UnityEngine.Object data)
		{
			if (s_daceCoroutine != null) {
				Common.looper.StopCoroutine (s_daceCoroutine);
				s_daceCoroutine = null;
			}
			
			yield return new WaitForSeconds (0.1f);
			DispatchLuaEvent (EVENT_COMPLETE, path, data);

			if (s_daceCoroutine != null)
				Common.looper.StopCoroutine (s_daceCoroutine);
			s_daceCoroutine = Common.looper.StartCoroutine (DispatchAllCompleteEvent ());
		}

		/// <summary>
		/// 在 editor play mode 状态下，延迟抛出所有资源异步加载完成事件
		/// </summary>
		/// <returns>The all complete event.</returns>
		private static IEnumerator DispatchAllCompleteEvent ()
		{
			yield return new WaitForSeconds (0.1f);
			s_daceCoroutine = null;
			DispatchLuaEvent (EVENT_ALL_COMPLETE);
		}

		#endif


		/// <summary>
		/// 获取当前异步加载总进度 0~1
		/// </summary>
		/// <returns>The progress.</returns>
		public static float GetProgress ()
		{
			return ABLoader.GetProgress ();
		}

		#endregion



		#region 卸载资源

		/// <summary>
		/// 卸载资源
		/// </summary>
		/// <param name="groupName">Group name.</param>
		/// <param name="delay">Delay.</param>
		public static void Unload (string groupName, float delay = 0)
		{
			#if UNITY_EDITOR
			if (Common.isDebug)
				return;
			#endif

			if (delay > 0)
				Common.looper.StartCoroutine (DelayedUnload (groupName, delay));
			else
				ABLoader.RemoveReference (groupName);
		}


		private static IEnumerator DelayedUnload (string groupName, float delay)
		{
			// 先添加到需要被延迟卸载到列表中，以防 delay 过程中该 groupName 又进行了加载
			s_delayedUnloadList.Add (groupName);

			yield return new WaitForSeconds (delay);

			if (s_delayedUnloadList.Contains (groupName)) {
				s_delayedUnloadList.Remove (groupName);
				ABLoader.RemoveReference (groupName);
			}
		}

		#endregion



		#region Path / MD5 / ABI 的转换和获取

		/// <summary>
		/// 获取路径对应的 MD5
		/// </summary>
		/// <returns>The path MD5.</returns>
		/// <param name="path">Path.</param>
		[NoToLuaAttribute]
		public static string GetPathMD5 (string path)
		{
			string md5;
			if (s_pathMD5Dic.ContainsKey (path)) {
				s_pathMD5Dic.TryGetValue (path, out md5);
			} else {
				md5 = MD5Util.GetMD5 (path);
				s_pathMD5Dic.Add (path, md5);
			}
			return md5;
		}


		/// <summary>
		/// 通过 AssetBundle 的路径MD5 来获取对应的ABI（由 ABLoader 调用）
		/// </summary>
		/// <returns>The abi.</returns>
		/// <param name="abPathMD5">Ab path M d5.</param>
		[NoToLuaAttribute]
		public static ABI GetAbi (string abPathMD5)
		{
			ABI abi;
			s_abiDic.TryGetValue (abPathMD5, out abi);
			return abi;
		}


		/// <summary>
		/// 通过资源路径 来获取对应的ABI（由 ABLoader 调用）
		/// </summary>
		/// <returns>The abi with asset path.</returns>
		/// <param name="path">Path.</param>
		[NoToLuaAttribute]
		public static ABI GetAbiWithAssetPath (string path)
		{
			ABI abi;
			s_resDic.TryGetValue (GetPathMD5 (path), out abi);
			return abi;
		}

		#endregion



		#region 获取 Lua 文件的字节内容

		/// <summary>
		/// 获取 Lua 文件的字节内容
		/// </summary>
		/// <returns>The lua file bytes.</returns>
		/// <param name="path">lua 路径，如：Module/Core/launcher </param>
		[NoToLuaAttribute]
		public static byte[] GetLuaFileBytes (string path)
		{
			// 不需要后缀名
			path = path.Replace (".lua", "");

			// 已经缓存过文件真实路径了，直接返回文件内容
			if (s_luaPathDic.ContainsKey (path)) {
				s_luaPathDic.TryGetValue (path, out path);
				return FileHelper.GetBytes (path);
			}

			// 在 LuaPackages 中找到对应到文件
			bool isFound = false;
			string foundPath = string.Empty;
			for (int i = 0; i < m_luaPackages.Length; i++) {
				foundPath = m_luaPackages [i] + path;
				if (s_luaDic.ContainsKey (foundPath)) {
					isFound = true;
					break;
				}
			}

			if (!isFound) {
				throw new LuaException (string.Format (Constants.E1002, path));
			}

			// 转换成真实路径，并查找文件
			string md5;
			s_luaDic.TryGetValue (foundPath, out md5);
			string realPath = "Lua/" + foundPath + "_" + md5 + Constants.LuaExtName;

			string filePath = Constants.PackageDir + realPath;
			if (!FileHelper.Exists (filePath))
				filePath = Constants.UpdateDir + realPath;

			s_luaPathDic.Add (path, filePath);

			// 返回文件内容
			return FileHelper.GetBytes (filePath);
		}

		#endregion


		#region 在 lua 层抛出事件

		// lua 层的事件类型
		[NoToLuaAttribute]
		public const string EVENT_START = "LoadResEvent_Start";
		[NoToLuaAttribute]
		public const string EVENT_COMPLETE = "LoadResEvent_Complete";
		[NoToLuaAttribute]
		public const string EVENT_ALL_COMPLETE = "LoadResEvent_All_Complete";

		/// 在 lua 层抛出 LoadResEvent 的方法。 - Events/LoadResEvent.lua
		private static LuaFunction s_dispatchEvent;

		/// <summary>
		/// 在 lua 层抛出事件
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="path">Path.</param>
		/// <param name="data">Data.</param>
		[NoToLuaAttribute]
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

		#endregion


		//
	}
}

