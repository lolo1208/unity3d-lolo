using System;
using System.Net.Sockets;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{



	/// <summary>
	/// 消息协议接口
	/// </summary>
	public interface IMsgProtocol
	{
		/// 收到消息的回调。Receive() 解包出一条消息时的回调
		Action<System.Object> messageCallback{ set; get; }

		/// 接收数据，处理粘包，根据协议解析出消息，并回调 messageCallback
		void Receive (byte[] buffer, int length);

		/// 重置（清空）已收到的数据包。在连接关闭时会被 TcpSocketClient 调用
		void Reset ();

		/// 根据协议编码 data，并返回编码后的字节数组
		byte[] Encode (System.Object data);
	}



	/// <summary>
	/// Socket 相关事件
	/// </summary>
	public class SocketEvent
	{
		public const string CONNECTED = "SocketEvent_Connected";
		public const string CONNECT_FAIL = "SocketEvent_ConnectFail";
		public const string DISCONNECT = "SocketEvent_Disconnect";
		public const string MESSAGE = "SocketEvent_Message";
	}



	/// <summary>
	/// Tcp socket client.
	/// </summary>
	public class TcpSocketClient
	{
		/// 读取数据的 buffer 尺寸
		private const int BUFFER_SIZE = 8192;

		/// SocketEvent.lua
		private static readonly LuaFunction s_dispatchEvent = Common.luaMgr.state.GetFunction ("SocketEvent.DispatchEvent");

		/// 锁对象
		private readonly System.Object LOCK_OBJECT = new System.Object ();


		/// 连接超时时长
		public int connentTimeout = 2000;
		/// 发送数据超时时长
		public int sendTimeout = 1000;
		/// 读取数据超时时长
		public int receiveTimeout = 1000;

		/// 对应的 TcpSocketClient.lua 实例
		public LuaTable luaClient;
		/// C# 事件回调函数
		public Action<string, System.Object> eventCallback;


		private TcpClient m_client;
		private NetworkStream m_stream;
		private byte[] m_readBuffer = new byte[BUFFER_SIZE];


		/// 消息协议处理对象。默认使用 StringMsgProtocol
		public IMsgProtocol msgProtocol {
			set { 
				m_msgProtocol = value;
				m_msgProtocol.messageCallback = OnMessage;
			}
			get{ return m_msgProtocol; }
		}

		private IMsgProtocol m_msgProtocol;


		/// 当前连接的主机地址
		public string host {
			get { return m_host; }
		}

		private string m_host = null;


		/// 当前连接的端口
		public int port {
			get { return m_port; }
		}

		private int m_port = 0;


		/// 是否正在建立连接中
		public bool connected {
			get{ return m_connected; }
		}

		private bool m_connected = false;


		/// 是否已经建立好连接了
		public bool connecting {
			get{ return m_connecting; }
		}

		private bool m_connecting = false;



		public TcpSocketClient ()
		{
			msgProtocol = new StringMsgProtocol ();
		}



		/// <summary>
		/// 连接指定主机和端口
		/// </summary>
		/// <param name="host">Host.</param>
		/// <param name="port">Port.</param>
		public void Content (string host, int port)
		{
			Close ();

			m_client = new TcpClient ();
			m_client.SendTimeout = sendTimeout;
			m_client.ReceiveTimeout = receiveTimeout;
			m_client.NoDelay = true;
			m_connecting = true;

			try {
				m_client.BeginConnect (host, port, new AsyncCallback (OnConnected), m_client);
				Common.timerMgr.Once (connentTimeout, OnConnectTimeout, m_client);

			} catch (Exception e) {
				Close ("Error - Content: " + e.Message);
				DispatchEvent (SocketEvent.CONNECT_FAIL, e.Message);
			}
		}


		/// <summary>
		/// 连接成功
		/// </summary>
		/// <param name="ar">Ar.</param>
		private void OnConnected (IAsyncResult ar)
		{
			TcpClient client = (TcpClient)ar.AsyncState;

			lock (LOCK_OBJECT) {
				
				try {
					client.EndConnect (ar);

					// 不是当前 TcpClient。可能是连接过程中切换了 host 或 连接超时
					if (client != m_client) {
						client.Close ();
						return;
					}

					m_connected = true;
					m_connecting = false;
					m_stream = client.GetStream ();
					m_stream.BeginRead (m_readBuffer, 0, BUFFER_SIZE, new AsyncCallback (OnRead), client);

					DispatchEvent (SocketEvent.CONNECTED);
				} catch (Exception e) {
					DispatchEvent (SocketEvent.CONNECT_FAIL, e.Message);
				}

			}
		}


		/// <summary>
		/// 连接超时
		/// </summary>
		/// <param name="timer">Timer.</param>
		private void OnConnectTimeout (Timer timer)
		{
			lock (LOCK_OBJECT) {
				
				TcpClient client = (TcpClient)timer.data;
				if (client != m_client)
					return;// 不是当前 TcpClient

				if (m_connecting)
					Close ();

			}
		}



		/// <summary>
		/// 有读取到数据
		/// </summary>
		/// <param name="ar">Ar.</param>
		private void OnRead (IAsyncResult ar)
		{
			TcpClient client = (TcpClient)ar.AsyncState;
			NetworkStream stream = null;
			lock (LOCK_OBJECT) {
				
				try {
					stream = client.GetStream ();
					int bytesRead = stream.EndRead (ar);

					// 不是当前连接
					if (client != m_client) {
						stream.Close ();
						client.Close ();
						return;
					}

					// 服务端主动断开了连接
					if (bytesRead == 0) {
						Close ("Server Closed");
						return;
					}

					// 接收数据，清空 buffer，继续等待异步 OnRead
					m_msgProtocol.Receive (m_readBuffer, bytesRead);
//					Array.Clear (m_readBuffer, 0, BUFFER_SIZE);
					m_stream.BeginRead (m_readBuffer, 0, BUFFER_SIZE, new AsyncCallback (OnRead), client);

				} catch (Exception e) {
					if (client == m_client) {
						Close ("Error - OnRead: " + e.Message);
					} else {
						if (stream != null)
							stream.Close ();
						client.Close ();
					}
				}

			}
		}


		/// <summary>
		/// msgProtocol 解包出一条消息时的回调
		/// </summary>
		/// <param name="data">Data.</param>
		private void OnMessage (System.Object data)
		{
			lock (LOCK_OBJECT) {
				
				DispatchEvent (SocketEvent.MESSAGE, data);

			}
		}


		/// <summary>
		/// 发送数据
		/// </summary>
		/// <param name="data">Data.</param>
		public void Send (System.Object data)
		{
			if (!m_connected)
				return;
			
			lock (LOCK_OBJECT) {

				try {
					byte[] buffer = m_msgProtocol.Encode (data);
					m_stream.BeginWrite (buffer, 0, buffer.Length, new AsyncCallback (OnWrite), m_client);
				} catch (Exception e) {
					Close ("Error - Send: " + e.Message);
				}

			}
		}


		private void OnWrite (IAsyncResult ar)
		{
			TcpClient client = (TcpClient)ar.AsyncState;
			lock (LOCK_OBJECT) {

				try {
					if (client == m_client)
						m_stream.EndWrite (ar);
					else
						client.GetStream ().EndWrite (ar);
					
				} catch (Exception e) {
					if (client == m_client)
						Close ("Error - OnWrite: " + e.Message);
				}

			}
		}



		/// <summary>
		/// 关闭当前连接
		/// </summary>
		public void Close ()
		{
			Close ("Client Close");
		}


		private void Close (string msg)
		{
			if (m_stream != null) {
				m_stream.Close ();
				m_stream = null;
			}
			
			if (m_client != null) {
				m_client.Close ();
				m_client = null;
			}

			bool connected = m_connected;
			m_connecting = m_connected = false;

			if (connected) {
				m_msgProtocol.Reset ();
				DispatchEvent (SocketEvent.DISCONNECT, msg);
			}
		}


		/// <summary>
		/// 抛出事件
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="data">Data.</param>
		private void DispatchEvent (string type, System.Object data = null)
		{
			Common.threadMgr.AddActionToMainThread (() => {
				if (eventCallback != null)
					eventCallback (type, data);

				if (luaClient != null) {
					s_dispatchEvent.BeginPCall ();
					s_dispatchEvent.Push (luaClient);
					s_dispatchEvent.Push (type);
					s_dispatchEvent.Push (data);
					s_dispatchEvent.PCall ();
					s_dispatchEvent.EndPCall ();
				}
			});
		}


		//
	}
}

