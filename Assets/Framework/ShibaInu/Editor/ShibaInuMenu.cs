using System.IO;
using UnityEngine;
using UnityEditor;
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




        [MenuItem("ShibaInu/Clear Lua Wraps", false, 801)]
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


        //
    }
}
