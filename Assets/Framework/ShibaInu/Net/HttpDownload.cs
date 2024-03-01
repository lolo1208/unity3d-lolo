using System;
using System.IO;
using System.Net;
using System.Threading;
using LuaInterface;


namespace ShibaInu
{

    /// <summary>
    /// HTTP 下载文件，并保存在本地
    /// </summary>
    public class HttpDownload
    {
        /// 下载完成的状态码
        public static readonly int STATUS_CODE_COMPLETE = (int)HttpStatusCode.OK;


        /// 文件网络地址
        public string Url;
        /// 本地保存路径
        public string SavePath;
        /// 下载超时时限（毫秒）
        public int Timeout = 5000;
        /// 下载成功或失败的回调函数 (状态码, 错误信息)
        public Action<int, string> Callback;

        /// 已下载字节数
        private long m_bytesLoaded;
        /// 文件总字节数
        private long m_bytesTotal = 1;
        /// 上次统计下载速度的时间（秒）
        private float m_lastTime;
        /// 上次统计下载速度的字节数
        private long m_lastBytes;

        private HttpWebRequest m_request;
        private string m_proxyHost;
        private int m_proxyPort;


        /// 已下载，字节
        public int BytesLoaded { get { return (int)m_bytesLoaded; } }

        /// 总大小，字节
        public int BytesTotal { get { return (int)m_bytesTotal; } }

        /// 下载进度（0 ~ 1）
        public float Progress { get { return (float)m_bytesLoaded / m_bytesTotal; } }

        /// 下载速度，字节/秒
        public int Speed { get; private set; }

        /// 是否正在下载中
        public bool Downloading { get; private set; }



        /// <summary>
        /// 设置代理
        /// </summary>
        /// <param name="host">Host.</param>
        /// <param name="port">Port.</param>
        public void SetProxy(string host, int port)
        {
            m_proxyHost = host;
            m_proxyPort = port;
        }


        /// <summary>
        /// 设置回调为 lua 函数
        /// </summary>
        /// <param name="callback">Callback.</param>
        public void SetLuaCallback(LuaFunction callback)
        {
            Callback = (int statusCode, string errMsg) =>
            {
                callback.BeginPCall();
                callback.Push(statusCode);
                callback.Push(errMsg);
                callback.PCall();
                callback.EndPCall();
            };
        }




        /// <summary>
        /// 开始下载
        /// </summary>
        public void Start()
        {
            if (Downloading || Url == null || SavePath == null)
                return;

            Downloading = true;
            m_bytesLoaded = 0;
            m_bytesTotal = 1;
            Speed = 0;

            try
            {
                ThreadPool.QueueUserWorkItem(DoDownload);
            }
            catch (Exception e)
            {
                InvokeCallback(HttpExceptionStatusCode.CREATE_THREAD, e.Message);
            }
        }


        /// <summary>
        /// 线程函数
        /// </summary>
        /// <param name="stateInfo">State info.</param>
        private void DoDownload(object stateInfo)
        {
            // 被取消了
            if (!Downloading)
            {
                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                return;
            }

            try
            {
                // 先使用 HEAD 模式获取文件大小
                m_request = (HttpWebRequest)WebRequest.Create(Url);
                m_request.ServicePoint.ConnectionLimit = 10;
                m_request.Method = HttpRequestMethod.HEAD;
                m_request.Timeout = Timeout;
                if (m_proxyHost != null)
                    m_request.Proxy = new WebProxy(m_proxyHost, m_proxyPort);

                using (HttpWebResponse response = (HttpWebResponse)m_request.GetResponse())
                {
                    m_bytesTotal = response.ContentLength;
                }

            }
            catch (Exception e)
            {
                InvokeCallback(HttpExceptionStatusCode.GET_HEAD, e.Message);
                return;
            }


            // 被取消了
            if (!Downloading)
            {
                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                return;
            }


            try
            {
                // 先创建对应的文件夹
                DirectoryInfo dirInfo = new FileInfo(SavePath).Directory;
                if (!dirInfo.Exists) dirInfo.Create();

                using (FileStream fs = new FileStream(SavePath, FileMode.OpenOrCreate, FileAccess.Write))
                {
                    m_bytesLoaded = fs.Length;
                    m_lastTime = 0f;
                    m_lastBytes = m_bytesLoaded;

                    // 继续下载
                    if (m_bytesLoaded < m_bytesTotal)
                    {
                        fs.Seek(m_bytesLoaded, SeekOrigin.Begin);

                        m_request = (HttpWebRequest)WebRequest.Create(Url);
                        m_request.ServicePoint.ConnectionLimit = 10;
                        m_request.AddRange((int)m_bytesLoaded);
                        m_request.Timeout = Timeout;
                        if (m_proxyHost != null)
                            m_request.Proxy = new WebProxy(m_proxyHost, m_proxyPort);

                        using (HttpWebResponse response = (HttpWebResponse)m_request.GetResponse())
                        {

                            // 被取消了
                            if (!Downloading)
                            {
                                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                                return;
                            }

                            // 获取文件内容
                            using (Stream responseStream = response.GetResponseStream())
                            {
                                byte[] buffer = new byte[4096];
                                int len = -1;
                                while ((len = responseStream.Read(buffer, 0, buffer.Length)) > 0)
                                {
                                    // 被取消了
                                    if (!Downloading)
                                    {
                                        InvokeCallback(HttpExceptionStatusCode.ABORTED);
                                        return;
                                    }

                                    fs.Write(buffer, 0, len);
                                    m_bytesLoaded += len;

                                    // 每秒统计两次速度
                                    float time = TimeUtil.timeSec - m_lastTime;
                                    if (time >= 0.5)
                                    {
                                        Speed = (int)((m_bytesLoaded - m_lastBytes) / time);
                                        m_lastTime = TimeUtil.timeSec;
                                        m_lastBytes = m_bytesLoaded;
                                    }
                                }
                            }
                        }
                    }
                }
                // 下载完成
                InvokeCallback(STATUS_CODE_COMPLETE);
            }
            catch (Exception e)
            {
                InvokeCallback(HttpExceptionStatusCode.GET_RESPONSE, e.Message);
            }
        }


        /// <summary>
        /// 执行回调
        /// </summary>
        /// <param name="statusCode">Status code.</param>
        /// <param name="errMsg">Error Message.</param>
        private void InvokeCallback(int statusCode, string errMsg = "")
        {
            if (m_request != null)
            {
                m_request.Abort();
                m_request = null;
            }
            Downloading = false;

            if (Callback != null)
            {
                Common.looper.AddNetAction(() =>
                {
                    Callback(statusCode, errMsg);
                });
            }
        }


        /// <summary>
        /// 取消正在发送的请求
        /// </summary>
        public void Abort()
        {
            Downloading = false;
            if (m_request != null)
                m_request.Abort();
        }


        //
    }
}

