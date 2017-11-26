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
		private static readonly string[] LuaPackages = { "ToLua/", "ShibaInu/", "App/" };

		/// 路径 -> 路径MD5 映射列表
		private static Dictionary<string, string> _pathMD5Dic = new Dictionary<string, string> ();
		/// lua文件路径 -> 真实完整路径 映射列表
		private static Dictionary<string, string> _luaPathDic = new Dictionary<string, string> ();

		/// lua 文件列表[ key = lua文件路径，value = 文件MD5 ]
		private static Dictionary<string, string> _luaDic = new Dictionary<string, string> ();
		/// ABI 列表[ key = AB文件路径MD5，value = ABI对象 ]
		private static Dictionary<string, ABI> _abiDic = new Dictionary<string, ABI> ();
		/// 资源文件列表[ key = 资源文件路径MD5，value = ABI对象 ]
		private static Dictionary<string, ABI> _resDic = new Dictionary<string, ABI> ();

		/// 抛出 ABLoader.EVENT_ALL_COMPLETE 事件的协程对象
		private static Coroutine _daceCoroutine;

		/// 需要被延迟卸载到资源组列表
		private static HashSet<string> _delayedUnloadList = new HashSet<string> ();



		#region 初始化

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

			_luaDic.Clear ();
			_abiDic.Clear ();
			_resDic.Clear ();
			_luaPathDic.Clear ();

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
					_luaDic.Add (path, md5);
				}

				// 所有场景文件
				byte1 = reader.ReadByte ();
				for (i = 0; i < byte1; i++) {
					pathLen = reader.ReadByte ();
					path = new string (reader.ReadChars (pathLen));// "Loading" or "SceneA"
					md5 = new string (reader.ReadChars (16));

					abi = new ABI (path, md5, "Scene/");
					pathMD5 = GetPathMD5 (path);
					_abiDic.Add (pathMD5, abi);
				}

				// 所有 AssetBundle 文件
				ushort1 = reader.ReadUInt16 ();
				for (i = 0; i < ushort1; i++) {
					pathLen = reader.ReadByte ();
					path = new string (reader.ReadChars (pathLen));// "material/test" or "prefab/test/testui" or "texture/test_bar"
					md5 = new string (reader.ReadChars (16));

					abi = new ABI (path, md5, "Res/");
					pathMD5 = GetPathMD5 (path + Constants.AbExtName);
					_abiDic.Add (pathMD5, abi);

					// 包含的资源文件
					ushort2 = reader.ReadUInt16 ();
					for (n = 0; n < ushort2; n++) {
						pathMD5 = new string (reader.ReadChars (16));
						_resDic.Add (pathMD5, abi);
					}

					// 依赖的 AssetBundle
					byte2 = reader.ReadByte ();
					for (n = 0; n < byte2; n++) {
						pathMD5 = new string (reader.ReadChars (16));
						abi.pedList.Add (pathMD5);
					}
				}
				// Debug.Log ("!!!!  " + reader.BaseStream.Position.ToString () + "  " + reader.BaseStream.Length.ToString ());
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
		public static UnityEngine.Object LoadAsset (string path, string groupName)
		{
			#if UNITY_EDITOR
			if (Common.isDebug) {
				if (!File.Exists (Constants.ResDirPath + path)) {
					throw new LuaException (string.Format (Constants.E5001, path));
				}
				return UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object> (Constants.ResDirPath + path);
			}

			string pathMD5 = GetPathMD5 (path);
			if (!_resDic.ContainsKey (pathMD5)) {
				throw new LuaException (string.Format (Constants.E5001, path));
			}
			#endif

			_delayedUnloadList.Remove (groupName);

			ABI abi = GetAbiWithAssetPath (path);
			ABLoader.Load (abi, groupName);
			return abi.ab.LoadAsset (Constants.ResDirPath + path);
		}


		/// <summary>
		/// 异步加载资源。
		/// 在 lua 层可通过向 Res 注册 LoadEvent 相关事件来跟踪加载状态
		/// </summary>
		/// <param name="path">Path.</param>
		/// <param name="path">Group Name.</param>
		public static void LoadAssetAsync (string path, string groupName)
		{
			#if UNITY_EDITOR
			if (Common.isDebug) {
				if (!File.Exists (Constants.ResDirPath + path)) {
					throw new LuaException (string.Format (Constants.E5001, path));
				}

				ABLoader.DispatchLuaEvent (ABLoader.EVENT_START, path);
				ABLoader.DispatchLuaEvent (ABLoader.EVENT_COMPLETE, path,
					UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object> (Constants.ResDirPath + path)
				);

				if (_daceCoroutine != null)
					Common.looper.StopCoroutine (_daceCoroutine);
				_daceCoroutine = Common.looper.StartCoroutine (DispatchAllCompleteEvent ());
				return;
			}

			string pathMD5 = GetPathMD5 (path);
			if (!_resDic.ContainsKey (pathMD5)) {
				throw new LuaException (string.Format (Constants.E5001, path));
			}
			#endif

			_delayedUnloadList.Remove (groupName);

			ABI abi = GetAbiWithAssetPath (path);
			abi.AddAssetAsync (path);
			ABLoader.LoadAsync (abi, groupName);
		}


		#if UNITY_EDITOR
		/// <summary>
		/// 在 editor play mode 状态下，延迟零点几秒后抛出所有资源异步加载完成事件
		/// </summary>
		/// <returns>The all complete event.</returns>
		private static IEnumerator DispatchAllCompleteEvent ()
		{
			yield return new WaitForSeconds (0.2f);
			_daceCoroutine = null;
			ABLoader.DispatchLuaEvent (ABLoader.EVENT_ALL_COMPLETE);
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
			_delayedUnloadList.Add (groupName);

			yield return new WaitForSeconds (delay);

			if (_delayedUnloadList.Contains (groupName)) {
				_delayedUnloadList.Remove (groupName);
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
		public static string GetPathMD5 (string path)
		{
			string md5;
			if (_pathMD5Dic.ContainsKey (path)) {
				_pathMD5Dic.TryGetValue (path, out md5);
			} else {
				md5 = MD5Util.GetMD5 (path);
				_pathMD5Dic.Add (path, md5);
			}
			return md5;
		}


		/// <summary>
		/// 通过 AssetBundle 的路径MD5 来获取对应的ABI（由 ABLoader 调用）
		/// </summary>
		/// <returns>The abi.</returns>
		/// <param name="abPathMD5">Ab path M d5.</param>
		public static ABI GetAbi (string abPathMD5)
		{
			ABI abi;
			_abiDic.TryGetValue (abPathMD5, out abi);
			return abi;
		}


		/// <summary>
		/// 通过资源路径 来获取对应的ABI（由 ABLoader 调用）
		/// </summary>
		/// <returns>The abi with asset path.</returns>
		/// <param name="path">Path.</param>
		public static ABI GetAbiWithAssetPath (string path)
		{
			ABI abi;
			_resDic.TryGetValue (GetPathMD5 (path), out abi);
			return abi;
		}

		#endregion



		#region 获取 Lua 文件的字节内容

		/// <summary>
		/// 获取 Lua 文件的字节内容
		/// </summary>
		/// <returns>The lua file bytes.</returns>
		/// <param name="path">lua 路径，如：Module/Core/launcher </param>
		public static byte[] GetLuaFileBytes (string path)
		{
			// 不需要后缀名
			path = path.Replace (".lua", "");

			// 已经缓存过文件真实路径了，直接返回文件内容
			if (_luaPathDic.ContainsKey (path)) {
				_luaPathDic.TryGetValue (path, out path);
				return FileHelper.GetBytes (path);
			}

			// 在 LuaPackages 中找到对应到文件
			bool isFound = false;
			string foundPath = string.Empty;
			for (int i = 0; i < LuaPackages.Length; i++) {
				foundPath = LuaPackages [i] + path;
				if (_luaDic.ContainsKey (foundPath)) {
					isFound = true;
					break;
				}
			}

			if (!isFound) {
				throw new LuaException (string.Format (Constants.E1002, path));
			}

			// 转换成真实路径，并查找文件
			string md5;
			_luaDic.TryGetValue (foundPath, out md5);
			string realPath = "Lua/" + foundPath + "_" + md5 + Constants.LuaExtName;

			string filePath = Constants.PackageDir + realPath;
			if (!FileHelper.Exists (filePath))
				filePath = Constants.UpdateDir + realPath;

			_luaPathDic.Add (path, filePath);

			// 返回文件内容
			return FileHelper.GetBytes (filePath);
		}

		#endregion


		//
	}
}

