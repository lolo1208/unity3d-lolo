using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
	
	public enum LuaEncodeType
	{
		NONE = 0,
		JIT,
		LUAC,
	}


	public class Packager
	{
		/// 打包输出根目录
		private const string outputPath = "Assets/StreamingAssets/";
		/// Lua 打包输出根目录
		private const string luaOutputPath = outputPath + "Lua/";

		private const string luaPath_tolua = "Assets/Framework/ToLua/Lua/";
		private const string luaPath_shibaInu = "Assets/Framework/ShibaInu/Lua/";
		private const string luaPath_project = "Assets/Lua/";


		#if UNITY_EDITOR_OSX
		private const string jitexe = "LuaEncoder/luajit_mac/luajit";
		#else
		private const string jitexe = "LuaEncoder/luajit/luajit.exe";
		#endif


		private static LuaEncodeType _luaEncodeType;



		private static void Pack(BuildTarget target, LuaEncodeType encodeType)
		{
			Console.Clear ();

			if (Directory.Exists (outputPath)) {
				Directory.Delete (outputPath, true);
			}
			Directory.CreateDirectory (outputPath);


			EncodeLua (encodeType);
		}


		private static void EncodeLua(LuaEncodeType encodeType)
		{
			if (Directory.Exists (luaOutputPath)) {
				Directory.Delete (luaOutputPath, true);
			}
			Directory.CreateDirectory (luaOutputPath);
			_luaEncodeType = encodeType;

			// encode tolua lua files
			List<string> files = new List<string> ();
//			GetFiles (luaPath_tolua, files);
//			foreach (string f in files)
//				EncodeLuaFile (f, luaPath_tolua, "ToLua/");

			// encode project lua files
			files.Clear();
			GetFiles (luaPath_project, files);
			foreach (string f in files)
				EncodeLuaFile (f, luaPath_project, "App/");

			print ("OK!!!");

			AssetDatabase.Refresh ();
		}


		/// <summary>
		/// 编码 lua 文件
		/// </summary>
		/// <param name="filePath">文件完整路径</param>
		/// <param name="inRootPath">输入根目录</param>
		/// <param name="outRootPath">输出根目录</param>
		private static void EncodeLuaFile(string filePath, string inRootPath, string outRootPath)
		{
			if (!filePath.EndsWith (".lua"))
				return;


			string curDirPath = Directory.GetCurrentDirectory () + "/";
			string path = filePath.Replace (inRootPath, "");
			string outPath = curDirPath + luaOutputPath + outRootPath + path;
			string inPath = curDirPath + filePath;

			switch (_luaEncodeType) {

			case LuaEncodeType.JIT:
				ProcessStartInfo info = new ProcessStartInfo ();
				info.FileName = curDirPath + jitexe;
				info.Arguments = "-b " + inPath + " " + outPath;
				print (info.FileName);
				print (info.Arguments);
//				info.WindowStyle = ProcessWindowStyle.Hidden;
//				info.ErrorDialog = true;
//				info.UseShellExecute = false;

				Process p = Process.Start (info);
				p.WaitForExit ();
				p.Close ();
				print ("??", p.ExitCode.ToString());
				break;
			}
		}




		/// <summary>
		/// 递归获取 目录，以及子目录 下所有文件，存入 files 中
		/// </summary>
		/// <param name="dirPath">Dir path.</param>
		/// <param name="files">Files.</param>
		private static void GetFiles(string dirPath, List<string> files)
		{
			string[] fs = Directory.GetFiles (dirPath);
			foreach (string f in fs) {
				if (f.EndsWith (".meta") || f.EndsWith(".DS_Store"))
					continue;
				files.Add (f.Replace ("\\", "/"));
			}

			string[] dirs = Directory.GetDirectories (dirPath);
			foreach (string dir in dirs) {
				if (dir.EndsWith (".svn"))
					continue;
				GetFiles (dir, files);
			}
		}



		private static void print(params string[] args)
		{
			string msg = string.Empty;
			for (int i = 0; i < args.Length; i++) {
				if (i > 0)
					msg += " ";
				msg += args [i];
			}
			UnityEngine.Debug.Log (msg);
		}



		// ----------------------------------------------------------------------

		[MenuItem("Packager/iOS", false, 101)]
		public static void PackIOS()
		{
			Pack (BuildTarget.iOS, LuaEncodeType.JIT);
		}

		[MenuItem("Packager/Android", false, 102)]
		public static void PackAndroid()
		{
			Pack (BuildTarget.Android, LuaEncodeType.JIT);
		}

		[MenuItem("Packager/Win64", false, 103)]
		public static void PackWin64()
		{
			Pack (BuildTarget.StandaloneWindows64, LuaEncodeType.JIT);
		}

		// ----------------------------------------------------------------------

		[MenuItem("Packager/Encode LuaJIT", false, 201)]
		public static void EncodeLuaJIT()
		{
			EncodeLua (LuaEncodeType.JIT);
		}

		[MenuItem("Packager/Encode LuaC", false, 202)]
		public static void EncodeLuaC()
		{
			EncodeLua (LuaEncodeType.LUAC);
		}

		[MenuItem("Packager/Encode LuaNone", false, 203)]
		public static void EncodeLuaNone()
		{
			EncodeLua (LuaEncodeType.NONE);
		}

		// ----------------------------------------------------------------------


		//
	}
}

