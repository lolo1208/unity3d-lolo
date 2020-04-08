#define REIGN_MSG_PROTOCOL_CLUSTER


using System;
using System.IO;
using System.Text;
using MiscUtil.IO;
using MiscUtil.Conversion;
using ICSharpCode.SharpZipLib.Zip.Compression;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 锐战消息协议
    /// </summary>
    public class ReignMsgProtocol : IMsgProtocol
    {
        private readonly MemoryStream m_stream;
        private readonly EndianBinaryReader m_reader;

        /// 接收到的消息内容是否需要解压缩
        public bool isCompress;


        public ReignMsgProtocol(bool isCompress = false)
        {
            this.isCompress = isCompress;
            m_stream = new MemoryStream();
            m_reader = new EndianBinaryReader(EndianBitConverter.Big, m_stream);
        }


        [NoToLua]
        public Action<object> OnMessage { set; get; }


        [NoToLua]
        public void Receive(byte[] buffer, int length)
        {
            // 索引到尾部，写入数据
            m_stream.Seek(0, SeekOrigin.End);
            m_stream.Write(buffer, 0, length);

            // 索引到头部，尝试解析消息
            m_stream.Seek(0, SeekOrigin.Begin);
            while (GetDataLength() > 4)
            {
                int dataLen = m_reader.ReadInt32();
                if (GetDataLength() >= dataLen)
                {
                    OnMessage(new ReignMsgResponse(m_reader, dataLen, isCompress));
                }
                else
                {
                    m_stream.Position -= 4;
                    break;
                }
            }

            // 读取剩余内容到包头
            int len = (int)GetDataLength();
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


        [NoToLua]
        public byte[] Encode(object data)
        {
            return ((ReignMsgRequest)data).GetBytes();
        }


        [NoToLua]
        public void Reset()
        {
            m_stream.SetLength(0);
        }


        /// <summary>
        /// 缓冲区剩余字节
        /// </summary>
        private long GetDataLength()
        {
            return m_stream.Length - m_stream.Position;
        }


        //
    }



    /// <summary>
    /// 请求数据
    /// </summary>
    public class ReignMsgRequest
    {
        // 包的类型 [ 1:请求包 ]
        public byte packageType = 1;
        // 服务器类型
        public int serverType;
        // 服务器 ID
        public int serverId;
        // 命令
        public string command;
        // 请求 ID
        public int requestId;
        // 内容
        public string content;


        public ReignMsgRequest(int serverType, int serverId, string command, string content, int requestId)
        {
            this.serverType = serverType;
            this.serverId = serverId;
            this.command = command;
            this.content = content;
            this.requestId = requestId;
        }


        [NoToLua]
        public byte[] GetBytes()
        {
            MemoryStream stream = new MemoryStream();
            EndianBinaryWriter writer = new EndianBinaryWriter(EndianBitConverter.Big, stream);

#if REIGN_MSG_PROTOCOL_CLUSTER
            writer.Write(packageType);
            writer.Write(serverType);
            writer.Write(serverId);
#endif

            byte[] commandBytes = Encoding.UTF8.GetBytes(command);
            byte[] bytes = new byte[32];
            Array.Copy(commandBytes, bytes, commandBytes.Length);
            writer.Write(bytes);

            writer.Write(requestId);

            bytes = Encoding.UTF8.GetBytes(content);
            writer.Write(bytes);

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

            return bytes;
        }
    }



    /// <summary>
    /// 响应数据
    /// </summary>
    public class ReignMsgResponse
    {
        // 命令
        public string command;
        // 请求 ID
        public int requestId;
        // 内容
        public string content;

        [NoToLua]
        public ReignMsgResponse(EndianBinaryReader reader, int dataLen, bool isCompress)
        {

#if REIGN_MSG_PROTOCOL_CLUSTER
            reader.ReadByte();// packageType
#endif

            byte[] bytes = reader.ReadBytes(32);
            command = Encoding.UTF8.GetString(bytes);
            command = command.Trim('\0');

            requestId = reader.ReadInt32();

#if REIGN_MSG_PROTOCOL_CLUSTER
            bytes = reader.ReadBytes(dataLen - 37);
#else
            bytes = reader.ReadBytes(dataLen - 36);
#endif
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
        }

    }

}

