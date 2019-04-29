using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;


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
        /// Lua 文件根目录
        private static readonly string[] dirLuas = {
            "Assets/Framework/ShibaInu/Lua/",
            "Assets/Framework/ToLua/Lua/",
            "Assets/Lua/"
        };

        /// 核心场景列表
        private static readonly string[] coreScenes = {
            "Assets/Res/Scenes/" + Constants.LauncherSceneName + ".unity",
            "Assets/Res/Scenes/" + Constants.EmptySceneName + ".unity"
        };

        /// 资源根目录
        private const string dirRes = "Assets/Res/";



        /// <summary>
        /// 生成需要 build 的文件清单
        /// </summary>
        private static void GenerateBuildManifest()
        {
            string manifestPath = GetCmdLineArg("-manifestPath");
            //string manifestPath = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/ShibaInu/log/7.manifest";

            ClearAllAssetBundleNames();

            // lua 列表
            List<string> luaList = new List<string>();
            foreach (string luaDir in dirLuas)
                AppendLuaFiles(luaDir, luaList);

            // 场景列表
            List<string> sceneList = new List<string>();

            // AssetBundleInfo 列表
            List<AssetBundleInfo> abiList = new List<AssetBundleInfo>();

            // 解析项目资源目录结构
            string[] typeDirs = Directory.GetDirectories(dirRes);
            foreach (string typeDir in typeDirs)
            {
                switch (Path.GetFileName(typeDir))
                {
                    // 忽略的目录
                    case ".svn":
                    case "Ignore":
                        break;

                    // 场景资源
                    case "Scenes":
                        string[] files = Directory.GetFiles(typeDir);
                        foreach (string file in files)
                        {
                            if (file.EndsWith(".unity", StringComparison.Ordinal))
                            {
                                bool isCoreScene = false;// 是否属于核心场景
                                foreach (string coreScene in coreScenes)
                                {
                                    if (file == coreScene)
                                    {
                                        isCoreScene = true;
                                        break;
                                    }
                                }
                                if (!isCoreScene) sceneList.Add(file);
                            }
                        }
                        break;

                    // Asset Bundle
                    default:
                        GenerateAssetBundleInfo(typeDir, abiList);
                        break;
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
                foreach (AssetBundleInfo abi in abiList)
                {
                    writer.WriteLine(abi.assets.Count + 1);// [W] AssetBundle 包含的文件数量 + 别名
                    writer.WriteLine(abi.name);// [W] AssetBundle 文件别名
                    foreach (string asset in abi.assets)
                        writer.WriteLine(asset);// [W] AssetBundle 包含的文件路径
                }
            }
        }


        /// <summary>
        /// 根据 目录 或 prefab 来创建 AssetBundleInfo，然后存入 list 中
        /// </summary>
        /// <param name="path">Path.</param>
        /// <param name="list">List.</param>
        private static void GenerateAssetBundleInfo(string path, List<AssetBundleInfo> list)
        {
            // 固定小写名和 ".ab" 后缀
            AssetBundleInfo abi = new AssetBundleInfo { name = path.ToLower() + ".ab" };

            // prefab 文件单独打包成 AssetBundle
            if (path.EndsWith(".prefab", StringComparison.Ordinal))
            {
                abi.assets.Add(path);
            }
            else
            {
                // 每个目录都打成一个 AssetBundle，包含该目录下的所有文件（不含子目录和 prefab 文件）
                string[] files = Directory.GetFiles(path);
                foreach (string file in files)
                {
                    if (file.EndsWith(".prefab", StringComparison.Ordinal))
                        GenerateAssetBundleInfo(file, list);// prefab 文件
                    else
                    {
                        if (!file.EndsWith(".meta", StringComparison.Ordinal)
                            && !file.EndsWith(".DS_Store", StringComparison.Ordinal)
                        )
                            abi.assets.Add(file);
                    }
                }

                // 递归子目录
                string[] dirs = Directory.GetDirectories(path);
                foreach (string dir in dirs)
                {
                    if (!dir.EndsWith(".svn", StringComparison.Ordinal))
                        GenerateAssetBundleInfo(dir, list);
                }
            }

            // 有包含资源（不是空目录）
            if (abi.assets.Count > 0) list.Add(abi);
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
        /// 清除所有已设置的 AssetBundle Name
        /// </summary>
        private static void ClearAllAssetBundleNames()
        {
            string[] names = AssetDatabase.GetAllAssetBundleNames();
            foreach (string name in names)
                AssetDatabase.RemoveAssetBundleName(name, true);
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

            //string targetPlatform = "android";
            //string manifestPath = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/ShibaInu/log/7/manifest.log";
            //string outputDir = "/Users/limylee/LOLO/unity/projects/ShibaInu/Tools/build/ShibaInu/cache/";
            //string scenes = "2,3";

            // 需要打包的场景索引列表
            string[] buildScenes = scenes.Split(',');

            // 目标平台
            BuildTarget buildTarget = default(BuildTarget);
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
                AssetBundleBuild abb = default(AssetBundleBuild);
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
                Console.Error.WriteLine("[build scene start]");
                string outputScene = outputDir + "scene/" + targetPlatform + "/";
                if (!Directory.Exists(outputScene))
                    Directory.CreateDirectory(outputScene);
                foreach (string index in buildScenes)
                {
                    DateTime startTime = DateTime.Now;
                    string scene = sceneList[int.Parse(index)];
                    string[] levels = { scene };
                    string outputPath = outputScene + Path.GetFileName(scene);
                    BuildPipeline.BuildPlayer(levels, outputPath, buildTarget, BuildOptions.BuildAdditionalStreamedScenes);
                    Console.Error.WriteLine("[build scene complete]," + scene + "," + DateTime.Now.Subtract(startTime).TotalMilliseconds);
                }
                Console.Error.WriteLine("[build scene all complete]");
            }


            // 打包 AssetBundle
            Console.Error.WriteLine("[build assetbundle start]");
            string outputAB = outputDir + "assetbundle/" + targetPlatform + "/";
            if (!Directory.Exists(outputAB))
                Directory.CreateDirectory(outputAB);
            BuildPipeline.BuildAssetBundles(outputAB, abbList.ToArray(),
                BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression,
                buildTarget
            );
            Console.Error.WriteLine("[build assetbundle complete]");


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
                            writer.Write("\"" + depList[i] + "\"");
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
            BuildPipeline.BuildPlayer(coreScenes, outputDir, buildTarget, BuildOptions.AcceptExternalModificationsToPlayer);
        }




        /// <summary>
        /// 如果传入的 filePath 所在的目录不存在，将会创建该目录
        /// </summary>
        /// <param name="filePath">File path.</param>
        public static void CreateDirectory(string filePath)
        {
            string dir = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
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
        //    GeneratePlatformProject();
        //}


        //
    }
}
