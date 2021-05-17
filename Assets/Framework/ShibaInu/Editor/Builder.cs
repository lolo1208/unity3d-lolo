using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// Asset bundle info.
    /// </summary>
    public class AssetBundleInfo
    {
        /// AssetBundle 文件别名
        public string name;
        /// 包含的资源列表
        public List<string> assets = new List<string>();
    }



    public static class Builder
    {

        /// 资源根目录
        private const string ResDir = "Assets/Res/";
        /// AssetBundle 文件后缀
        private const string ABExtName = ".ab";

        /// 打包规则文件路径
        private static readonly string RulesFilePath = ResDir + "BuildRules.txt";

        /// 核心场景列表
        private static readonly string[] CoreScenes = {
            ResDir + "Scenes/" + Constants.EmptySceneName + ".unity"
        };

        /// Lua 文件根目录
        private static readonly string[] LuaDirs = {
            "Assets/Framework/ShibaInu/Lua/",
            "Assets/Framework/ToLua/Lua/",
            "Assets/Lua/"
        };


        /// 需要打包的 AssetBundle 信息列表
        private static readonly List<AssetBundleInfo> s_abiList = new List<AssetBundleInfo>();
        /// abi 映射，路径（资源目录路径，不是 ab 文件路径）为 key
        private static readonly Dictionary<string, AssetBundleInfo> s_abiMap = new Dictionary<string, AssetBundleInfo>();

        /// 打包规则 - 需要被忽略的目录列表
        private static readonly HashSet<string> s_ignoreRules = new HashSet<string>();
        /// 打包规则 - 子目录需要被合并打包的目录列表
        private static readonly HashSet<string> s_combineRules = new HashSet<string>();
        /// 打包规则 - 所有文件需要被单独打包的目录列表
        private static readonly HashSet<string> s_singleRules = new HashSet<string>();

        /// 打包规则 - 需要被忽略的后缀名列表
        private static readonly HashSet<string> s_ignoreExtNames = new HashSet<string>();
        /// 打包规则 - 需要被合并的后缀名列表
        private static readonly HashSet<string> s_combineExtNames = new HashSet<string>();
        /// 打包规则 - 需要单独打包的后缀名列表
        private static readonly HashSet<string> s_singleExtNames = new HashSet<string>();




        /// <summary>
        /// 生成需要 build 的文件清单
        /// </summary>
        private static void GenerateBuildManifest()
        {
            string manifestPath = GetCmdLineArg("-manifestPath");
            //string manifestPath = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/log/0/manifest.log";

            ShibaInuMenu.ClearAllAssetBundleNames();

            s_abiList.Clear();
            s_abiMap.Clear();
            s_ignoreRules.Clear();
            s_combineRules.Clear();
            s_singleRules.Clear();
            s_ignoreExtNames.Clear();
            s_combineExtNames.Clear();
            s_singleExtNames.Clear();

            ParseBuildRules();


            // lua 列表
            List<string> luaList = new List<string>();
            foreach (string luaDir in LuaDirs)
                AppendLuaFiles(luaDir, luaList);

            // 场景列表
            List<string> sceneList = new List<string>();

            // 解析项目资源目录结构
            string[] typeDirs = Directory.GetDirectories(ResDir);
            foreach (string typeDir in typeDirs)
            {
                if (typeDir.EndsWith(".svn", StringComparison.Ordinal))
                    continue;

                // 场景资源
                if (Path.GetFileName(typeDir) == "Scenes")
                {
                    string[] files = Directory.GetFiles(typeDir);
                    foreach (string file in files)
                    {
                        if (file.EndsWith(".unity", StringComparison.Ordinal))
                        {
                            string scenePath = file.Replace("\\", "/");
                            bool isCoreScene = false;// 是否属于核心场景
                            foreach (string coreScene in CoreScenes)
                            {
                                if (scenePath == coreScene)
                                {
                                    isCoreScene = true;
                                    break;
                                }
                            }
                            if (!isCoreScene) sceneList.Add(scenePath);
                        }
                    }
                }
                else
                {
                    ParseResDir(typeDir);
                }
            }


            // 写入打包清单文件
            CreateDirectory(manifestPath);
            using (StreamWriter writer = new StreamWriter(File.Open(manifestPath, FileMode.Create)))
            {
                // 写入 lua 信息
                writer.WriteLine(luaList.Count);// [W] lua 数量
                foreach (string luaPath in luaList)
                    writer.WriteLine(luaPath);// [W] lua 文件路径

                // 写入场景信息
                writer.WriteLine(sceneList.Count);// [W] 场景数量
                foreach (string scenePath in sceneList)
                    writer.WriteLine(scenePath);// [W] 场景文件路径

                // 写入 AssetBundle 信息
                foreach (AssetBundleInfo abi in s_abiList)
                {
                    if (abi.assets.Count == 0) continue;
                    writer.WriteLine(abi.assets.Count + 1);// [W] AssetBundle 包含的文件数量 + 1（别名）
                    writer.WriteLine(abi.name);// [W] AssetBundle 文件别名
                    foreach (string asset in abi.assets)
                        writer.WriteLine(asset);// [W] AssetBundle 包含的文件路径
                }
            }
        }


        /// <summary>
        /// 解析资源文件夹
        /// </summary>
        /// <param name="dir">Dir.</param>
        private static void ParseResDir(string dir)
        {
            dir = dir.Replace("\\", "/");

            string rulePath = dir.Replace(ResDir, "");
            if (!rulePath.EndsWith("/", StringComparison.Ordinal)) rulePath += "/";

            // 是被忽略的目录
            foreach (string d in s_ignoreRules)
                if (rulePath.StartsWith(d, StringComparison.Ordinal))
                    return;

            // 遍历目录下的文件
            string[] files = Directory.GetFiles(dir);
            foreach (string file in files)
            {
                if (file.EndsWith(".meta", StringComparison.Ordinal) || file.EndsWith(".DS_Store", StringComparison.Ordinal))
                    continue;
                AppendFile(file.Replace("\\", "/"), dir);
            }

            // 递归子目录
            string[] dirs = Directory.GetDirectories(dir);
            foreach (string d in dirs)
            {
                if (d.EndsWith(".svn", StringComparison.Ordinal))
                    continue;
                ParseResDir(d);
            }
        }


        /// <summary>
        /// 将文件添加到 AssetBundleInfo 中
        /// </summary>
        /// <param name="file">File.</param>
        /// <param name="abDir">Ab dir.</param>
        private static void AppendFile(string file, string abDir)
        {
            string extName = Path.GetExtension(file);

            // 是要被忽略的文件
            if (s_ignoreExtNames.Contains(extName))
                return;

            // 是要合并的文件
            if (s_combineExtNames.Contains(extName))
                abDir = "combine_extname" + extName;

            // 是要单独打包的文件
            if (s_singleExtNames.Contains(extName))
                abDir = file;


            string rulePath = file.Replace(ResDir, "");

            // 文件在需要被合并的目录下
            foreach (string d in s_combineRules)
            {
                if (rulePath.StartsWith(d, StringComparison.Ordinal))
                {
                    abDir = ResDir + d.Substring(0, d.Length - 1);
                    break;
                }
            }

            // 文件在 single 规则目录下
            foreach (string d in s_singleRules)
            {
                if (rulePath.StartsWith(d, StringComparison.Ordinal))
                {
                    abDir = file;
                    break;
                }
            }

            // 根据 abiDir 路径，创建或获取 abi 对象
            if (!s_abiMap.TryGetValue(abDir, out AssetBundleInfo abi))
            {
                abi = new AssetBundleInfo { name = abDir.ToLower() + ABExtName };
                s_abiMap.Add(abDir, abi);
                s_abiList.Add(abi);
            }
            abi.assets.Add(file);
        }


        /// <summary>
        /// 将 dirPath 目录下的所有 lua 文件添加到 list 中，并递归子目录
        /// </summary>
        /// <param name="dirPath">Dir path.</param>
        /// <param name="list">List.</param>
        private static void AppendLuaFiles(string dirPath, List<string> list)
        {
            string[] files = Directory.GetFiles(dirPath);
            foreach (string file in files)
            {
                if (file.EndsWith(".lua", StringComparison.Ordinal))
                    list.Add(file.Replace("\\", "/"));
            }

            string[] dirs = Directory.GetDirectories(dirPath);
            foreach (string dir in dirs)
            {
                if (!dir.EndsWith(".svn", StringComparison.Ordinal))
                    AppendLuaFiles(dir, list);
            }
        }


        /// <summary>
        /// 解析打包规则
        /// </summary>
        private static void ParseBuildRules()
        {
            using (StreamReader file = new StreamReader(RulesFilePath))
            {
                string line;
                HashSet<string> rules = null;
                HashSet<string> extNames = null;
                while ((line = file.ReadLine()) != null)
                {
                    if (line == "") continue;
                    if (line.StartsWith("//", StringComparison.Ordinal)) continue;

                    if (line.StartsWith("-ignore", StringComparison.Ordinal))
                    {
                        rules = s_ignoreRules;
                        extNames = s_ignoreExtNames;
                        continue;
                    }
                    if (line.StartsWith("-combine", StringComparison.Ordinal))
                    {
                        rules = s_combineRules;
                        extNames = s_combineExtNames;
                        continue;
                    }
                    if (line.StartsWith("-single", StringComparison.Ordinal))
                    {
                        rules = s_singleRules;
                        extNames = s_singleExtNames;
                        continue;
                    }

                    line = line.Replace("\\", "/");
                    if (line.StartsWith("*.", StringComparison.Ordinal))
                    {
                        extNames.Add(line.Substring(1));
                    }
                    else
                    {
                        if (!line.EndsWith("/", StringComparison.Ordinal)) line += "/";
                        rules.Add(line);
                    }

                }
            }
        }




        /// <summary>
        /// 打包（生成）场景和 AssetBundle 资源
        /// </summary>
        private static void GenerateAssets()
        {
            string targetPlatform = GetCmdLineArg("-targetPlatform");
            string manifestPath = GetCmdLineArg("-manifestPath");
            string outputDir = GetCmdLineArg("-outputDir");
            string scenes = GetCmdLineArg("-scenes");
            string outFilePath = GetCmdLineArg("-logFile").Replace("unity.log", "unity.out");

            //string targetPlatform = "android";
            //string manifestPath = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/log/0/manifest.log";
            //string outputDir = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/ShibaInu/cache/";
            //string scenes = "2,3";
            //string outFilePath = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/log/0/unity.out";

            // 需要打包的场景索引列表
            string[] buildScenes = scenes.Split(',');

            // 目标平台
            BuildTarget buildTarget = default;
            switch (targetPlatform)
            {
                case "ios":
                    buildTarget = BuildTarget.iOS;
                    break;
                case "android":
                    buildTarget = BuildTarget.Android;
                    break;
                case "macos":
                    buildTarget = BuildTarget.StandaloneOSX;
                    break;
                case "windows":
                    buildTarget = BuildTarget.StandaloneWindows;
                    break;
            }

            // 解析打包清单
            List<string> sceneList = new List<string>();
            List<AssetBundleBuild> abbList = new List<AssetBundleBuild>();
            using (StreamReader file = new StreamReader(manifestPath))
            {
                string line;
                int phase = 1, index = 0, count = 0;
                AssetBundleBuild abb = default;
                List<string> assets = new List<string>();
                while ((line = file.ReadLine()) != null)
                {
                    switch (phase)
                    {
                        // lua
                        case 1:
                            if (count == 0)
                                count = int.Parse(line);
                            else
                            {
                                if (++index == count)
                                {
                                    count = index = 0;
                                    phase++;
                                }
                            }
                            break;

                        // scene
                        case 2:
                            if (count == 0)
                                count = int.Parse(line);
                            else
                            {
                                sceneList.Add(line);
                                if (++index == count)
                                {
                                    count = index = 0;
                                    phase++;
                                }
                            }
                            break;

                        // AssetBundle
                        case 3:
                            if (count == 0)
                            {
                                count = int.Parse(line);
                            }
                            else
                            {
                                if (index == 0)
                                {
                                    abb = new AssetBundleBuild { assetBundleName = line };
                                    assets.Clear();
                                }
                                else
                                {
                                    assets.Add(line);
                                }

                                if (++index == count)
                                {
                                    count = index = 0;
                                    abb.assetNames = assets.ToArray();
                                    abbList.Add(abb);
                                }
                            }
                            break;
                    }
                }
            }


            // 打包场景
            if (buildScenes.Length > 0 && buildScenes[0] != "")
            {
                DateTime timeScene = DateTime.Now;
                WriteOut(outFilePath, "build scene start");
                string outputScene = outputDir + "scene/" + targetPlatform + "/";
                if (!Directory.Exists(outputScene))
                    Directory.CreateDirectory(outputScene);
                foreach (string index in buildScenes)
                {
                    DateTime time = DateTime.Now;
                    string scene = sceneList[int.Parse(index)];
                    string[] levels = { scene };
                    string outputPath = outputScene + Path.GetFileName(scene);
                    BuildReport report = BuildPipeline.BuildPlayer(levels, outputPath, buildTarget, BuildOptions.BuildAdditionalStreamedScenes);
                    if (report.summary.result == BuildResult.Succeeded)
                        WriteOut(outFilePath, "build scene complete," + scene + "," + DateTime.Now.Subtract(time).TotalMilliseconds);
                    else
                    {
                        WriteOut(outFilePath, "build scene error," + scene + "," + report.summary.result);
                        EditorApplication.Exit(1);
                        return;
                    }
                }
                WriteOut(outFilePath, "build scene all complete," + DateTime.Now.Subtract(timeScene).TotalMilliseconds);
            }


            // 打包 AssetBundle
            DateTime timeAB = DateTime.Now;
            WriteOut(outFilePath, "build assetbundle start");
            string outputAB = outputDir + "assetbundle/" + targetPlatform + "/";
            if (!Directory.Exists(outputAB))
                Directory.CreateDirectory(outputAB);
            BuildPipeline.BuildAssetBundles(outputAB, abbList.ToArray(),
                BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression,
                buildTarget
            );
            WriteOut(outFilePath, "build assetbundle complete," + DateTime.Now.Subtract(timeAB).TotalMilliseconds);


            // 写入 AssetBundle 依赖信息文件
            string dependenciesFilePath = outputDir + "dependencies.json";
            AssetBundle ab = AssetBundle.LoadFromFile(outputAB + targetPlatform);
            AssetBundleManifest manifest = (AssetBundleManifest)ab.LoadAsset("AssetBundleManifest");
            string[] abList = manifest.GetAllAssetBundles();
            using (StreamWriter writer = new StreamWriter(File.Open(dependenciesFilePath, FileMode.Create)))
            {
                writer.Write("{");
                bool isFirst = true;
                foreach (string abPath in abList)
                {
                    string[] depList = manifest.GetAllDependencies(abPath);
                    if (depList.Length > 0)
                    {
                        if (isFirst)
                            isFirst = false;
                        else
                            writer.Write(",");
                        writer.Write("\n  \"" + abPath + "\": [");
                        for (int i = 0; i < depList.Length; i++)
                        {
                            if (i != 0) writer.Write(", ");
                            writer.Write("\"" + depList[i].Replace("\\", "/") + "\"");
                        }
                        writer.Write("]");
                    }
                }
                writer.Write("\n}");
            }

            //
        }




        /// <summary>
        /// 生成目标平台项 Android / iOS
        /// </summary>
        private static void GeneratePlatformProject()
        {
            string targetPlatform = GetCmdLineArg("-targetPlatform");
            string outputDir = GetCmdLineArg("-outputDir");
            string development = GetCmdLineArg("-development");

            //string targetPlatform = "android";
            //string outputDir = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/ShibaInu/platform/tmp/";

            BuildTarget buildTarget;
            if (targetPlatform == "ios")
            {
                buildTarget = BuildTarget.iOS;
            }
            else
            {
                buildTarget = BuildTarget.Android;
                EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
                if (outputDir.EndsWith("/", StringComparison.Ordinal))
                    outputDir = outputDir.Substring(0, outputDir.Length - 1);// 切记!!!! 导出 AndroidStudio 项目路径不能以 "/" 结尾
            }

            if (Directory.Exists(outputDir))
                Directory.Delete(outputDir, true);

            BuildOptions options;
#if UNITY_2018
            // Unity 2018
            options = development == "true"
                ? BuildOptions.AcceptExternalModificationsToPlayer | BuildOptions.Development | BuildOptions.ConnectWithProfiler
                : BuildOptions.AcceptExternalModificationsToPlayer;
#else
            // Unity 2019 or Newer
            options = development == "true"
                ? BuildOptions.AllowDebugging | BuildOptions.Development | BuildOptions.ConnectWithProfiler
                : BuildOptions.None;
#endif
            BuildPipeline.BuildPlayer(CoreScenes, outputDir, buildTarget, options);
        }




        /// <summary>
        /// 如果传入的 filePath 所在的目录不存在，将会创建该目录
        /// </summary>
        /// <param name="filePath">File path.</param>
        private static void CreateDirectory(string filePath)
        {
            string dir = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        }


        /// <summary>
        /// 添加一行内容到输出文件中
        /// </summary>
        /// <param name="filePath">File path.</param>
        /// <param name="line">Line.</param>
        private static void WriteOut(string filePath, string line)
        {
            using (StreamWriter sw = File.AppendText(filePath))
            {
                sw.WriteLine(line);
            }
        }


        /// <summary>
        /// 根据命令行参数名称，获取对应的值
        /// </summary>
        /// <returns>The command line argument.</returns>
        /// <param name="argName">Argument name.</param>
        private static string GetCmdLineArg(string argName)
        {
            string[] args = Environment.GetCommandLineArgs();
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == argName)
                {
                    if (i < args.Length - 1)
                    {
                        string argValue = args[i + 1];
                        if (argValue.StartsWith("-", StringComparison.Ordinal)) return "";
                        return argValue;
                    }
                }
            }
            return "";
        }



        //[MenuItem("ShibaInu/Test Build", false, 1)]
        //private static void Test()
        //{
        //    GenerateBuildManifest();
        //}


        //
    }
}
