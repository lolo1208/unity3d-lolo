using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


namespace ShibaInu
{
	

	public class AssetBundleInfo
	{
		public string name;
		public List<string> assetList = new List<string> ();
	}


	public class Packager
	{
		
		public enum LuaEncodeType
		{
			NONE = 0,
			JIT,
			LUAVM,
		}

		public enum UpdateResInfoType
		{
			/// 全部更新
			ALL = 0,
			/// 只更新 lua
			LUA,
			/// 只更新场景
			SCENE,
			/// 只更新资源
			RES,
		}

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
		private const string sceneOutputPath = outputPath + "Scenes/";
		/// 资源信息文件路径
		private const string resInfoFilePath = outputPath + "ResInfo";
		/// 测试模式标识文件路径。文件存在时，表示正处于测试模式
		private const string testModeFlagFilePath = outputPath + "TestModeFlag";

		private const string luaPath_tolua = "Assets/Framework/ToLua/Lua/";
		private const string luaPath_shibaInu = "Assets/Framework/ShibaInu/Lua/";
		private const string luaPath_project = "Assets/Lua/";


		#if UNITY_EDITOR_OSX
		private const string jitPath = "LuaEncoder/luajit_mac/";
		private const string jitExe = "luajit";
		private const string luavmPath = "LuaEncoder/luavm/";
		private const string luavmExe = "luac";
		#else
        private const string jitPath = "LuaEncoder/luajit/";
		private const string jitExe = "luajit.exe";
		private const string luavmPath = "";
		private const string luavmExe = "";
		#endif

		private const string pp_xc = "PlatformProjects/Xcode/";
		private static readonly string[] pp_xc_res = new string[]{ "Data/", "Libraries/", "Classes/Native/" };
		private const string pp_as = "PlatformProjects/AndroidStudio/";
		private static readonly string[] pp_as_res = new string[]{ "src/main/assets/", "src/main/jniLibs/" };
		private const string pp_tp = "PlatformProjects/Temp/";


		private static readonly string[] coreScenes = {
			coreResPath + "Scenes/" + Constants.LauncherSceneName + ".unity",
			coreResPath + "Scenes/" + Constants.EmptySceneName + ".unity"
		};
		private static readonly Dictionary<string, AssetBundleInfo> _abiDic = new Dictionary<string, AssetBundleInfo> ();
		private static readonly List<string> _sceneList = new List<string> ();
		private static readonly List<string> _luaList = new List<string> ();

		private static LuaEncodeType _luaEncodeType;
		private static string _curDirPath;
		private static string _encoderPath;
		private static string _encoderExe;

		private static int _pCurr, _pMax;




		private static void Pack (BuildTarget buildTarget, LuaEncodeType encodeType, bool enterTestMode = false)
		{
			ClearAllRes ();
			Directory.CreateDirectory (outputPath);

			EncodeAllLua (encodeType);
			BuildAllScene (buildTarget);
			BuildAllRes (buildTarget);
			CreateResInfo ();

			if (enterTestMode)
				EnterTestMode ();
			
			Finish ();
			UnityEngine.Debug.Log ("[Packager] All Completed!");
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
			
			switch (encodeType) {
			case LuaEncodeType.JIT:
				_encoderPath = jitPath;
				_encoderExe = _curDirPath + jitPath + jitExe;
				break;
			case LuaEncodeType.LUAVM:
				_encoderPath = luavmPath;
				_encoderExe = _curDirPath + luavmPath + luavmExe;
				break;

			default: // none
				_encoderPath = _curDirPath;
				break;
			}

			EncodeLuaPackage (luaPath_tolua, "ToLua/");
			EncodeLuaPackage (luaPath_shibaInu, "ShibaInu/");
			EncodeLuaPackage (luaPath_project, "App/");
			EditorUtility.ClearProgressBar ();
			UnityEngine.Debug.Log ("[Packager] Encode Lua Files Completed.");
		}


		private static void EncodeLuaPackage (string inRootPath, string outRootPath)
		{
			List<string> files = new List<string> ();
			GetFiles (inRootPath, files);
			_pCurr = 0;
			_pMax = files.Count;
			Directory.SetCurrentDirectory (_encoderPath);
			foreach (string f in files)
				EncodeLuaFile (f, inRootPath, outRootPath);
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
			if (!filePath.EndsWith (".lua") || filePath.IndexOf ("ShibaInu/Lua/Define/") != -1)
				return;
			EditorUtility.DisplayProgressBar ("Encode Lua Files", filePath, (float)++_pCurr / _pMax);
            
			string path = filePath.Replace (inRootPath, "");
			string outPath = _curDirPath + luaOutputPath + outRootPath + path;
			string inPath = _curDirPath + filePath;
			_luaList.Add (luaOutputPath + outRootPath + path);

			string outDirPath = outPath.Substring (0, outPath.LastIndexOf ("/"));
			if (!Directory.Exists (outDirPath))
				Directory.CreateDirectory (outDirPath);

			ProcessStartInfo info;
			switch (_luaEncodeType) {

			case LuaEncodeType.JIT:
				info = new ProcessStartInfo (_encoderExe);
				info.Arguments = "-b " + inPath + " " + outPath;
				break;

			case LuaEncodeType.LUAVM:
				info = new ProcessStartInfo (_encoderExe);
				info.Arguments = "-o " + outPath + " " + inPath;
				break;

			default: // none
				File.Copy (inPath, outPath);
				return;
			}

			info.WindowStyle = ProcessWindowStyle.Hidden;
			using (Process p = Process.Start (info)) {
				p.WaitForExit ();
				if (p.ExitCode != 0)
					throw new Exception (string.Format (Constants.E9001, info.Arguments));
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
			string[] files = Directory.GetFiles (resInputPath + "Scenes");
			List<string> projScenes = new List<string> ();
			foreach (string file in files) {
				if (file.EndsWith (".unity"))
					projScenes.Add (file);
			}

			// 打包项目内场景到 StreamingAssets/Scene/ 目录
			foreach (string scene in projScenes) {
				string[] levels = { scene };
				string outputPath = sceneOutputPath + Path.GetFileName (scene).Replace (".unity", Constants.AbExtName);
				_sceneList.Add (outputPath);
				BuildPipeline.BuildPlayer (levels, outputPath, buildTarget, BuildOptions.BuildAdditionalStreamedScenes);
			}
			UnityEngine.Debug.Log ("[Packager] Build Scenes Completed.");
		}

		#endregion


		#region 打包所有资源

		private static void BuildAllRes (BuildTarget buildTarget)
		{
			ClearAssetBundleNames ();

			if (Directory.Exists (resOutputPath))
				Directory.Delete (resOutputPath, true);
			Directory.CreateDirectory (resOutputPath);

			// 资源类型根目录。忽略这一级目录的资源，不调用 CreateAssetBundleInfo()
			string[] typeDirs = Directory.GetDirectories (resInputPath);
			foreach (string typeDir in typeDirs) {
				string typeDirName = Path.GetFileName (typeDir);

				if (typeDirName == ".svn" || typeDirName == "Excludes" || typeDirName == "Scenes")
					continue;// 忽略这几个文件夹

				// texture 按 spritePackingTag 打包
				// prefab 每个单独打包
				if (typeDirName == "Textures" || typeDirName == "Prefabs") {
					CreateAssetBundleInfo (typeDir, true);
					continue;// 直接递归处理
				}

				// 根目录资源
				CreateAssetBundleInfo (typeDir, false);

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
			foreach (var item in _abiDic) {
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
			UnityEngine.Debug.Log ("[Packager] Build Res Completed.");
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
					string spInputPath = resInputPath + "Textures/";
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


		private static void AddFileToABI (string path, string filePath)
		{
			path = path.Replace ("\\", "/");
			// 根据传入的 文件 或 目录 路径，获取对应的 AssetBundle 名称
			string abPath = path.Replace (resInputPath, "");
			string extName = Path.GetExtension (abPath);
			if (string.IsNullOrEmpty (extName))
				abPath += Constants.AbExtName;
			else
				abPath = abPath.Replace (extName, Constants.AbExtName);
			abPath = abPath.ToLower ();// ab包的路径和名称只能小写

			AssetBundleInfo abi;
			if (_abiDic.ContainsKey (abPath)) {
				// Dictionary 中已存在
				_abiDic.TryGetValue (abPath, out abi);
			} else {
				// 创建 AssetBundleInfo，放入 Dictionary 中
				abi = new AssetBundleInfo ();
				abi.name = abPath;
				_abiDic.Add (abPath, abi);
			}
			abi.assetList.Add (filePath);
		}

		#endregion


		#region 创建资源信息（场景列表 以及 ab包内容和依赖关系）

		private static void CreateResInfo (UpdateResInfoType updateType = UpdateResInfoType.ALL)
		{
			byte[] luaBytes = null, sceneBytes = null, resBytes = null;
			if (updateType != UpdateResInfoType.ALL) {
				if (!File.Exists (resInfoFilePath)) {// ResInfo 文件不存在
					updateType = UpdateResInfoType.ALL;
				} else {
					// 只用更新某部分资源信息，将资源信息分类读取出来
					using (BinaryReader reader = new BinaryReader (File.Open (resInfoFilePath, FileMode.Open))) {
						ushort ushort1, ushort2, i;
						byte byte1, byte2;
						int sceneBytesPos, resBytesPos;

						// - lua bytes
						ushort1 = reader.ReadUInt16 ();
						for (i = 0; i < ushort1; i++) {
							byte2 = reader.ReadByte ();
							reader.BaseStream.Position += byte2 + 16;
						}
						sceneBytesPos = (int)reader.BaseStream.Position;
						reader.BaseStream.Position = 0;
						luaBytes = reader.ReadBytes (sceneBytesPos);

						// - scene bytes
						byte1 = reader.ReadByte ();
						for (i = 0; i < byte1; i++) {
							byte2 = reader.ReadByte ();
							reader.BaseStream.Position += byte2 + 16;
						}
						resBytesPos = (int)reader.BaseStream.Position;
						reader.BaseStream.Position = sceneBytesPos;
						sceneBytes = reader.ReadBytes (resBytesPos - sceneBytesPos);

						// - res bytes
						ushort1 = reader.ReadUInt16 ();
						for (i = 0; i < ushort1; i++) {
							byte2 = reader.ReadByte ();
							reader.BaseStream.Position += byte2 + 16;

							// 包含的资源文件
							ushort2 = reader.ReadUInt16 ();
							reader.BaseStream.Position += ushort2 * 16;

							// 依赖的 AssetBundle
							byte2 = reader.ReadByte ();
							reader.BaseStream.Position += byte2 * 16;
						}
						reader.BaseStream.Position = resBytesPos;
						resBytes = reader.ReadBytes ((int)reader.BaseStream.Length - resBytesPos);
					}
				}
			}

			// 写入资源信息
			using (BinaryWriter writer = new BinaryWriter (File.Open (resInfoFilePath, FileMode.Create))) {

				// - lua
				if (updateType == UpdateResInfoType.ALL || updateType == UpdateResInfoType.LUA) {
					writer.Write ((ushort)_luaList.Count);// 写入lua文件数量
					foreach (string lua in _luaList) {
						RenameFileAndWriteMD5 (lua, luaOutputPath, writer);
					}
				} else {
					writer.Write (luaBytes);
				}


				// - scene
				if (updateType == UpdateResInfoType.ALL || updateType == UpdateResInfoType.SCENE) {
					writer.Write ((byte)_sceneList.Count);// 写入场景文件数量（一字节）
					foreach (string scene in _sceneList) {
						RenameFileAndWriteMD5 (scene, sceneOutputPath, writer);
					}
				} else {
					writer.Write (sceneBytes);
				}

				// - res
				if (updateType == UpdateResInfoType.ALL || updateType == UpdateResInfoType.RES) {
					// 加载 Assets/StreamingAssets/Res/Res 文件，读取包含所有ab包引用关系的 manifest
					AssetBundle ab = AssetBundle.LoadFromFile (resOutputPath + "Res");
					AssetBundleManifest manifest = (AssetBundleManifest)ab.LoadAsset ("AssetBundleManifest");
					string[] abList = manifest.GetAllAssetBundles ();
					writer.Write ((ushort)abList.Length);// 写入ab文件数量

					AssetBundleInfo abi;
					foreach (string abPath in abList) {
						RenameFileAndWriteMD5 (resOutputPath + abPath, resOutputPath, writer);
						_abiDic.TryGetValue (abPath, out abi);

						writer.Write ((ushort)abi.assetList.Count);// 写入包含的资源文件数量
						foreach (string assetPath in abi.assetList) {
							writer.Write (MD5Util.GetMD5 (assetPath.Replace (resInputPath, "")).ToCharArray ());// 写入资源文件的路径MD5
						}

						string[] depList = manifest.GetAllDependencies (abPath);
						writer.Write ((byte)depList.Length);// 写入依赖的ab文件数量（一字节）
						foreach (string depPath in depList) {
							writer.Write (MD5Util.GetMD5 (depPath).ToCharArray ());// 写入ab文件的路径MD5
						}
					}
					ab.Unload (true);
				} else {
					writer.Write (resBytes);
				}
			}

			if (updateType == UpdateResInfoType.ALL)
				UnityEngine.Debug.Log ("[Packager] Generates ResInfo Completed.");
			else
				UnityEngine.Debug.Log ("[Packager] Update ResInfo Completed!");
		}


		/// <summary>
		/// 完成时，需要做些数据清理工作
		/// </summary>
		private static void Finish ()
		{
			_abiDic.Clear ();
			_sceneList.Clear ();
			_luaList.Clear ();
			ClearAssetBundleNames ();
			AssetDatabase.Refresh ();
		}



		/// <summary>
		/// 重命名文件，加入文件MD5字符串。
		/// 写入路径的长度（一字节），写入路径，以及对应的文件MD5。
		/// </summary>
		/// <param name="filePath">File path.</param>
		/// <param name="replacePath">Replace path.</param>
		/// <param name="writer">Writer.</param>
		private static void RenameFileAndWriteMD5 (string filePath, string replacePath, BinaryWriter writer)
		{
			string extName = Path.GetExtension (filePath);
			string fileName = Path.GetFileName (filePath);
			string fileMD5 = MD5Util.GetFileMD5 (filePath);
			string outFileName = fileName.Replace (extName, "") + "_" + fileMD5;
			string outFilePath = Path.GetDirectoryName (filePath) + "/" + outFileName + extName;

			File.Move (filePath, outFilePath);// 重命名文件

			filePath = filePath.Replace (replacePath, "").Replace (extName, "");// 文件路径掐头去尾

			writer.Write ((byte)filePath.Length);// 写入路径的长度（一字节）
			writer.Write (filePath.ToCharArray ());// 写入路径
			writer.Write (fileMD5.ToCharArray ());// 写入文件MD5
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
				if (f.EndsWith (".meta") || f.EndsWith (".DS_Store") || f.EndsWith (".manifest"))
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


		/// <summary>
		/// 拷贝文件夹，以及子文件夹
		/// </summary>
		/// <param name="sourceDir">Source dir.</param>
		/// <param name="destDir">Destination dir.</param>
		private static void CopyDir (string sourceDir, string destDir)
		{
			if (!Directory.Exists (destDir))
				Directory.CreateDirectory (destDir);

			foreach (string file in Directory.GetFiles (sourceDir)) {
				if (file.EndsWith (".DS_Store") || file.EndsWith (".meta") || file.EndsWith (".manifest"))
					continue;
				File.Copy (file, destDir + Path.GetFileName (file));
			}

			foreach (string dir in Directory.GetDirectories (sourceDir)) {
				if (dir.EndsWith (".svn"))
					continue;
				CopyDir (dir + "/", destDir + Path.GetFileName (dir) + "/");
			}
		}



		#region 定义 Packager 菜单项

		[MenuItem ("Packager/Build All (Enter Test Mode)", false, 101)]
		private static void BuildAll ()
		{
			Pack (currentEditorBuildTarget, currentEditorLuaEncodeType, true);
		}

		[MenuItem ("Packager/Re-encode Lua Files", false, 102)]
		private static void ReencodeLua ()
		{
			EncodeAllLua (currentEditorLuaEncodeType);
			CreateResInfo (UpdateResInfoType.LUA);
			Finish ();
		}

		[MenuItem ("Packager/Rebuild Res", false, 103)]
		private static void RebuildRes ()
		{
			BuildAllRes (currentEditorBuildTarget);
			CreateResInfo (UpdateResInfoType.RES);
			Finish ();
		}

		[MenuItem ("Packager/Rebuild Scenes", false, 104)]
		private static void RebuildScene ()
		{
			BuildAllScene (currentEditorBuildTarget);
			CreateResInfo (UpdateResInfoType.SCENE);
			Finish ();
		}

		private static readonly BuildTarget currentEditorBuildTarget =
			Application.platform == RuntimePlatform.OSXEditor
				? BuildTarget.StandaloneOSX
				: BuildTarget.StandaloneWindows64;

		private static readonly LuaEncodeType currentEditorLuaEncodeType =
			Application.platform == RuntimePlatform.OSXEditor
				? LuaEncodeType.LUAVM
				: LuaEncodeType.JIT;


		// ----------------------------------------------------


		[MenuItem ("Packager/iOS", false, 201)]
		private static void PackIOS ()
		{
			Pack (BuildTarget.iOS, LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Android", false, 202)]
		private static void PackAndroid ()
		{
//			Pack (BuildTarget.Android, LuaEncodeType.JIT);
			Pack (BuildTarget.Android, LuaEncodeType.NONE);
		}

		[MenuItem ("Packager/Win", false, 203)]
		private static void PackWin64 ()
		{
			Pack (BuildTarget.StandaloneWindows64, LuaEncodeType.JIT);
		}

		[MenuItem ("Packager/Mac", false, 204)]
		private static void PackMac64 ()
		{
			Pack (BuildTarget.StandaloneOSX, LuaEncodeType.LUAVM);
		}


		// ----------------------------------------------------


		[MenuItem ("Packager/Gen or Upd - Xcode", false, 401)]
		private static void GenOrUpdXcode ()
		{
			PackIOS ();

			// 先导出到 Temp 目录
			if (Directory.Exists (pp_tp))
				Directory.Delete (pp_tp, true);
			BuildPipeline.BuildPlayer (coreScenes, pp_tp, BuildTarget.iOS, BuildOptions.AcceptExternalModificationsToPlayer);

			if (Directory.Exists (pp_xc)) {
				foreach (string dir in pp_xc_res) {
					if (Directory.Exists (pp_xc + dir))
						Directory.Delete (pp_xc + dir, true);
					CopyDir (pp_tp + dir, pp_xc + dir);
				}
				UnityEngine.Debug.Log ("[Packager] Update Xcode Project Complete!");

			} else {
				CopyDir (pp_tp, pp_xc);
				UnityEngine.Debug.Log ("[Packager] Generates Xcode Project Complete!");
			}
		}

		[MenuItem ("Packager/Gen or Upd - Android Studio", false, 402)]
		private static void GenOrUpdAndroidStudio ()
		{
			PackAndroid ();

			// 先导出到 Temp 目录
			if (Directory.Exists (pp_tp))
				Directory.Delete (pp_tp, true);
			BuildPipeline.BuildPlayer (coreScenes, pp_tp.Substring (0, pp_tp.Length - 1), BuildTarget.Android, BuildOptions.AcceptExternalModificationsToPlayer);
			string tempDir = Directory.GetDirectories (pp_tp) [0] + "/";// PlatformProjects/Temp/[ProjectName]/

			if (Directory.Exists (pp_as)) {
				foreach (string dir in pp_as_res) {
					if (Directory.Exists (pp_as + dir))
						Directory.Delete (pp_as + dir, true);
					CopyDir (tempDir + dir, pp_as + dir);
				}
				UnityEngine.Debug.Log ("[Packager] Update Android Studio Project Complete!");

			} else {
				CopyDir (tempDir, pp_as);
				CopyDir ("Templates/AndroidProject/java/", pp_as + "src/main/java/");// 拷贝 java 代码
				UnityEngine.Debug.Log ("[Packager] Generates Android Studio Project Complete!");
			}
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

		// ----------------------------------------------------

		[MenuItem ("Packager/测试资源包模式 - 进入", false, 601)]
		private static void EnterTestMode ()
		{
			File.Create (testModeFlagFilePath);
		}

		[MenuItem ("Packager/测试资源包模式 - 进入", true)]
		private static bool EnterTestModeValidation ()
		{
			return !File.Exists (testModeFlagFilePath);
		}

		[MenuItem ("Packager/测试资源包模式 - 退出", false, 602)]
		private static void ExitTestMode ()
		{
			File.Delete (testModeFlagFilePath);
			if (File.Exists (testModeFlagFilePath + ".meta"))
				File.Delete (testModeFlagFilePath + ".meta");
		}

		[MenuItem ("Packager/测试资源包模式 - 退出", true)]
		private static bool ExitTestModeValidation ()
		{
			return File.Exists (testModeFlagFilePath);
		}

		#endregion


		//
	}
}

