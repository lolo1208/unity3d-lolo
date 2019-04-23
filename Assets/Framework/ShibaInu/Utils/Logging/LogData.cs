using System;


namespace ShibaInu
{

    /// <summary>
    /// 日志数据
    /// </summary>
    public class LogData
    {
        /// 日志类型 - 普通
        public const string TYPE_LOG = "Log";
        /// 日志类型 - 警告
        public const string TYPE_WARNING = "Warning";
        /// 日志类型 - 错误
        public const string TYPE_ERROR = "Error";
        /// 日志类型 - 异常
        public const string TYPE_EXCEPTION = "Exception";
        /// 日志类型 - 断言
        public const string TYPE_ASSERT = "Assert";

        /// 日志类型 - 通信成功
        public const string TYPE_NET_SUCC = "NetSucc";
        /// 日志类型 - 通信失败
        public const string TYPE_NET_FAIL = "NetFail";
        /// 日志类型 - 后端推送
        public const string TYPE_NET_PUSH = "NetPush";



        /// 日志类型
        public string type;
        /// 日志描述消息
        public string msg;
        /// 堆栈信息
        public string stackTrace;
        /// 日志产生时间
        public string time;

        /// 日志内容转换成的字符串
        private string m_string;



        /// <summary>
        /// 添加一条日志
        /// </summary>
        /// <param name="type">Type.</param>
        /// <param name="msg">Message.</param>
        /// <param name="stackTrace">Stack trace.</param>
        public static LogData Append(string type, string msg, string stackTrace = null)
        {
            LogData data = new LogData
            {
                type = type,
                msg = msg.Replace("\r", "").Replace("\n", " "),
                stackTrace = stackTrace,
                time = DateTime.Now.ToString("HH:mm:ss.fff")
            };

            LogFileWriter.Append(data);

            return data;
        }



        override public string ToString()
        {
            if (m_string == null)
            {
                if (stackTrace == null)
                    m_string = string.Format("[{0}] [{1}] {2}", type, time, msg);
                else
                    m_string = string.Format("[{0}] [{1}] {2}{3}", type, time, msg, stackTrace);
            }
            return m_string;
        }


        //
    }
}

