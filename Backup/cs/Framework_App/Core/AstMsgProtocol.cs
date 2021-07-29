using System;
using System.IO;
using System.Text;
using MiscUtil.IO;
using MiscUtil.Conversion;
using ICSharpCode.SharpZipLib.Zip.Compression;
using LuaInterface;
using ShibaInu;


namespace App
{
    /// <summary>
    /// 傲世堂消息协议
    /// </summary>
    public class AstMsgProtocol : IMsgProtocol
    {
        /// 是否为 cluster 协议
        public bool isCluster;
        /// 接收到的消息内容是否需要解压缩
        public bool isCompress;

        private readonly ISocket m_socket;
        private readonly MemoryStream m_stream;
        private readonly EndianBinaryReader m_reader;
        private readonly LuaFunction m_onMessage;
        private byte[] m_sendData;



        public AstMsgProtocol(ISocket socket, LuaFunction onMessage, bool isCompress = false, bool isCluster = true)
        {
            this.isCompress = isCompress;
            this.isCluster = isCluster;
            m_socket = socket;
            m_onMessage = onMessage;
            m_stream = new MemoryStream();
            m_reader = new EndianBinaryReader(EndianBitConverter.Big, m_stream);
        }



        /// <summary>
        /// 发送数据
        /// </summary>
        /// <param name="serverType">服务器类型</param>
        /// <param name="serverId">服务器 ID</param>
        /// <param name="command">命令名称</param>
        /// <param name="content">发送的内容</param>
        /// <param name="requestId">这条请求的 ID</param>
        /// <param name="packageType">包的类型 [ 1:请求包 ]</param>
        public void Send(int serverType, int serverId, string command, string content, int requestId, byte packageType = 1)
        {
            MemoryStream stream = new MemoryStream();
            EndianBinaryWriter writer = new EndianBinaryWriter(EndianBitConverter.Big, stream);

            // cluster
            if (isCluster)
            {
                writer.Write(packageType);
                writer.Write(serverType);
                writer.Write(serverId);
            }

            // command
            byte[] commandBytes = Encoding.UTF8.GetBytes(command);
            byte[] bytes = new byte[32];
            Array.Copy(commandBytes, bytes, commandBytes.Length);
            writer.Write(bytes);
            // requestId
            writer.Write(requestId);
            // content
            bytes = Encoding.UTF8.GetBytes(content);
            writer.Write(bytes);
            // to bytes and dispose
            writer.Flush();
            bytes = stream.ToArray();
            writer.Dispose();

            // 先写入长度，再写入内容
            stream = new MemoryStream();
            writer = new EndianBinaryWriter(EndianBitConverter.Big, stream);
            writer.Write(bytes.Length);
            writer.Write(bytes);
            writer.Flush();
            bytes = stream.ToArray();
            writer.Dispose();

            m_sendData = bytes;
            m_socket.Send(null);// Send() 传入 null，在Encode() 时，返回封装好的 m_sendData 即可
        }


        [NoToLua]
        public byte[] Encode(object data)
        {
            return m_sendData;
        }


        //


        [NoToLua]
        public void Receive(byte[] buffer, int length)
        {
            // 索引到尾部，写入数据
            m_stream.Seek(0, SeekOrigin.End);
            m_stream.Write(buffer, 0, length);

            // 索引到头部，尝试解析消息
            m_stream.Seek(0, SeekOrigin.Begin);
            while (DataLength > 4)
            {
                int dataLen = m_reader.ReadInt32();
                if (DataLength >= dataLen)
                {
                    ParseResponse(dataLen);
                }
                else
                {
                    m_stream.Position -= 4;
                    break;
                }
            }

            // 读取剩余内容到包头
            int len = DataLength;
            if (len > 0 && m_stream.Position > 0)
            {
                byte[] leftBytes = m_reader.ReadBytes(len);
                m_stream.SetLength(0);
                m_stream.Seek(0, SeekOrigin.Begin);
                m_stream.Write(leftBytes, 0, leftBytes.Length);
            }
            else if (len == 0)
            {
                m_stream.SetLength(0);
            }
        }


        /// <summary>
        /// 解析服务端传来的响应数据包
        /// </summary>
        /// <param name="dataLen"></param>
        private void ParseResponse(int dataLen)
        {
            // packageType
            if (isCluster) m_reader.ReadByte();

            // command
            byte[] bytes = m_reader.ReadBytes(32);
            string command = Encoding.UTF8.GetString(bytes);
            command = command.Trim('\0');

            // requestId
            int requestId = m_reader.ReadInt32();

            // content
            string content;
            bytes = m_reader.ReadBytes(dataLen - (isCluster ? 37 : 36));
            if (isCompress)
            {
                try
                {
                    using (MemoryStream output = new MemoryStream())
                    {
                        Inflater inflater = new Inflater();
                        inflater.SetInput(bytes);
                        int len = -1;
                        byte[] buff = new byte[2048];
                        while (!inflater.IsFinished)
                        {
                            len = inflater.Inflate(buff);
                            output.Write(buff, 0, len);
                        }
                        content = Encoding.UTF8.GetString(output.ToArray());
                    }
                }
                catch (Exception e)
                {
                    content = "uncompress error: " + e;
                }
            }
            else
            {
                content = Encoding.UTF8.GetString(bytes);
            }

            // 在主线程调用 lua OnMessage 回调
            Common.looper.AddNetAction(() =>
            {
                m_onMessage.BeginPCall();
                m_onMessage.Push(command);
                m_onMessage.Push(requestId);
                m_onMessage.Push(content);
                m_onMessage.PCall();
                m_onMessage.EndPCall();
            });
        }


        /// <summary>
        /// 缓冲区剩余字节长度
        /// </summary>
        private int DataLength
        {
            get
            {
                return (int)(m_stream.Length - m_stream.Position);
            }
        }


        //


        [NoToLua]
        public Action<object> OnMessage { set; get; }


        [NoToLua]
        public void Reset()
        {
            m_sendData = null;
            m_stream.SetLength(0);
        }


        //
    }
}