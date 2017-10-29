using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


namespace ShibaInu
{
	
	public enum LuaEncodeType
	{
		NONE = 0,
		JIT,
		LUAC,
	}


	public class AssetBundleInfo
	{
		public string name;
		public List<string> assetList = new List<string> ();
		public string[] depList;
	}


	public class Packager
	{
		/// AssetBundle 后缀名
		private const string abExtName = ".unity3d";

		/// 资源文件输入根目录
		private const string resInputPath = "Assets/Res/";
		/// 框架内资源目录
		private const string coreResPath = "Assets/Framework/ShibaInu/Res/";

		/// 打包输出根目录
		private const string outputPath = "Assets/StreamingAssets/";
		/// lua 文件输出根目录
		private const string luaOutputPath = outputPath + "Lua/";
		/// 资源输出根目录
		private const string resOutputPath = outputPath + "Res/";
		/// 场景输出根目录
		private const string sceneOutputPath = outputPath + "Scene/";
        /// 资源信息文件路径
        private const string resInfoFilePath = outputPath + "ResInfo";

        private const string luaPath_tolua = "Assets/Framework/ToLua/Lua/";
		private const string luaPath_shibaInu = "Assets/Framework/ShibaInu/Lua/";
		private const string luaPath_project = "Assets/Lua/";


		#if UNITY_EDITOR_OSX
		private const string jitPath = "LuaEncoder/luajit_mac/";
		private const string jitExe = "luajit";
		private const string luacPath = "LuaEncoder/luavm/";
		private const string luacExe = "luac";
		#else
        private const string jitPath = "LuaEncoder/luajit/";
		private const string jitExe = "luajit.exe";
		private const string luacPath = "";
		private const string luacExe = "";
		#endif


		private static string[] coreScenes = {
			coreResPath + "Scene/Launcher.unity",
			coreResPath + "Scene/Scene1.unity",
			coreResPath + "Scene/Scene2.unity"
		};

		private static LuaEncodeType _luaEncodeType;
		private static string _curDirPath;
		private static string _encoderExe;
		private static Dictionary<string, AssetBundleInfo> _abiMap = new Dictionary<string, AssetBundleInfo> ();
		private static List<string> _sceneList = new List<string> ();



		private static void Pack (BuildTarget buildTarget, LuaEncodeType encodeType)
		{
			ClearAllRes ();
			Directory.CreateDirectory (outputPath);
			ClearAssetBundleNames ();
			_abiMap.Clear ();
			_sceneList.Clear ();

//			EncodeAllLua (encodeType);
			BuildAllScene (buildTarget);
//			BuildAllRes (buildTarget);
			CreateResInfo ();
		}



		#region 编码所有 lua 文件

		private static void EncodeAllLua (LuaEncodeType encodeType)
		{
			if (Directory.Exists (luaOutputPath))
				Directory.Delete (luaOutputPath, true);
			Directory.CreateDirectory (luaOutputPath);

			_luaEncodeType = encodeType;
			if (_curDirPath == null)
				_curDirPath = Directory.GetCurrentDirectory () + "/";
			
			string encoderPath;
			switch (encodeType) {
			case LuaEncodeType.JIT:
				encoderPath = jitPath;
				_encoderExe = _curDirPath + jitPath + jitExe;
				break;
			case LuaEncodeType.LUAC:
				encoderPath = luacPath;
				_encoderExe = _curDirPath + luacPath + luacExe;
				break;

			default: // none
				encoderPath = _curDirPath;
				break;
			}


			// encode tolua lua files
			List<string> files = new List<string> ();
			GetFiles (luaPath_tolua, files);
			Directory.SetCurrentDirectory (encoderPath);
			foreach (string f in files)
				EncodeLuaFile (f, luaPath_tolua, "ToLua/");
			Directory.SetCurrentDirectory (_curDirPath);
			
			// encode shibaInu lua files
			files.Clear ();
			GetFiles (luaPath_shibaInu, files);
			Directory.SetCurrentDirectory (encoderPath);
			foreach (string f in files)
				EncodeLuaFile (f, luaPath_shibaInu, "ShibaInu/");
			Directory.SetCurrentDirectory (_curDirPath);
			
			// encode project lua files
			files.Clear ();
			GetFiles (luaPath_project, files);
			Directory.SetCurrentDirectory (encoderPath);
			foreach (string f in files)
				EncodeLuaFile (f, luaPath_project, "App/");
			Directory.SetCurrentDirectory (_curDirPath);
		}


		/// <summary>
		/// 编码单个 lua 文件
		/// </summary>
		/// <param name="filePath">文件完整路径</param>
		/// <param name="inRootPath">输入根目录</param>
		/// <param name="outRootPath">输出根目录</param>
		private static void EncodeLuaFile (string filePath, string inRootPath, string outRootPath)
		{
			if (!filePath.EndsWith (".lua") || filePath.EndsWith ("Core/define.lua"))
				return;
            
			string path = filePath.Replace (inRootPath, "");
			string outPath = _curDirPath + luaOutputPath + outRootPath + path;
			string inPath = _curDirPath + filePath;

			string outDirPath = outPath.Substring (0, outPath.LastIndexOf ("/"));
			if (!Directory.Exists (outDirPath))
				Directory.CreateDirectory (outDirPath);

			ProcessStartInfo info;
			switch (_luaEncodeType) {

			case LuaEncodeType.JIT:
				info = new ProcessStartInfo (_encoderExe);
				info.Arguments = "-b " + inPath + " " + outPath;
				break;

			case LuaEncodeType.LUAC:
				info = new ProcessStartInfo (_encoderExe);
				info.Arguments = "-o " + outPath + " " + inPath;
				break;

			default: // none
				File.Copy (inPath, outPath);
				return;
			}

//			info.WindowStyle = ProcessWindowStyle.Hidden;
			using (Process p = Process.Start (info)) {
				p.WaitForExit ();
				if (p.ExitCode != 0)
					throw new Exception ("编码 lua 出现错误：" + info.Arguments);
			}
		}

		#endregion


		#region 打包场景

		private static void BuildAllScene (BuildTarget buildTarget)
		{
			if (Directory.Exists (sceneOutputPath))
				Directory.Delete (sceneOutputPath, true);
			Directory.CreateDirectory (sceneOutputPath);

			// 项目内的场景列表
			string[] files = Directory.GetFiles (resInputPath + "Scene");
			List<string> projScenes = new List<string> ();
			foreach (string file in files) {
				if (file.EndsWith (".unity"))
					projScenes.Add (file);
			}

			// 打包项目内场景到 StreamingAssets/Scene/ 目录
			foreach (string scene in projScenes) {
				string[] levels = { scene };
				string outputPath = sceneOutputPath + Path.GetFileName (scene).Replace (".unity", abExtName);
				_sceneList.Add (outputPath);
				BuildPipeline.BuildPlayer (levels, outputPath, buildTarget, BuildOptions.BuildAdditionalStreamedScenes);
			}
		}

		#endregion


		#region 打包所有资源

		private static void BuildAllRes (BuildTarget buildTarget)
		{
			// 资源类型根目录。忽略这一级目录的资源，不调用 CreateAssetBundleInfo()
			string[] typeDirs = Directory.GetDirectories (resInputPath);
			foreach (string typeDir in typeDirs) {
				string typeDirName = Path.GetFileName (typeDir);

				if (typeDirName == ".svn" || typeDirName == "Exclude" || typeDirName == "Scene")
					continue;// 忽略这几个文件夹

				if (typeDirName == "Texture" || typeDirName == "Prefab" || typeDirName == "Shader") {
					CreateAssetBundleInfo (typeDir, true);
					continue;// 直接递归处理 sprite, prefab, shader（所有shader打在一个ab包里）
				}

				// 子目录（按模块划分的根目录）
				string[] childDirs = Directory.GetDirectories (typeDir);
				foreach (string childDir in childDirs) {
					if (childDir.EndsWith (".svn"))
						continue;
					CreateAssetBundleInfo (childDir, false);

					// 最多到第二级目录，后面的资源递归查找
					string[] secondLevelDirs = Directory.GetDirectories (childDir);
					foreach (string secondLevelDir in secondLevelDirs) {
						if (secondLevelDir.EndsWith (".svn"))
							continue;
						CreateAssetBundleInfo (secondLevelDir, true);
					}
				}
			}

			// 建立 AssetBundleBuild 列表
			List<AssetBundleBuild> abbList = new List<AssetBundleBuild> ();
			foreach (var item in _abiMap) {
				var abi = item.Value;
				AssetBundleBuild abb = new AssetBundleBuild ();
				abb.assetBundleName = abi.name;
				abb.assetNames = abi.assetList.ToArray ();
				abbList.Add (abb);
			}

			// 将所有资源打包成 AssetBundle
			Directory.CreateDirectory (resOutputPath);
			BuildPipeline.BuildAssetBundles (resOutputPath, abbList.ToArray (),
				BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression,
				buildTarget
			);
		}


		private static void CreateAssetBundleInfo (string dirPath, bool recursive)
		{
			List<string> files = new List<string> ();
			GetFiles (dirPath, files, recursive);
			foreach (string filePath in files) {

				// 每个预设都单独打成一个ab包
				if (Path.GetExtension (filePath) == ".prefab") {
					AddFileToABI (filePath, filePath);
					continue;
				}

				// 纹理按 spritePackingTag 来打ab包
				AssetImporter importer = AssetImporter.GetAtPath (filePath);
				if (importer is TextureImporter) {
					string spTag = (importer as TextureImporter).spritePackingTag;
					string spInputPath = resInputPath + "Texture/";
					if (spTag == "#") { // spritePackingTag = # 的图片单独打包
						spTag = filePath.Replace (spInputPath, "");
						spTag = spTag.Replace ("/", "_");
					}
					AddFileToABI (spInputPath + spTag, filePath);
					continue;
				}

				// 按文件夹来打ab包
				AddFileToABI (dirPath, filePath);
			}
		}


		public static void AddFileToABI (string path, string filePath)
		{
			// 根据传入的 文件 或 目录 路径，获取对应的 AssetBundle 名称
			string abPath = path.Replace (resInputPath, "");
			string extName = Path.GetExtension (abPath);
			if (string.IsNullOrEmpty (extName))
				abPath += abExtName;
			else
				abPath = abPath.Replace (extName, abExtName);
			abPath = abPath.ToLower ();// ab包的路径和名称只能小写

			AssetBundleInfo abi;
			if (_abiMap.ContainsKey (abPath)) {
				// Dictionary 中已存在
				_abiMap.TryGetValue (abPath, out abi);
			} else {
				// 创建 AssetBundleInfo，放入 Dictionary 中
				abi = new AssetBundleInfo ();
				abi.name = abPath;
				_abiMap.Add (abPath, abi);
			}
			abi.assetList.Add (filePath);
		}

		#endregion


		#region 创建资源信息（场景列表 以及 ab包内容和依赖关系）

		private static void CreateResInfo ()
		{
            using (BinaryWriter writer = new BinaryWriter(File.Open(resInfoFilePath, FileMode.Create)))
            {
                writer.Write((ushort)_sceneList.Count);
                foreach (string scene in _sceneList)
                {
                    writer.Write(AppendMD5ToFileName(scene, sceneOutputPath));
                }
            }


			/*
			// 加载 Assets/StreamingAssets/Res/Res 文件，读取包含所有ab包引用关系的 manifest
			AssetBundle ab = AssetBundle.LoadFromFile (resOutputPath + "Res");
			AssetBundleManifest manifest = (AssetBundleManifest)ab.LoadAsset ("AssetBundleManifest");
			string[] abs = manifest.GetAllAssetBundles ();
			AssetBundleInfo abi;

			foreach (string abPath in abs) {
				_abiMap.TryGetValue (abPath, out abi);
				abi.depList = manifest.GetAllDependencies (abPath);
				print (JsonUtility.ToJson (abi));
			}

			ab.Unload (true);
			*/
		}


		private static string AppendMD5ToFileName(string filePath, string replacePath)
		{
			if (!filePath.StartsWith (outputPath))
				filePath = outputPath + filePath;

			string fileName = Path.GetFileName (filePath);
			string fileMD5 = MD5Util.GetFileMD5 (filePath);
			string outFileName = fileName.Replace (abExtName, "") + "_" + fileMD5;
			string outFilePath = Path.GetDirectoryName (filePath) + "/" + outFileName;

			File.Move (filePath, outFilePath + abExtName);
			return outFilePath.Replace(replacePath, "");
		}


		#endregion





		/// <summary>
		/// 获取 目录，以及子目录 下所有文件，存入 files 中
		/// </summary>
		/// <param name="dirPath">Dir path.</param>
		/// <param name="files">Files.</param>
		/// <param name="recursive">If set to <c>true</c> recursive.</param>
		private static void GetFiles (string dirPath, List<string> files, bool recursive = true)
		{
			string[] fs = Directory.GetFiles (dirPath);
			foreach (string f in fs) {
				if (f.EndsWith (".meta") || f.EndsWith (".DS_Store"))
					continue;
				files.Add (f.Replace ("\\", "/"));
			}

			if (recursive) {
				string[] dirs = Directory.GetDirectories (dirPath);
				foreach (string dir in dirs) {
					if (dir.EndsWith (".svn"))
						continue;
					GetFiles (dir, files);
				}
			}
		}



		private static void print (params string[] args)
		{
			string msg = string.Empty;
			for (int i = 0; i < args.Length; i++) {
				if (i > 0)
					msg += " ";
				msg += args [i];
			}
			UnityEngine.Debug.Log (msg);
		}



		#region 定义 Packager 菜单项

		[MenuItem ("Packager/iOS", false, 101)]
		private static void PackIOS ()
		{
			Pack (BuildTarget.iOS, LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Android", false, 102)]
		private static void PackAndroid ()
		{
			Pack (BuildTarget.Android, LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Win x64", false, 103)]
		private static void PackWin64 ()
		{
			Pack (BuildTarget.StandaloneWindows64, LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Mac x64", false, 104)]
		private static void PackMac64 ()
		{
			Pack (BuildTarget.StandaloneOSXIntel64, LuaEncodeType.JIT);
		}

		// ----------------------------------------------------

		[MenuItem ("Packager/Encode LuaJIT", false, 201)]
		private static void EncodeLuaJIT ()
		{
			EncodeAllLua (LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Encode LuaC", false, 202)]
		private static void EncodeLuaC ()
		{
			EncodeAllLua (LuaEncodeType.LUAC);
		}

		[MenuItem ("Packager/Encode LuaC", true)]
		private static bool EncodeLuaCValidation ()
		{
			return Application.platform == RuntimePlatform.OSXEditor;
		}

		[MenuItem ("Packager/Encode LuaNone", false, 203)]
		private static void EncodeLuaNone ()
		{
			EncodeAllLua (LuaEncodeType.NONE);
		}

		// ----------------------------------------------------

		[MenuItem ("Packager/Build Scene - iOS", false, 301)]
		private static void BuildSceneIOS ()
		{
			BuildAllScene (BuildTarget.iOS);
		}

		[MenuItem ("Packager/Build Scene - Android", false, 302)]
		private static void BuildSceneAndroid ()
		{
			BuildAllScene (BuildTarget.Android);
		}

		// ----------------------------------------------------

		[MenuItem ("Packager/Build Player - iOS", false, 401)]
		private static void BuildPlayerIOS ()
		{
			string path = "runtime-src/proj.ios";
			if (Directory.Exists (path))
				Directory.Delete (path);
			BuildPipeline.BuildPlayer (coreScenes, path, BuildTarget.iOS, BuildOptions.None);
		}

		[MenuItem ("Packager/Build Player - Android", false, 402)]
		private static void BuildPlayerAndroid ()
		{
			string path = "publish/Android/buildPlayer.apk";
			if (File.Exists (path))
				File.Delete (path);
			BuildPipeline.BuildPlayer (coreScenes, path, BuildTarget.Android, BuildOptions.None);
		}

		// ----------------------------------------------------

		[MenuItem ("Packager/Clear Asset Bundle Names", false, 501)]
		private static void ClearAssetBundleNames ()
		{
			string[] names = AssetDatabase.GetAllAssetBundleNames ();
			foreach (string name in names) {
				AssetDatabase.RemoveAssetBundleName (name, true);
			}
		}

		[MenuItem ("Packager/Clear All Res", false, 502)]
		private static void ClearAllRes ()
		{
			if (Directory.Exists (outputPath))
				Directory.Delete (outputPath, true);
		}


		[MenuItem ("Packager/test", false, 999)]
		private static void Test ()
		{
			print (MD5Util.GetMD5 ("sss"));
			print (MD5Util.GetMD5 ("sss", false));
		}

		#endregion


		//
	}
}

