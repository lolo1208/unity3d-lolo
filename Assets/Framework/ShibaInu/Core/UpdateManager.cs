using System;
using System.Threading;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Collections;
using ICSharpCode.SharpZipLib.Zip;
using UnityEngine;


namespace ShibaInu
{

    /// <summary>
    /// 
    /// </summary>
    public static class UpdateManager
    {

        #region 解压更新包 ZIP 文件（协程）

        /// 状态 - 无状态（还未开始解压缩）
        public static readonly int STATE_EXTRACT_NONE = 0;
        /// 状态 - 解压缩中
        public static readonly int STATE_EXTRACTING = 1;
        /// 状态 - 解压缩完成
        public static readonly int STATE_EXTRACT_COMPLETED = 2;
        /// 状态 - 解压缩过程中被取消
        public static readonly int STATE_EXTRACT_ABORT = 3;
        /// 状态 - 解压缩出错
        public static readonly int STATE_EXTRACT_ERROR = 4;


        /// 当前状态
        public static int State { get; private set; } = STATE_EXTRACT_NONE;

        /// 解压缩进度（0~1）
        public static float Progress { get { return s_progress; } }

        /// 解压缩出错（或被取消）时，对应的错误信息
        public static string ErrorMessage { get; private set; } = string.Empty;


        /// 补丁包文件路径
        private static string s_zipPath;
        /// 需解压缩的文件总数
        private static int s_totalNum = 1;
        /// 已完成解压缩的文件数
        private static int s_extractNum;
        /// 当前已解压进度
        private static float s_progress;
        /// 上次记录的解压进度
        private static float s_progressRec;
        /// 卸载资源的协程对象
        private static Coroutine s_coExtract;


        /// <summary>
        /// 开始解压缩更新包（ZIP）文件
        /// 解压完成后，将会删除更新包文件
        /// </summary>
        /// <param name="patchPackagePath">更新包文件路径</param>
        public static void Extract(string patchPackagePath)
        {
            s_zipPath = patchPackagePath;

            if (!File.Exists(patchPackagePath))
            {
                ExtractException(new Exception(string.Format(Constants.E1004, patchPackagePath)));
                return;
            }

            try
            {
                State = STATE_EXTRACTING;
                s_progressRec = 0;
                if (s_coExtract != null)
                    Common.looper.StopCoroutine(s_coExtract);
                s_coExtract = Common.looper.StartCoroutine(DoExtract());
            }
            catch (Exception e)
            {
                ExtractException(e);
            }
        }


        /// <summary>
        /// 执行解压缩任务（协程）
        /// </summary>
        private static IEnumerator DoExtract()
        {
            // 被取消了
            if (State != STATE_EXTRACTING) yield break;

            // 创建更新文件目录
            DirectoryInfo updateDir = new DirectoryInfo(Constants.UpdateDir);
            if (!updateDir.Exists)
                updateDir.Create();

            string version = "";
            ZipInputStream zip;
            try
            {
                // 获取总文件数
                using (ZipFile zipFile = new ZipFile(s_zipPath))
                    s_totalNum = Convert.ToInt32(zipFile.Count);
                zip = new ZipInputStream(File.Open(s_zipPath, FileMode.Open));
            }
            catch (Exception e)
            {
                ExtractException(e);
                yield break;
            }

            while (State == STATE_EXTRACTING)
            {
                ZipEntry entry;
                try
                {
                    entry = zip.GetNextEntry();
                }
                catch (Exception e)
                {
                    ExtractException(e);
                    break;
                }
                if (entry == null) break;// 解压完毕

                s_extractNum++;
                s_progress = (float)s_extractNum / s_totalNum;
                // 进度每超过 1% 时停留一会，留给界面更新时间
                if (s_progress - s_progressRec > 0.01 || s_progress == 1)
                {
                    s_progressRec = s_progress;
                    yield return new WaitForEndOfFrame();
                }

                try
                {
                    if (entry.Name == "./") continue;
                    if (entry.Name == Constants.VerCfgFileName)
                    {
                        // 版本号文件（version.cfg）的内容先记录下来，解压全部完成后，再写入文件中
                        byte[] bytes = new byte[entry.Size];
                        zip.Read(bytes, 0, bytes.Length);
                        version = Encoding.UTF8.GetString(bytes, 0, bytes.Length);
                    }
                    else
                    {
                        // 解压（写入）文件
                        using (FileStream fs = new FileStream(Constants.UpdateDir + entry.Name, FileMode.Create))
                        {
                            byte[] buffer = new byte[1024 * 2];
                            int len;
                            while ((len = zip.Read(buffer, 0, buffer.Length)) > 0)
                                fs.Write(buffer, 0, len);
                        }
                    }
                }
                catch (Exception e)
                {
                    ExtractException(e);
                    break;
                }
            }

            zip?.Dispose();
            if (State != STATE_EXTRACTING) yield break;// 被取消或出错了

            // 写入 version.cfg
            try
            {
                using (StreamWriter sw = new StreamWriter(VersionConfigFilePath, false))
                    sw.Write(version);
            }
            catch (Exception e)
            {
                ExtractException(e);
                yield break;
            }

            // complete
            State = STATE_EXTRACT_COMPLETED;
            s_coExtract = null;
            ClearCache();
            File.Delete(s_zipPath);// 删除更新包文件
        }


        private static void ExtractException(Exception e)
        {
            if (s_coExtract != null)
            {
                Common.looper.StopCoroutine(s_coExtract);
                s_coExtract = null;
            }
            State = STATE_EXTRACT_ERROR;
            ErrorMessage = e.Message;
            LogException(e);
        }


        /// <summary>
        /// 取消解压缩
        /// </summary>
        public static void AbortExtract()
        {
            if (State == STATE_EXTRACTING)
                State = STATE_EXTRACT_ABORT;

            if (s_coExtract != null)
            {
                Common.looper.StopCoroutine(s_coExtract);
                s_coExtract = null;
            }
        }


        /// <summary>
        /// 获取更新包储存在本地的路径
        /// </summary>
        /// <param name="fileName">更新包文件名</param>
        /// <returns></returns>
        public static string GetPatchPackagePath(string fileName)
        {
            return Constants.PatchDir + fileName;
        }

        #endregion



        #region 验证更新包

        /// <summary>
        /// 验证更新包文件 MD5 是否与传入的 md5 字符串一致。
        /// 如果不一致，将会删除更新包文件。
        /// </summary>
        /// <param name="pkgPath"></param>
        /// <param name="md5"></param>
        /// <returns></returns>
        public static bool VerifyPatchPackage(string pkgPath, string md5)
        {
            try
            {
                if (!File.Exists(pkgPath)) return false;

                if (MD5Util.GetFileMD5(pkgPath) == md5) return true;

                File.Delete(pkgPath);
            }
            catch (Exception e)
            {
                Logger.LogException(e);
            }
            return false;
        }

        #endregion



        #region 删除与当前（最新）版本无关的文件（后台线程）

        public static void ClearCache()
        {
            if (!File.Exists(VersionConfigFilePath)) return;

            try
            {
                ThreadPool.QueueUserWorkItem(DoClearCache);
            }
            catch (Exception e)
            {
                LogException(e);
            }
        }

        private static void DoClearCache(object stateInfo)
        {
            try
            {
                // 获取版本号
                string fullVersion = FileHelper.GetText(VersionConfigFilePath);
                // 解析资源清单文件名
                string manifestFileName = fullVersion + ".manifest";

                // 建立资源文件列表
                HashSet<string> resList = new HashSet<string>();
                resList.Add(Constants.VerCfgFileName);
                resList.Add(manifestFileName);
                using (StreamReader file = new StreamReader(new MemoryStream(FileHelper.GetBytes(Constants.UpdateDir + manifestFileName))))
                {
                    string line;
                    while ((line = file.ReadLine()) != null)
                    {
                        if (line.EndsWith(Constants.EXT_AB, StringComparison.Ordinal)
                            || line.EndsWith(Constants.EXT_LUA, StringComparison.Ordinal)
                            || line.EndsWith(Constants.EXT_SCENE, StringComparison.Ordinal)
                            || line.EndsWith(Constants.EXT_BYTES, StringComparison.Ordinal)
                            )
                            resList.Add(line);
                    }
                }

                // 删除与当前版本无关的文件
                string[] files = Directory.GetFiles(Constants.UpdateDir);
                foreach (string file in files)
                {
                    if (!resList.Contains(new FileInfo(file).Name))
                        File.Delete(file);
                }
            }
            catch (Exception e)
            {
                LogException(e);
            }
        }

        #endregion



        #region 修复资源。删除已更新的所有内容，以及已下载的更新包

        public static bool Repair()
        {
            try
            {
                if (Directory.Exists(Constants.UpdateDir))
                    Directory.Delete(Constants.UpdateDir, true);
                if (Directory.Exists(Constants.PatchDir))
                    Directory.Delete(Constants.PatchDir, true);
                return true;
            }
            catch (Exception e)
            {
                Logger.LogException(e);
                return false;
            }
        }

        #endregion



        /// <summary>
        /// 更新包目录下的版本信息文件路径
        /// </summary>
        private static string VersionConfigFilePath
        {
            get { return Constants.UpdateDir + Constants.VerCfgFileName; }
        }


        private static void LogException(Exception e)
        {
            Common.looper.AddActionToMainThread(() =>
            {
                Logger.LogException(e);
            });
        }


        //
    }
}

