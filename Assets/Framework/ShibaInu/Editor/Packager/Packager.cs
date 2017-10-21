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
		private const string jitPath = "LuaEncoder/luajit_mac";
		private const string jitExe = "luajit";
#else
        private const string jitPath = "LuaEncoder/luajit/";
        private const string jitExe = "luajit.exe";
#endif


        private static LuaEncodeType _luaEncodeType;
        private static string _curDirPath;



		private static void Pack(BuildTarget target, LuaEncodeType encodeType)
		{
            ClearConsole();

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

            if (_curDirPath == null)
                _curDirPath = Directory.GetCurrentDirectory() + "/";


			// encode tolua lua files
			List<string> files = new List<string> ();
            GetFiles (luaPath_tolua, files);
            Directory.SetCurrentDirectory(jitPath);
            foreach (string f in files)
            	EncodeLuaFile (f, luaPath_tolua, "ToLua/");


            // encode shibaInu lua files
            Directory.SetCurrentDirectory(_curDirPath);
            files.Clear();
            GetFiles(luaPath_shibaInu, files);
            Directory.SetCurrentDirectory(jitPath);
            foreach (string f in files)
                EncodeLuaFile(f, luaPath_shibaInu, "ShibaInu/");


            // encode project lua files
            Directory.SetCurrentDirectory(_curDirPath);
            files.Clear();
            GetFiles (luaPath_project, files);
            Directory.SetCurrentDirectory(jitPath);
            foreach (string f in files)
				EncodeLuaFile (f, luaPath_project, "App/");

            Directory.SetCurrentDirectory(_curDirPath);
			AssetDatabase.Refresh ();
            print("ok!!!");
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
            
			string path = filePath.Replace (inRootPath, "");
			string outPath = _curDirPath + luaOutputPath + outRootPath + path;
			string inPath = _curDirPath + filePath;

            string outDirPath = outPath.Substring(0, outPath.LastIndexOf("/"));
            if (!Directory.Exists(outDirPath))
                Directory.CreateDirectory(outDirPath);

            switch (_luaEncodeType) {

                case LuaEncodeType.JIT:
                    ProcessStartInfo info = new ProcessStartInfo();
                    info.FileName = _curDirPath + jitPath + jitExe;
                    info.Arguments = "-b " + inPath + " " + outPath;
                    info.WindowStyle = ProcessWindowStyle.Hidden;
                    info.ErrorDialog = true;
                    //info.UseShellExecute = false;

                    using (Process p = Process.Start(info))
                        p.WaitForExit();
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



        private static void ClearConsole()
        {
            try
            {
                Type logEntries = Type.GetType("UnityEditorInternal.LogEntries,UnityEditor.dll");
                System.Reflection.MethodInfo clearMethod = logEntries.GetMethod("Clear", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public);
                clearMethod.Invoke(null, null);
            }
            catch { }
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

		[MenuItem("Packager/Win x64", false, 103)]
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

