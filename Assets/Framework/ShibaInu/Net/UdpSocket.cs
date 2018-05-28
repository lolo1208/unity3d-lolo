using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Net;
using LuaInterface;


namespace ShibaInu
{

	public class UdpSocket
	{
		/// SocketEvent.lua
		private static readonly LuaFunction s_dispatchEvent = Common.luaMgr.state.GetFunction ("SocketEvent.DispatchEvent");
		/// 需要 Update() 的 UdpSocket 列表
		private static List<UdpSocket> s_updateList = new List<UdpSocket> ();

		/// 锁对象
		private readonly System.Object LOCK_OBJECT = new System.Object ();

		/// 对应的 UdpSocket.lua 实例
		public LuaTable luaTarget;
		/// C# 事件回调函数
		public Action<string, System.Object> callback;


		private UdpClient m_client;
		private KCP m_kcp;
		private bool m_updateDirty;
		private UInt32 m_nextUpdateTime;


		/// 消息协议处理对象。默认使用 StringMsgProtocol
		public IMsgProtocol msgProtocol {
			set { 
				m_msgProtocol = value;
				m_msgProtocol.onMessage = OnMessage;
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


		/// 当前连接使用的会话编号
		public UInt32 conv {
			get { return m_conv; }
		}

		private UInt32 m_conv = 0;


		/// 是否已经建立好连接了（已指定主机和端口）
		public bool connected {
			get {
				if (m_client == null)
					return false;
				return m_client.Client.Connected;
			}
		}



		public UdpSocket ()
		{
			msgProtocol = new StringMsgProtocol ();
		}



		/// <summary>
		/// 连接指定主机和端口（稍后向该地址发送数据）
		/// </summary>
		/// <param name="host">Host.</param>
		/// <param name="port">Port.</param>
		public void Connect (string host, int port, UInt32 conv)
		{
			Close ();

			m_conv = conv;
			m_kcp = new KCP (m_conv, OnKcpOutput);
			// fast mode.
			m_kcp.NoDelay (1, 1, 2, 1);
			m_kcp.WndSize (128, 128);

			try {
				m_client = new UdpClient (host, port);
				m_client.Connect (IPAddress.Parse (host), port);
				m_client.BeginReceive (new AsyncCallback (OnReceive), m_client);

				if (!s_updateList.Contains (this))
					s_updateList.Add (this);
				
				DispatchEvent (SocketEvent.CONNECTED);

			} catch (Exception e) {
				Close ("Error - Connect: " + e.Message);
				DispatchEvent (SocketEvent.CONNECT_FAIL, e.Message);
			}
		}


		/// <summary>
		/// UdpClient 收到数据
		/// </summary>
		/// <param name="ar">Ar.</param>
		private void OnReceive (IAsyncResult ar)
		{
			UdpClient client = (UdpClient)ar.AsyncState;
			lock (LOCK_OBJECT) {

				try {
					// 不是当前连接
					if (client != m_client) {
						client.Close ();
						return;
					}

					IPEndPoint remoteEP = null;
					Byte[] data = client.EndReceive (ar, ref remoteEP);
					m_kcp.Input (data);
					for (int size = m_kcp.PeekSize (); size > 0; size = m_kcp.PeekSize ()) {
						var buffer = new byte[size];
						if (m_kcp.Recv (buffer) > 0) {
							m_msgProtocol.Receive (buffer, buffer.Length);
						}
					}
					m_updateDirty = true;

					// 继续等待异步 OnReceive
					m_client.BeginReceive (new AsyncCallback (OnReceive), m_client);
				} catch (Exception e) {
					Close ("Error - OnReceive: " + e.Message);
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
			if (m_client == null || !m_client.Client.Connected)
				return;

			byte[] buffer = m_msgProtocol.Encode (data);
			m_kcp.Send (buffer);
			m_updateDirty = true;
			Update ();
		}


		private void OnKcpOutput (byte[] buffer, int size)
		{
			m_client.BeginSend (buffer, size, new AsyncCallback (OnSend), m_client);
		}


		private void OnSend (IAsyncResult ar)
		{
			UdpClient client = (UdpClient)ar.AsyncState;
			lock (LOCK_OBJECT) {
				
				try {
					client.EndSend (ar);
				} catch (Exception e) {
					UnityEngine.Debug.Log ("UdpSocket.OnSend() Exception:" + e.Message);
				}

			}
		}




		/// <summary>
		/// Update KCP
		/// </summary>
		public void Update ()
		{
			if (m_kcp == null)
				return;
			
			UInt32 current = TimeUtil.timeMsec;
			if (m_updateDirty || current >= m_nextUpdateTime) {
				m_kcp.Update (current);
				m_nextUpdateTime = m_kcp.Check (current);
				m_updateDirty = false;
			}
		}


		/// <summary>
		/// 更新所有活跃的 UdpSocket
		/// </summary>
		public static void UpdateAll ()
		{
			foreach (UdpSocket udp in s_updateList)
				udp.Update ();
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
			bool connected = false;
			if (m_client != null) {
				connected = true;
				m_client.Close ();
				m_client = null;
				m_kcp = null;

				s_updateList.Remove (this);
			}

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
			Common.looper.AddNetAction (() => {
				if (callback != null)
					callback (type, data);

				if (luaTarget != null) {
					s_dispatchEvent.BeginPCall ();
					s_dispatchEvent.Push (luaTarget);
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

