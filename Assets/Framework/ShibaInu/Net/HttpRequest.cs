using System;
using System.IO;
using System.Threading;
using System.Collections.Generic;
using System.Net;
using System.Text;
using LuaInterface;


namespace ShibaInu
{

    /// <summary>
    /// 用于发送 http 请求，获取返回内容
    /// </summary>
    public class HttpRequest
    {
        /// 网络地址
        public string url;
        /// 请求方式
        public string method = HttpRequestMethod.GET;
        /// 超时时限（毫秒）
        public int timeout = 5000;
        /// 已 EncodeURI() 的 post 数据
        public string postData;
        /// 请求成功或失败的回调函数 (状态码, 数据内容)
        public Action<int, string> callback;


        private HttpWebRequest m_request;
        private StringBuilder m_postData;
        private string m_proxyHost;
        private int m_proxyPort;


        /// 是否正在发送请求中
        public bool requeting { get; private set; }




        /// <summary>
        /// 添加 post data
        /// </summary>
        /// <param name="key">Key.</param>
        /// <param name="value">Value.</param>
        public void AppedPostData(string key, string value)
        {
            if (m_postData == null)
            {
                m_postData = new StringBuilder();
            }
            else
            {
                m_postData.Append("&");
            }

            m_postData.Append(key).Append("=").Append(EncodeURI(value));
        }


        /// <summary>
        /// 清空 post data
        /// </summary>
        public void CleanPostData()
        {
            m_postData = null;
            postData = null;
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
            this.callback = (int statusCode, string content) =>
            {
                callback.BeginPCall();
                callback.Push(statusCode);
                callback.Push(content);
                callback.PCall();
                callback.EndPCall();
            };
        }




        /// <summary>
        /// 发送请求
        /// </summary>
        public void Send()
        {
            if (requeting || url == null)
                return;
            requeting = true;

            try
            {
                ThreadPool.QueueUserWorkItem(DoSend);
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
        private void DoSend(Object stateInfo)
        {
            // 被取消了
            if (!requeting)
            {
                InvokeCallback(HttpExceptionStatusCode.ABORTED);
                return;
            }

            try
            {
                // 创建 HttpWebRequest
                m_request = (HttpWebRequest)WebRequest.Create(url);
                m_request.ServicePoint.ConnectionLimit = 10;
                m_request.Method = method;
                m_request.Timeout = timeout;

                // 代理
                if (m_proxyHost != null)
                    m_request.Proxy = new WebProxy(m_proxyHost, m_proxyPort);

                // post 方式
                if (method == HttpRequestMethod.POST)
                {
                    // 连接 postData
                    if (m_postData != null)
                    {
                        if (postData != null)
                        {
                            m_postData.Append("&").Append(postData);
                        }
                        postData = m_postData.ToString();
                        m_postData = null;
                    }

                    // 写入 post 数据
                    if (postData != null)
                    {
                        byte[] postBytes = Encoding.UTF8.GetBytes(postData);
                        using (Stream requestStream = m_request.GetRequestStream())
                        {
                            requestStream.Write(postBytes, 0, postBytes.Length);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                InvokeCallback(HttpExceptionStatusCode.SEND_REQUEST, e.Message);
                return;
            }


            // 被取消了
            if (!requeting)
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
                    if (!requeting)
                    {
                        InvokeCallback(HttpExceptionStatusCode.ABORTED);
                        return;
                    }

                    int statusCode = (int)response.StatusCode;
                    // 只获取 response handers (content length)
                    if (method == HttpRequestMethod.HEAD)
                    {
                        InvokeCallback(statusCode, response.ContentLength.ToString());
                        return;
                    }

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
            requeting = false;

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
        /// <param name="cancelCallBack">是否注销已注册的回调</param>
        public void Abort(bool cancelCallBack = true)
        {
            requeting = false;
            if (cancelCallBack)
                callback = null;
            if (m_request != null)
                m_request.Abort();
        }




        /// <summary>
        /// 对传入的 str 进行 url 编码，并返回编码后的字符串
        /// </summary>
        /// <returns>The encode.</returns>
        /// <param name="str">String.</param>
        private static string EncodeURI(string str)
        {
            StringBuilder sb = new StringBuilder();
            byte[] bytes = Encoding.UTF8.GetBytes(str);
            foreach (byte b in bytes)
            {
                sb.Append(@"%" + Convert.ToString(b, 16));
            }
            return sb.ToString();
        }


        //
    }
}

