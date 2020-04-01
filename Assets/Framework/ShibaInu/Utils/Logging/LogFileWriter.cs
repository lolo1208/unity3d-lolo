using System;
using System.IO;
using System.Collections.Generic;
using System.Threading;

using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 写入日志文件
    /// </summary>
    public static class LogFileWriter
    {

#if UNITY_EDITOR
        public static readonly string FILE_PATH = Application.dataPath + "/../Logs/Running.log";
#else
		public static readonly string FILE_PATH = Application.persistentDataPath + "/Logs/Running.log";
#endif

        public static readonly string DIR_PATH = Path.GetDirectoryName(FILE_PATH);

        /// 写入文件间隔（毫秒）
        private const int WRITE_INTERVAL = 3000;

        /// 还未写入到文件中的日志列表
        private static readonly List<LogData> s_list = new List<LogData>();
        /// 锁对象
        private static readonly object LOCK_OBJECT = new object();
        /// 写入文件定时器是否已经启动了
        private static bool s_running;
        /// 是否追加写入文件（日志内容是否已经被清空过了）
        private static bool s_isAppend;



        /// <summary>
        /// 添加一条日志
        /// </summary>
        /// <param name="data">Data.</param>
        public static void Append(LogData data)
        {
            lock (LOCK_OBJECT)
            {

                s_list.Add(data);
                if (!s_running)
                {
                    Timer.Once(WRITE_INTERVAL, (Timer timer) =>
                    {
                        ThreadPool.QueueUserWorkItem(new WaitCallback(WriteFile));
                    });
                    s_running = true;
                }

            }
        }


        /// <summary>
        /// [线程函数] 写入日志文件
        /// </summary>
        /// <param name="stateInfo">State info.</param>
        private static void WriteFile(object stateInfo = null)
        {
            lock (LOCK_OBJECT)
            {

                if (s_list.Count > 0)
                {
                    if (!s_isAppend && !Directory.Exists(DIR_PATH))
                        Directory.CreateDirectory(DIR_PATH);

                    using (StreamWriter sw = new StreamWriter(FILE_PATH, s_isAppend))
                    {
                        if (!s_isAppend)
                        {
                            sw.WriteLine(DateTime.Now.ToString("[yyyy/MM/dd]"));
                            s_isAppend = true;
                        }
                        foreach (LogData data in s_list)
                        {
                            sw.WriteLine("");
                            sw.WriteLine(data);
                        }
                        s_list.Clear();
                    }
                }
                s_running = false;

            }
        }


        /// <summary>
        /// 销毁。游戏结束时
        /// </summary>
        public static void Destroy()
        {
            WriteFile();
        }

        //
    }
}

