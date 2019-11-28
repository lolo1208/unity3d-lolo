using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;


namespace ShibaInu
{
    /// <summary>
    /// 定义 ShibaInu 框架的所有菜单项
    /// </summary>
    public static class ShibaInuMenu
    {

        [MenuItem("ShibaInu/Run the Application", false, 101)]
        private static void RunTheApplication()
        {
            Scene scene = SceneManager.GetActiveScene();
            GameObject[] list = scene.GetRootGameObjects();
            bool hasMain = false;
            foreach (GameObject go in list)
            {
                hasMain = go.GetComponent<Main>() != null;
                if (hasMain)
                {
                    go.SetActive(true);
                    break;
                }
            }

            if (!hasMain)
                new GameObject("Main").AddComponent<Main>();

            EditorApplication.ExecuteMenuItem("Edit/Play");
        }

        [MenuItem("ShibaInu/Run the Application", true)]
        private static bool RunTheApplicationValidation()
        {
            return !Application.isPlaying;
        }




        [MenuItem("ShibaInu/Language Window", false, 701)]
        private static void OpenLanguageWindow()
        {
            LanguageWindow.Open();
        }


        [MenuItem("ShibaInu/Log Window", false, 702)]
        private static void OpenLogWindow()
        {
            LogWindow.Open();
        }


        [MenuItem("ShibaInu/Gpu Animation Window", false, 702)]
        private static void OpenGpuAnimationWindow()
        {
            GpuAnimationWindow.Open();
        }


        [MenuItem("ShibaInu/Lua Profiler", false, 703)]
        private static void ShowLuaProfilerConsole()
        {
            LuaProfiler.Console(true);
        }

        [MenuItem("ShibaInu/Lua Profiler", true)]
        private static bool ShowLuaProfilerConsoleValidation()
        {
            return Application.isPlaying;
        }




        [MenuItem("ShibaInu/Clear & Gen Lua Wraps", false, 801)]
        private static void ClearLuaWraps()
        {
            ToLuaMenu.ClearLuaWraps();
        }


        [MenuItem("ShibaInu/Generate Lua API", false, 801)]
        private static void GenerateLuaAPI()
        {
            Emmy.ToLuaEmmyAPIGenerator.DoIt();
        }




        [MenuItem("ShibaInu/进入 AssetBundle 模式", false, 901)]
        private static void EnterABMode()
        {
            File.Create(Constants.ABModeFilePath);
        }

        [MenuItem("ShibaInu/进入 AssetBundle 模式", true)]
        private static bool EnterABModeValidation()
        {
            return !File.Exists(Constants.ABModeFilePath);
        }

        [MenuItem("ShibaInu/退出 AssetBundle 模式", false, 902)]
        private static void ExitABMode()
        {
            File.Delete(Constants.ABModeFilePath);
            if (File.Exists(Constants.ABModeFilePath + ".meta"))
                File.Delete(Constants.ABModeFilePath + ".meta");
        }

        [MenuItem("ShibaInu/退出 AssetBundle 模式", true)]
        private static bool ExitABModeValidation()
        {
            return File.Exists(Constants.ABModeFilePath);
        }




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
