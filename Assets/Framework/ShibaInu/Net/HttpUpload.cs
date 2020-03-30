using System;
using System.IO;
using System.Net;
using System.Threading;
using System.Collections.Generic;
using System.Text;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// Http 上传本地文件
    /// 
    /// multipart/form-data 数据结构可参考：
    /// https://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.2
    /// </summary>
    public class HttpUpload
    {
        /// 边界符的字符串格式
        private const string FORMAT_BOUNDARY = "----{0}";
        /// 内容类型字符串格式
        private const string FORMAT_CONTENT_TYPE = "Content-Type: multipart/form-data; boundary={0}";
        /// post 数据的字符串格式
        private const string FORMAT_POST_DATA = "--{0}\r\nContent-Disposition: form-data; name=\"{1}\"\r\n\r\n{2}\r\n";
        /// 文件信息的字符串格式
        private const string FORMAT_FILE_INFO = "--{0}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"{1}\"\r\nContent-Type: application/octet-stream\r\n\r\n";
        /// 全部结束时（最后一行）的字符串格式
        private const string FORMAT_END = "\r\n--{0}--";


        /// 网络地址
        public string url;
        /// 本地文件路径（UnityEngine.Application.persistentDataPath 目录下）
        public string filePath;
        /// 超时时限（毫秒）
        public int timeout = 5000;
        /// 请求成功或失败的回调函数 (状态码, 数据内容)
        public Action<int, string> callback;

        /// 已上传字节数
        private long m_bytesLoaded;
        /// 文件总字节数
        private long m_bytesTotal = 1;
        /// 上次统计上传速度的时间（秒）
        private float m_lastTime;
        /// 上次统计上传速度的字节数
        private long m_lastBytes;

        /// 要附带发送 POST 数据
        private Dictionary<string, string> m_postData;
        private HttpWebRequest m_request;
        private string m_proxyHost;
        private int m_proxyPort;



        /// 是否正在上传中
        public bool uploading { get; private set; }


        /// 上传速度，字节/秒
        public uint speed { get; private set; }


        /// 上传进度
        public float progress
        {
            get
            {
                return (float)m_bytesLoaded / m_bytesTotal;
            }
        }




        /// <summary>
        /// 添加 post data
        /// </summary>
        /// <param name="key">Key.</param>
        /// <param name="value">Value.</param>
        public void AppedPostData(string key, string value)
        {
            if (m_postData == null)
            {
                m_postData = new Dictionary<string, string>();
            }
            m_postData.Add(key, value);
        }


        /// <summary>
        /// 清空 post data
        /// </summary>
        public void CleanPostData()
        {
            m_postData = null;
        }


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
            this.callback = (int statusCode, string errMsg) =>
            {
                callback.BeginPCall();
                callback.Push(statusCode);
                callback.Push(errMsg);
                callback.PCall();
                callback.EndPCall();
            };
        }




        /// <summary>
        /// 开始上传
        /// </summary>
        public void Start()
        {
            if (uploading || url == null || filePath == null)
                return;
            uploading = true;
            m_bytesLoaded = 0;
            m_bytesTotal = 1;
            speed = 0;
            m_lastTime = 0f;
            m_lastBytes = 0;

            try
            {
                ThreadPool.QueueUserWorkItem(DoUpload);
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
        private void DoUpload(Object stateInfo)
        {
            // 被取消了
            if (!uploading)
            {
                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                return;
            }

            try
            {
                // 文件不存在
                if (!File.Exists(filePath))
                {
                    InvokeCallback(HttpExceptionStatusCode.FILE_ERROE);
                    return;
                }

                // 按当前时间生成分隔符
                string boundary = string.Format(FORMAT_BOUNDARY, DateTime.Now.Ticks.ToString("x"));

                // 设置 HttpWebRequest
                m_request = (HttpWebRequest)WebRequest.Create(url);
                m_request.ServicePoint.ConnectionLimit = 10;
                m_request.Method = HttpRequestMethod.POST;
                m_request.AllowWriteStreamBuffering = false;
                m_request.Timeout = timeout;
                m_request.ContentType = string.Format(FORMAT_CONTENT_TYPE, boundary);
                if (m_proxyHost != null)
                    m_request.Proxy = new WebProxy(m_proxyHost, m_proxyPort);

                // post 数据
                byte[] postDataBytes = null;
                if (m_postData != null)
                {
                    using (MemoryStream ms = new MemoryStream())
                    {
                        foreach (KeyValuePair<string, string> item in m_postData)
                        {
                            string s = string.Format(FORMAT_POST_DATA, boundary, item.Key, item.Value);
                            byte[] buffer = Encoding.UTF8.GetBytes(s);
                            ms.Write(buffer, 0, buffer.Length);
                        }
                        postDataBytes = ms.ToArray();
                    }
                }

                // 文件信息数据
                string sFileInfo = string.Format(FORMAT_FILE_INFO, boundary, Path.GetFileName(filePath));
                byte[] fileInfoBytes = Encoding.UTF8.GetBytes(sFileInfo);


                using (FileStream fs = new FileStream(filePath, FileMode.Open))
                {
                    m_bytesTotal = fs.Length;

                    // 结束（分隔符）数据
                    string sEnd = string.Format(FORMAT_END, boundary);
                    byte[] endBytes = Encoding.UTF8.GetBytes(sEnd);

                    // 得出 request 数据总长度
                    long contentLength = fileInfoBytes.Length + m_bytesTotal + endBytes.Length;
                    if (postDataBytes != null)
                        contentLength += postDataBytes.Length;
                    m_request.ContentLength = contentLength;

                    using (Stream rs = m_request.GetRequestStream())
                    {
                        // 写入 post 数据
                        if (postDataBytes != null)
                            rs.Write(postDataBytes, 0, postDataBytes.Length);

                        // 写入文件信息数据
                        rs.Write(fileInfoBytes, 0, fileInfoBytes.Length);

                        // 写入文件数据
                        byte[] buff = new byte[4096];
                        int size = fs.Read(buff, 0, buff.Length);
                        while (size > 0)
                        {
                            // 被取消了
                            if (!uploading)
                            {
                                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                                return;
                            }

                            rs.Write(buff, 0, size);
                            m_bytesLoaded += size;

                            // 每秒统计两次速度
                            float time = TimeUtil.timeSec - m_lastTime;
                            if (time >= 0.5)
                            {
                                speed = (UInt32)((m_bytesLoaded - m_lastBytes) / time);
                                m_lastTime = TimeUtil.timeSec;
                                m_lastBytes = m_bytesLoaded;
                            }

                            size = fs.Read(buff, 0, buff.Length);
                        }

                        // 写入结束（分隔符）数据
                        rs.Write(endBytes, 0, endBytes.Length);
                    }
                }

            }
            catch (Exception e)
            {
                InvokeCallback(HttpExceptionStatusCode.SEND_REQUEST, e.Message);
                return;
            }


            // 被取消了
            if (!uploading)
            {
                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                return;
            }


            try
            {
                // 获取响应内容
                using (HttpWebResponse response = (HttpWebResponse)m_request.GetResponse())
                {
                    // 被取消了
                    if (!uploading)
                    {
                        InvokeCallback(HttpExceptionStatusCode.ABORTED);
                        return;
                    }

                    int statusCode = (int)response.StatusCode;
                    // 读取内容
                    using (Stream responseStream = response.GetResponseStream())
                    {
                        using (StreamReader readStream = new StreamReader(responseStream, Encoding.UTF8))
                        {
                            string content = readStream.ReadToEnd();
                            // 请求成功
                            InvokeCallback(statusCode, content);
                        }
                    }
                }

            }
            catch (Exception e)
            {
                if (e is WebException)
                {
                    if ((e as WebException).Response is HttpWebResponse response)
                        InvokeCallback((int)response.StatusCode, e.Message);
                    else
                        InvokeCallback(HttpExceptionStatusCode.GET_RESPONSE, e.Message);
                }
                else
                {
                    InvokeCallback(HttpExceptionStatusCode.GET_RESPONSE, e.Message);
                }
            }
        }


        /// <summary>
        /// 执行回调
        /// </summary>
        /// <param name="statusCode">Status code.</param>
        /// <param name="content">Content.</param>
        private void InvokeCallback(int statusCode, string content = "")
        {
            if (m_request != null)
            {
                m_request.Abort();
                m_request = null;
            }
            uploading = false;

            if (callback != null)
            {
                Common.looper.AddNetAction(() =>
                {
                    callback(statusCode, content);
                });
            }
        }


        /// <summary>
        /// 取消正在发送的请求
        /// </summary>
        public void Abort()
        {
            uploading = false;
            if (m_request != null)
                m_request.Abort();
        }


        //
    }
}

