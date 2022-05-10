using System;
using System.Reflection;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using USceneMgr = UnityEngine.SceneManagement.SceneManager;


namespace ShibaInu
{
    /// <summary>
    /// 定义 ShibaInu 框架的所有菜单项
    /// </summary>
    public static class ShibaInuMenu
    {

        // ----

        [MenuItem("ShibaInu/Run the Application", false, 101)]
        private static void RunTheApplication()
        {
            Scene scene = USceneMgr.GetActiveScene();
            GameObject[] list = scene.GetRootGameObjects();
            bool hasMain = false;
            foreach (GameObject go in list)
            {
                hasMain = go.GetComponent<Main>() != null;
                if (hasMain)
                {
                    if (!go.activeSelf)
                    {
                        go.SetActive(true);
                        BaseEditor.MarkSceneDirty();
                    }
                    break;
                }
            }

            if (!hasMain)
            {
                new GameObject("Main").AddComponent<Main>();
                BaseEditor.MarkSceneDirty();
            }

            EditorApplication.ExecuteMenuItem("Edit/Play");
        }

        [MenuItem("ShibaInu/Run the Application", true)]
        private static bool RunTheApplicationValidation()
        {
            return !Application.isPlaying;
        }


        [MenuItem("ShibaInu/Add All the Scenes to BuildSettings", false, 102)]
        private static void AddAllScenes()
        {
            string[] files = Directory.GetFiles("Assets/Res/Scenes/", "*.unity");
            List<EditorBuildSettingsScene> scenes = new List<EditorBuildSettingsScene>();
            foreach (string path in files)
                scenes.Add(new EditorBuildSettingsScene(path, true));
            EditorBuildSettings.scenes = scenes.ToArray();
            Debug.Log("已将 Assets/Res/Scenes/ 目录（不含子目录）下的所有场景添加至 BuildSettings");
        }



        // ----

        [MenuItem("ShibaInu/Language Window", false, 201)]
        private static void OpenLanguageWindow()
        {
            LanguageWindow.Open();
        }


        [MenuItem("ShibaInu/Gpu Animation Window", false, 202)]
        private static void OpenGpuAnimationWindow()
        {
            GpuAnimationWindow.Open();
        }


        [MenuItem("ShibaInu/Log Window", false, 203)]
        private static void OpenLogWindow()
        {
            LogWindow.Open();
        }



        // ----

        [MenuItem("ShibaInu/Generate Lua Wraps", false, 301)]
        private static void ClearLuaWraps()
        {
            ToLuaMenu.ClearLuaWraps();
        }


        [MenuItem("ShibaInu/Generate Lua API", false, 302)]
        private static void GenerateLuaAPI()
        {
            Emmy.ToLuaEmmyAPIGenerator.DoIt();
        }



        // ----

        [MenuItem("ShibaInu/Clear All AssetBundle Names", false, 401)]
        public static void ClearAllAssetBundleNames()
        {
            string[] names = AssetDatabase.GetAllAssetBundleNames();
            foreach (string name in names)
                AssetDatabase.RemoveAssetBundleName(name, true);

            AssetDatabase.RemoveUnusedAssetBundleNames();

            Debug.Log("Clear All AssetBundle Names Complete!");
        }


        [MenuItem("ShibaInu/Clear Console", false, 402)]
        public static void ClearConsole()
        {
            Assembly assembly = Assembly.GetAssembly(typeof(Editor));
            MethodInfo methodInfo = assembly.GetType("UnityEditor.LogEntries").GetMethod("Clear");
            methodInfo.Invoke(new object(), null);
        }


        [MenuItem("ShibaInu/Lua Profiler", false, 403)]
        private static void ShowLuaProfilerConsole()
        {
            LuaProfiler.Console(true);
        }

        [MenuItem("ShibaInu/Lua Profiler", true)]
        private static bool ShowLuaProfilerConsoleValidation()
        {
            return Application.isPlaying;
        }



        // ----

        [MenuItem("ShibaInu/Into AssetBundle Mode", false, 501)]
        private static void EnterABMode()
        {
            File.Create(Constants.ABModeFilePath);
        }

        [MenuItem("ShibaInu/Into AssetBundle Mode", true)]
        private static bool EnterABModeValidation()
        {
            return !File.Exists(Constants.ABModeFilePath);
        }
        

        [MenuItem("ShibaInu/Out AssetBundle Mode", false, 502)]
        private static void ExitABMode()
        {
            File.Delete(Constants.ABModeFilePath);
            if (File.Exists(Constants.ABModeFilePath + ".meta"))
                File.Delete(Constants.ABModeFilePath + ".meta");
        }

        [MenuItem("ShibaInu/Out AssetBundle Mode", true)]
        private static bool ExitABModeValidation()
        {
            return File.Exists(Constants.ABModeFilePath);
        }



        // ---- Assets ----

        #region Re-import Assets With Default Setting

        [MenuItem("Assets/Reimport With Default Setting", false, 40)]
        private static void ReimportAsset()
        {
            string assetPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (Directory.Exists(assetPath))
                ReimportAssetDir(assetPath);
            else
                ReimportAssetFile(assetPath);
        }

        private static void ReimportAssetDir(string dirPath)
        {
            DirectoryInfo info = new DirectoryInfo(dirPath);

            FileInfo[] files = info.GetFiles();
            foreach (FileInfo fi in files)
                ReimportAssetFile(fi.FullName);

            DirectoryInfo[] dirs = info.GetDirectories();
            foreach (DirectoryInfo di in dirs)
                ReimportAssetDir(di.FullName);
        }

        private static void ReimportAssetFile(string path)
        {
            path = path.Replace(Directory.GetCurrentDirectory(), "");
            if (path.StartsWith("/", StringComparison.Ordinal) || path.StartsWith("\\", StringComparison.Ordinal))
                path = path.Substring(1);
            AssetImporter importer = AssetImporter.GetAtPath(path);
            if (importer != null)
            {
                importer.userData = "";
                importer.SaveAndReimport();
            }
        }

        #endregion


        //
    }
}
