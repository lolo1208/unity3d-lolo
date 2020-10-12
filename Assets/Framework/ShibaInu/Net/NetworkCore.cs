using System;


namespace ShibaInu
{

    /// <summary>
    /// Http 请求方式常量
    /// </summary>
    public static class HttpRequestMethod
    {
        /// POST
        public const string POST = "POST";
        /// GET
        public const string GET = "GET";
        /// 只获取 response handers (content length)
        public const string HEAD = "HEAD";
    }



    /// <summary>
    /// Http 请求异常状态码常量
    /// </summary>
    public static class HttpExceptionStatusCode
    {
        /// 创建线程时发生异常
        public const int CREATE_THREAD = -1;
        /// 发送请求时发生异常
        public const int SEND_REQUEST = -2;
        /// 获取内容时发生异常
        public const int GET_RESPONSE = -3;
        /// 发送请求或获取内容过程中被取消了
        public const int ABORTED = -4;
        /// 获取目标文件大小时发生异常
        public const int GET_HEAD = -5;
        /// 要上传的本地文件不存在
        public const int FILE_ERROE = -6;
    }



    /// <summary>
    /// Socket 相关事件常量
    /// </summary>
    public static class SocketEvent
    {
        /// 连接成功
        public const string CONNECTED = "SocketEvent_Connected";
        /// 连接失败
        public const string CONNECT_FAIL = "SocketEvent_ConnectFail";
        /// 断开连接
        public const string DISCONNECT = "SocketEvent_Disconnect";
        /// 收到消息
        public const string MESSAGE = "SocketEvent_Message";
    }



    /// <summary>
    /// Socket 接口
    /// </summary>
    public interface ISocket
    {
        /// 消息协议处理对象。默认使用 StringMsgProtocol
        IMsgProtocol msgProtocol { set; }

        /// 当前连接的主机地址
        string host { get; }
        /// 当前连接的端口
        int port { get; }
        /// 是否已经建立好连接了
        bool connected { get; }


        /// 发送数据
        void Send(object data);

        /// 关闭当前连接
        void Close();
    }



    /// <summary>
    /// Socket 消息协议接口
    /// </summary>
    public interface IMsgProtocol
    {
        /// 收到消息的回调。Receive() 解包出一条消息时的回调
        Action<object> OnMessage { set; get; }

        /// 接收数据，处理粘包，根据协议解析出消息，并回调 messageCallback
        void Receive(byte[] buffer, int length);

        /// 重置（清空）已收到的数据包。在连接关闭时会被 SocketClient 调用
        void Reset();

        /// 根据协议编码 data，并返回编码后的字节数组
        byte[] Encode(object data);
    }



}

