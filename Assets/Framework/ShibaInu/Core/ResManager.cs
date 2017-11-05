using System;
using System.IO;
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
		private static readonly string[] luaPackages = { "ToLua/", "ShibaInu/", "App/" };

		/// 路径 -> 路径MD5 映射列表
		private static readonly Dictionary<string, string> _pathMD5Dic = new Dictionary<string, string> ();
		/// lua文件路径 -> 真实完整路径 映射列表
		private static readonly Dictionary<string, string> _luaPathDic = new Dictionary<string, string> ();

		/// lua 文件列表[ key = lua文件路径，value = 文件MD5 ]
		private static readonly Dictionary<string, string> _luaDic = new Dictionary<string, string> ();
		/// ABI 列表[ key = AB文件路径MD5，value = ABI对象 ]
		private static readonly Dictionary<string, ABI> _abiDic = new Dictionary<string, ABI> ();
		/// 资源文件列表[ key = 资源（或场景）文件路径MD5，value = ABI对象 ]
		private static readonly Dictionary<string, ABI> _resDic = new Dictionary<string, ABI> ();



		#region 初始化

		public static void Initialize ()
		{
			if (Common.isDebug) {
			} else {
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
					path = new string (reader.ReadChars (pathLen));// "Loading" or "Dir/SceneFileName"
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



		public static UnityEngine.Object GetAsset (string path)
		{
			string pathMD5 = GetPathMD5 (path);
			if (!_resDic.ContainsKey (pathMD5)) {
				throw new LuaException (string.Format (Constants.E1001, path));
			}

			ABI abi;
			_resDic.TryGetValue (pathMD5, out abi);

			ABLoader.Load (abi);

			return abi.ab.LoadAsset (path);
		}



		public static ABI GetABI (string abPathMD5)
		{
			if (!_abiDic.ContainsKey (abPathMD5)) {
				throw new LuaException (string.Format (Constants.E1002, abPathMD5));
			}

			ABI abi;
			_abiDic.TryGetValue (abPathMD5, out abi);
			if (abi == null) {
				throw new LuaException (string.Format (Constants.E1002, abPathMD5));
			}

			return abi;
		}



		/// <summary>
		/// 获取 Lua 文件的字节内容
		/// </summary>
		/// <returns>The lua file bytes.</returns>
		/// <param name="path">lua 路径，如：Module/Core/launcher </param>
		public static byte[] GetLuaFileBytes (string path)
		{
			path = path.Replace (".lua", "");
			if (_luaPathDic.ContainsKey (path)) {
				_luaPathDic.TryGetValue (path, out path);
				return FileHelper.GetBytes (path);
			}

			bool isFound = false;
			string foundPath = string.Empty;
			for (int i = 0; i < luaPackages.Length; i++) {
				foundPath = luaPackages [i] + path;
				if (_luaDic.ContainsKey (foundPath)) {
					isFound = true;
					break;
				}
			}

			if (!isFound) {
				throw new LuaException (string.Format (Constants.E1003, path));
			}

			string md5;
			_luaDic.TryGetValue (foundPath, out md5);
			string realPath = "Lua/" + foundPath + "_" + md5 + Constants.LuaExtName;

			string filePath = Constants.PackageDir + realPath;
			if (!FileHelper.Exists (filePath))
				filePath = Constants.UpdateDir + realPath;

			_luaPathDic.Add (path, filePath);

			return FileHelper.GetBytes (filePath);
		}






		/// <summary>
		/// 获取路径对应的 MD5
		/// </summary>
		/// <returns>The path MD5.</returns>
		/// <param name="path">Path.</param>
		private static string GetPathMD5 (string path)
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

		//
	}
}

