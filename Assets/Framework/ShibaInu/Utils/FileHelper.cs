using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;


namespace ShibaInu
{

    /// <summary>
    /// 文件相关操作工具
    /// </summary>
    public static class FileHelper
    {

#if UNITY_ANDROID && !UNITY_EDITOR
		private static readonly AndroidJavaClass m_androidStreamingAssets = new AndroidJavaClass ("shibaInu.util.StreamingAssets");
#endif


        /// <summary>
        /// 文件是否存在
        /// </summary>
        /// <returns><c>true</c>, if exists was filed, <c>false</c> otherwise.</returns>
        /// <param name="path">文件路径</param>
        public static bool Exists(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
			if(path.StartsWith(Constants.PackageDir))
				return m_androidStreamingAssets.CallStatic<bool> ("exists", path.Replace (Constants.PackageDir, ""));
			else
				return File.Exists (path);

#else
            return File.Exists(path);
#endif
        }



        /// <summary>
        /// 获取文件的字节内容
        /// </summary>
        /// <returns>The file bytes.</returns>
        /// <param name="path">文件路径</param>
        public static byte[] GetBytes(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            if (path.StartsWith (Constants.PackageDir))
                return m_androidStreamingAssets.CallStatic<byte[]> ("getBytes", path.Replace (Constants.PackageDir, ""));
            else
                return File.ReadAllBytes (path);

#else
            return File.ReadAllBytes(path);
#endif
        }



        /// <summary>
        /// 获取文件的字符串内容
        /// </summary>
        /// <returns>The file bytes.</returns>
        /// <param name="path">文件路径</param>
        public static string GetText(string path)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            if (path.StartsWith (Constants.PackageDir))
                return m_androidStreamingAssets.CallStatic<string> ("getText", path.Replace (Constants.PackageDir, ""));
            else
                return File.ReadAllText (path);

#else
            return File.ReadAllText(path);
#endif
        }




#if UNITY_EDITOR

        /// 已缓存的文件路径列表（大小写匹配）
        private static readonly HashSet<string> s_cachePaths = new HashSet<string>();
        private static readonly string AppDataPath = Application.dataPath + '/';


        /// <summary>
        /// 检测传入路径的大小写是否匹配
        /// </summary>
        /// <returns><c>true</c>, if path case match was ised, <c>false</c> otherwise.</returns>
        /// <param name="path">Path.</param>
        public static bool IsPathCaseMatch(string path)
        {
            if (s_cachePaths.Contains(path))
                return true;

            path = path.Replace('\\', '/');
            string curPath;
            if (path.EndsWith(".lua", StringComparison.Ordinal))
            {
                // lua 文件
                path = path.Replace(AppDataPath, "");
                curPath = "Assets/";
            }
            else
            {
                // 资源文件
                curPath = Constants.ResDirPath;
            }

            string[] paths = path.Split('/');
            int fileIdx = paths.Length - 1;

            // 逐级查找目录大小写是否匹配
            for (int i = 0; i < fileIdx; i++)
            {
                string[] dirs = Directory.GetDirectories(curPath);
                curPath += paths[i];
                bool isMatch = false;
                foreach (string dir in dirs)
                {
                    if (dir == curPath)
                    {
                        curPath += "/";
                        isMatch = true;
                        break;
                    }
                }
                if (!isMatch)
                    return false;
            }

            // 文件大小写是否匹配
            string[] files = Directory.GetFiles(curPath);
            curPath += paths[fileIdx];
            foreach (string file in files)
            {
                if (file == curPath)
                {
                    s_cachePaths.Add(path);
                    return true;
                }
            }

            return false;
        }

#endif


        //
    }
}

