using System;
using System.IO;
using System.Threading;
using System.Collections.Generic;
using System.Net;
using System.Text;
using LuaInterface;


namespace ShibaInu
{
	public class HttpRequestMethod
	{
		/// 发送 POST 数据
		public const string POST = "POST";
		/// 发送 GET 数据
		public const string GET = "GET";
		/// 只获取 response handers (content length)
		public const string HEAD = "HEAD";
	}

	public class HttpException
	{
		/// 创建线程时发生异常
		public const int CREATE_THREAD = -1;
		/// 发送请求时发生异常
		public const int SEND_REQUEST = -2;
		/// 获取内容时发生异常
		public const int GET_RESPONSE = -3;
		/// 发送请求或获取内容过程中被取消了
		public const int ABORTED = -4;
	}



	public class HttpRequest
	{
		public string url = null;
		public string method = HttpRequestMethod.GET;
		public int timeout = 5000;
		public string postData = null;
		public Action<int, string> callback = null;

		private bool m_requesting = false;
		private HttpWebRequest m_request = null;

		private StringBuilder m_postData = null;
		private string m_proxyHost = null;
		private int m_proxyPort = 0;



		public HttpRequest ()
		{
			
		}


		/// <summary>
		/// 添加 post data
		/// </summary>
		/// <param name="key">Key.</param>
		/// <param name="value">Value.</param>
		public void AppedPostData (string key, string value)
		{
			if (m_postData == null)
				m_postData = new StringBuilder ();

			if (m_postData.Length > 0)
				m_postData.Append ("&");
			
			m_postData.Append (key).Append ("=").Append (UrlEncode (value));
		}

		/// <summary>
		/// 清空 post data
		/// </summary>
		public void CleanPostData ()
		{
			m_postData = null;
			postData = null;
		}


		/// <summary>
		/// 设置代理
		/// </summary>
		/// <param name="host">Host.</param>
		/// <param name="port">Port.</param>
		public void SetProxy (string host, int port)
		{
			m_proxyHost = host;
			m_proxyPort = port;
		}


		/// <summary>
		/// 设置回调为 lua 函数
		/// </summary>
		/// <param name="callback">Callback.</param>
		public void SetLuaCallback (LuaFunction callback)
		{
			this.callback = (int statusCode, string content) => {
				callback.BeginPCall ();
				callback.Push (statusCode);
				callback.Push (content);
				callback.PCall ();
				callback.EndPCall ();
			};
		}


		/// <summary>
		/// 发送请求
		/// </summary>
		public void Send ()
		{
			if (m_requesting || url == null)
				return;
			m_requesting = true;

			try {
				ThreadPool.QueueUserWorkItem (DoSend);
			} catch (Exception e) {
				DoCallback (HttpException.CREATE_THREAD, e.Message);
			}
		}


		/// <summary>
		/// Dos the send. 线程函数
		/// </summary>
		private void DoSend (Object stateInfo)
		{
			// 被取消了
			if (!m_requesting) {
				DoCallback (HttpException.ABORTED);
				return;
			}

			Stream requestStream = null;
			try {
				// 创建 HttpWebRequest
				m_request = (HttpWebRequest)WebRequest.Create (url);
				m_request.Method = method;
				m_request.Timeout = timeout;

				// 代理
				if (m_proxyHost != null)
					m_request.Proxy = new WebProxy (m_proxyHost, m_proxyPort);
				
				// post 模式
				if (method == HttpRequestMethod.POST) {
					// 连接 postData
					if (m_postData != null) {
						if (postData != null) {
							m_postData.Append ("&").Append (postData);
						}
						postData = m_postData.ToString ();
						m_postData = null;
					}

					// 写入 post 数据
					if (postData != null) {
						byte[] postBytes = Encoding.UTF8.GetBytes (postData);
						requestStream = m_request.GetRequestStream ();
						requestStream.Write (postBytes, 0, postBytes.Length);
						requestStream.Close ();
					}
				}
			} catch (Exception e) {
				if (requestStream != null)
					requestStream.Close ();
				
				DoCallback (HttpException.SEND_REQUEST, e.Message);
				return;
			}


			// 被取消了
			if (!m_requesting) {
				DoCallback (HttpException.ABORTED);
				return;
			}


			HttpWebResponse response = null;
			Stream responseStream = null;
			StreamReader readStream = null;
			try {
				// 获取响应内容
				response = (HttpWebResponse)m_request.GetResponse ();

				// 被取消了
				if (!m_requesting) {
					response.Close ();
					DoCallback (HttpException.ABORTED);
					return;
				}

				int statusCode = (int)response.StatusCode;
				// 只获取 response handers (content length)
				if (method == HttpRequestMethod.HEAD) {
					DoCallback (statusCode, response.ContentLength.ToString ());
					return;
				}

				// 读取内容
				responseStream = response.GetResponseStream ();
				readStream = new StreamReader (responseStream, Encoding.UTF8);
				string content = readStream.ReadToEnd ();

				readStream.Close ();
				responseStream.Close ();
				response.Close ();

				DoCallback (statusCode, content);

			} catch (Exception e) {
				if (readStream != null)
					readStream.Close ();
				if (responseStream != null)
					responseStream.Close ();
				if (response != null)
					response.Close ();

				if (e is WebException) {
					response = (e as WebException).Response as HttpWebResponse;
					if (response != null)
						DoCallback ((int)response.StatusCode, e.Message);
					else
						DoCallback (HttpException.GET_RESPONSE, e.Message);
				} else {
					DoCallback (HttpException.GET_RESPONSE, e.Message);
				}
			}
		}


		/// <summary>
		/// 执行回调
		/// </summary>
		/// <param name="statusCode">Status code.</param>
		/// <param name="content">Content.</param>
		private void DoCallback (int statusCode, string content = "")
		{
			if (m_request != null) {
				m_request.Abort ();
				m_request = null;
			}
			m_requesting = false;

			if (callback != null) {
				Common.threadMgr.addActionToMainThread (() => {
					callback (statusCode, content);
				});
			}
		}


		/// <summary>
		/// 取消正在发送的请求
		/// </summary>
		public void Abort ()
		{
			m_requesting = false;
			if (m_request != null)
				m_request.Abort ();
		}


		/// <summary>
		/// 是否正在发送请求中
		/// </summary>
		/// <value><c>true</c> if requeting; otherwise, <c>false</c>.</value>
		public bool requeting {
			get{ return m_requesting; }
		}




		/// <summary>
		/// 对传入的 str 进行 url 编码，并返回编码后的字符串
		/// </summary>
		/// <returns>The encode.</returns>
		/// <param name="str">String.</param>
		private static string UrlEncode (string str)
		{
			StringBuilder sb = new StringBuilder ();
			byte[] bytes = Encoding.UTF8.GetBytes (str);
			foreach (byte b in bytes) {
				sb.Append (@"%" + Convert.ToString (b, 16));
			}
			return sb.ToString ();
		}


		//
	}
}

