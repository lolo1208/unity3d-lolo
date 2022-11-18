using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Net;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{

    public class UdpSocket : ISocket
    {
        /// SocketEvent.lua
        private static LuaFunction s_dispatchEvent;
        /// 需要 UpdateKcp() 的 UdpSocket 列表
        private static readonly List<UdpSocket> s_updateList = new List<UdpSocket>();

        /// 锁对象
        private readonly object LOCK_OBJECT = new object();

        /// 对应的 UdpSocket.lua 实例
        public LuaTable luaTarget;
        /// C# 事件回调函数
        public Action<string, object> callback;


        private UdpClient m_client;
        private KCP m_kcp;
        private bool m_updateDirty;
        private uint m_nextUpdateTime;


        /// 消息协议处理对象。默认使用 StringMsgProtocol
        public IMsgProtocol msgProtocol
        {
            set
            {
                m_msgProtocol = value;
                m_msgProtocol.OnMessage = OnMessage;
            }
            get { return m_msgProtocol; }
        }

        private IMsgProtocol m_msgProtocol;


        /// 当前连接的主机地址
        public string host { get; private set; }


        /// 当前连接的端口
        public int port { get; private set; }


        /// 当前连接使用的会话编号
        public uint conv { get; private set; }


        /// 是否已经建立好连接了（已指定主机和端口）
        public bool connected
        {
            get
            {
                if (m_client == null)
                    return false;
                return m_client.Client.Connected;
            }
        }




        public UdpSocket()
        {
            msgProtocol = new StringMsgProtocol();
        }



        /// <summary>
        /// 连接指定主机和端口（稍后向该地址发送数据）
        /// </summary>
        /// <param name="host"></param>
        /// <param name="port"></param>
        /// <param name="conv"></param>
        public void Connect(string host, int port, uint conv)
        {
            Close();

            this.host = host;
            this.port = port;
            this.conv = conv;

            // fast mode.
            m_kcp = new KCP(this.conv, OnKcpOutput);
            m_kcp.NoDelay(1, 1, 2, 1);
            m_kcp.WndSize(128, 128);

            try
            {
                m_client = new UdpClient(host, port);
                m_client.Connect(IPAddress.Parse(host), port);
                m_client.BeginReceive(new AsyncCallback(OnReceive), m_client);

                if (!s_updateList.Contains(this))
                    s_updateList.Add(this);

                DispatchEvent(SocketEvent.CONNECTED);

            }
            catch (Exception e)
            {
                Close("Error - Connect: " + e.Message);
                DispatchEvent(SocketEvent.CONNECT_FAIL, e.Message);
            }
        }


        /// <summary>
        /// UdpClient 收到数据
        /// </summary>
        /// <param name="ar">Ar.</param>
        private void OnReceive(IAsyncResult ar)
        {
            UdpClient client = (UdpClient)ar.AsyncState;
            lock (LOCK_OBJECT)
            {

                try
                {
                    // 不是当前连接
                    if (client != m_client)
                    {
                        client.Close();
                        return;
                    }

                    IPEndPoint remoteEP = null;
                    Byte[] data = client.EndReceive(ar, ref remoteEP);
                    m_kcp.Input(data);
                    for (int size = m_kcp.PeekSize(); size > 0; size = m_kcp.PeekSize())
                    {
                        var buffer = new byte[size];
                        if (m_kcp.Recv(buffer) > 0)
                        {
                            m_msgProtocol.Receive(buffer, buffer.Length);
                        }
                    }
                    m_updateDirty = true;

                    // 继续等待异步 OnReceive
                    m_client.BeginReceive(new AsyncCallback(OnReceive), m_client);
                }
                catch (Exception e)
                {
                    Close("Error - OnReceive: " + e.Message);
                }

            }
        }


        /// <summary>
        /// msgProtocol 解包出一条消息时的回调
        /// </summary>
        /// <param name="data">Data.</param>
        private void OnMessage(object data)
        {
            lock (LOCK_OBJECT)
            {

                DispatchEvent(SocketEvent.MESSAGE, data);

            }
        }




        /// <summary>
        /// 发送数据
        /// </summary>
        /// <param name="data">Data.</param>
        public void Send(object data)
        {
            if (m_client == null || !m_client.Client.Connected)
                return;

            byte[] buffer = m_msgProtocol.Encode(data);
            m_kcp.Send(buffer);
            m_updateDirty = true;
            UpdateKcp();
        }


        private void OnKcpOutput(byte[] buffer, int size)
        {
            m_client.BeginSend(buffer, size, new AsyncCallback(OnSend), m_client);
        }


        private void OnSend(IAsyncResult ar)
        {
            UdpClient client = (UdpClient)ar.AsyncState;
            lock (LOCK_OBJECT)
            {

                try
                {
                    client.EndSend(ar);
                }
                catch (Exception e)
                {
                    Debug.LogFormat("[ShibaInu.UdpSocket] OnSend() Exception: {0}", e.Message);
                }

            }
        }




        /// <summary>
        /// Update KCP
        /// </summary>
        [NoToLua]
        public void UpdateKcp()
        {
            if (m_kcp == null)
                return;

            uint current = TimeUtil.timeMsec;
            if (m_updateDirty || current >= m_nextUpdateTime)
            {
                m_updateDirty = false;
                try
                {
                    m_kcp.Update(current);
                    m_nextUpdateTime = m_kcp.Check(current);
                }
                catch (Exception e)
                {
                    Close(e.Message);
                }
            }
        }


        /// <summary>
        /// 更新所有活跃的 UdpSocket
        /// </summary>
        [NoToLua]
        public static void Update()
        {
            for (int i = s_updateList.Count - 1; i >= 0; i--)
                s_updateList[i].UpdateKcp();
        }




        /// <summary>
        /// 关闭当前连接
        /// </summary>
        public void Close()
        {
            Close("Client Close");
        }


        private void Close(string msg)
        {
            bool connected = false;
            if (m_client != null)
            {
                connected = true;
                m_client.Close();
                m_client = null;
                m_kcp = null;

                if (s_updateList.Contains(this))
                    s_updateList.Remove(this);
            }

            if (connected)
            {
                m_msgProtocol.Reset();
                DispatchEvent(SocketEvent.DISCONNECT, msg);
            }
        }




        /// <summary>
        /// 抛出事件
        /// </summary>
        /// <param name="type">Type.</param>
        /// <param name="data">Data.</param>
        private void DispatchEvent(string type, System.Object data = null)
        {
            Common.looper.AddNetAction(() =>
            {
                if (callback != null)
                    callback(type, data);

                if (luaTarget != null)
                {
                    if (s_dispatchEvent == null)
                        s_dispatchEvent = Common.luaMgr.state.GetFunction("SocketEvent.DispatchEvent");
                    s_dispatchEvent.BeginPCall();
                    s_dispatchEvent.Push(luaTarget);
                    s_dispatchEvent.Push(type);
                    s_dispatchEvent.Push(data);
                    s_dispatchEvent.PCall();
                    s_dispatchEvent.EndPCall();
                }
            });
        }



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_dispatchEvent = null;
        }

        #endregion


        //
    }
}

