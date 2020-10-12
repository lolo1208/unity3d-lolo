using System;
using System.Net.Sockets;
using LuaInterface;


namespace ShibaInu
{

    /// <summary>
    /// Tcp socket client.
    /// </summary>
    public class TcpSocket : ISocket
    {
        /// 读取数据的 buffer 尺寸
        private const int BUFFER_SIZE = 8192;
        /// SocketEvent.lua
        private static LuaFunction s_dispatchEvent;

        /// 锁对象
        private readonly object LOCK_OBJECT = new object();


        /// 连接超时时长
        public int connentTimeout = 2000;
        /// 发送数据超时时长
        public int sendTimeout = 1000;
        /// 读取数据超时时长
        public int receiveTimeout = 1000;

        /// 对应的 TcpSocket.lua 实例
        public LuaTable luaTarget;
        /// C# 事件回调函数
        public Action<string, object> callback;


        private readonly byte[] m_readBuffer = new byte[BUFFER_SIZE];
        private TcpClient m_client;
        private NetworkStream m_stream;


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


        /// 是否正在建立连接中
        public bool connecting { get; private set; }


        /// 是否已经建立好连接了
        public bool connected { get; private set; }




        public TcpSocket()
        {
            msgProtocol = new StringMsgProtocol();
        }



        /// <summary>
        /// 连接指定主机和端口
        /// </summary>
        /// <param name="host">Host.</param>
        /// <param name="port">Port.</param>
        public void Connect(string host, int port)
        {
            Close();

            this.host = host;
            this.port = port;

            m_client = new TcpClient
            {
                SendTimeout = sendTimeout,
                ReceiveTimeout = receiveTimeout,
                NoDelay = true
            };
            connecting = true;

            try
            {
                m_client.BeginConnect(host, port, new AsyncCallback(OnConnected), m_client);
                Timer.Once(connentTimeout, OnConnectTimeout, m_client);

            }
            catch (Exception e)
            {
                Close("Error - Content: " + e.Message);
                DispatchEvent(SocketEvent.CONNECT_FAIL, e.Message);
            }
        }


        /// <summary>
        /// 连接成功
        /// </summary>
        /// <param name="ar">Ar.</param>
        private void OnConnected(IAsyncResult ar)
        {
            TcpClient client = (TcpClient)ar.AsyncState;

            lock (LOCK_OBJECT)
            {

                try
                {
                    client.EndConnect(ar);

                    // 不是当前 TcpClient。可能是连接过程中切换了 host 或 连接超时
                    if (client != m_client)
                    {
                        client.Close();
                        return;
                    }

                    connected = true;
                    connecting = false;
                    m_stream = client.GetStream();
                    m_stream.BeginRead(m_readBuffer, 0, BUFFER_SIZE, new AsyncCallback(OnRead), client);

                    DispatchEvent(SocketEvent.CONNECTED);
                }
                catch (Exception e)
                {
                    DispatchEvent(SocketEvent.CONNECT_FAIL, e.Message);
                }

            }
        }


        /// <summary>
        /// 连接超时
        /// </summary>
        /// <param name="timer">Timer.</param>
        private void OnConnectTimeout(Timer timer)
        {
            lock (LOCK_OBJECT)
            {

                TcpClient client = (TcpClient)timer.data;
                if (client != m_client)
                    return;// 不是当前 TcpClient

                if (connecting)
                    Close();

            }
        }



        /// <summary>
        /// 有读取到数据
        /// </summary>
        /// <param name="ar">Ar.</param>
        private void OnRead(IAsyncResult ar)
        {
            TcpClient client = (TcpClient)ar.AsyncState;
            NetworkStream stream = null;
            lock (LOCK_OBJECT)
            {

                try
                {
                    stream = client.GetStream();
                    int bytesRead = stream.EndRead(ar);

                    // 不是当前连接
                    if (client != m_client)
                    {
                        stream.Close();
                        client.Close();
                        return;
                    }

                    // 服务端主动断开了连接
                    if (bytesRead == 0)
                    {
                        Close("Server Closed");
                        return;
                    }

                    // 接收数据，清空 buffer，继续等待异步 OnRead
                    m_msgProtocol.Receive(m_readBuffer, bytesRead);
                    //Array.Clear (m_readBuffer, 0, BUFFER_SIZE);
                    m_stream.BeginRead(m_readBuffer, 0, BUFFER_SIZE, new AsyncCallback(OnRead), client);

                }
                catch (Exception e)
                {
                    if (client == m_client)
                    {
                        Close("Error - OnRead: " + e.Message);
                    }
                    else
                    {
                        if (stream != null)
                            stream.Close();
                        client.Close();
                    }
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
            if (!connected)
                return;

            lock (LOCK_OBJECT)
            {

                try
                {
                    byte[] buffer = m_msgProtocol.Encode(data);
                    m_stream.BeginWrite(buffer, 0, buffer.Length, new AsyncCallback(OnWrite), m_client);
                }
                catch (Exception e)
                {
                    Close("Error - Send: " + e.Message);
                }

            }
        }


        private void OnWrite(IAsyncResult ar)
        {
            TcpClient client = (TcpClient)ar.AsyncState;
            lock (LOCK_OBJECT)
            {

                try
                {
                    if (client == m_client)
                        m_stream.EndWrite(ar);
                    else
                        client.GetStream().EndWrite(ar);

                }
                catch (Exception e)
                {
                    if (client == m_client)
                        Close("Error - OnWrite: " + e.Message);
                }

            }
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
            if (m_stream != null)
            {
                m_stream.Close();
                m_stream = null;
            }

            if (m_client != null)
            {
                m_client.Close();
                m_client = null;
            }

            bool connected = this.connected;
            connecting = this.connected = false;

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
        private void DispatchEvent(string type, object data = null)
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

