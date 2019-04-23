using System;
using System.Text;
using System.IO;
using UnityEngine;
using UnityEngine.Profiling;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// Lua profiler 工具
    /// </summary>
    public class LuaProfiler : MonoBehaviour
    {
        private static UdpSocket s_udp;
        private static TcpSocket s_tcp;
        private static bool s_isUDP;
        private static readonly StringBuilder s_sb = new StringBuilder();

        // - Utils/Optimize/Profiler.lua
        private static LuaFunction s_luaBegin;
        private static LuaFunction s_luaEnd;
        private static LuaFunction s_luaGetData;



        void Awake()
        {
            s_luaBegin = Common.luaMgr.state.GetFunction("Profiler.Begin");
            s_luaEnd = Common.luaMgr.state.GetFunction("Profiler.End");
            s_luaGetData = Common.luaMgr.state.GetFunction("Profiler.GetData");
        }


        /// <summary>
        /// 每帧收集数据
        /// </summary>
        void LateUpdate()
        {
            s_luaGetData.BeginPCall();
            s_luaGetData.PCall();
            string data = s_luaGetData.CheckString();
            s_luaGetData.EndPCall();

            s_sb.Clear();
            s_sb.Append("{\"f\":");// 帧编号
            s_sb.Append(Time.frameCount);

            s_sb.Append(",\"r\":");// 帧率
            s_sb.Append(1 / Time.deltaTime);

            // s_sb.Append (",\"m\":");// 已申请最大内存量
            // s_sb.Append (Profiler.GetTotalReservedMemoryLong () * 1f / 1024 / 1024);

            s_sb.Append(",\"c\":");// 当前使用内存
            s_sb.Append(Profiler.GetTotalAllocatedMemoryLong() * 1f / 1024 / 1024);

            s_sb.Append(",\"d\":");// 统计数据
            s_sb.Append(data);
            s_sb.Append("}");

            if (s_isUDP)
                s_udp.Send(s_sb.ToString());
            else
                s_tcp.Send(s_sb.ToString());
            s_sb.Clear();
        }



        /// <summary>
        /// 连接到工具服务端，开始收集数据
        /// </summary>
        /// <param name="host">Host.</param>
        /// <param name="port">Port.</param>
        /// <param name="isUDP">If set to <c>true</c> is UD.</param>
        public static void Begin(string host, int port, bool isUDP)
        {
            GameObject go = Common.go;
            LuaProfiler profiler = go.GetComponent<LuaProfiler>();
            if (profiler == null)
                profiler = go.AddComponent<LuaProfiler>();
            else
            {
                if (profiler.enabled)
                    return;
                profiler.enabled = true;
            }

            s_isUDP = isUDP;
            if (isUDP)
            {
                if (s_udp == null)
                {
                    s_udp = new UdpSocket { callback = EventCallback };
                }
                s_udp.Connect(host, port, (uint)port);

            }
            else
            {
                if (s_tcp == null)
                {
                    s_tcp = new TcpSocket { callback = EventCallback };
                }
                s_tcp.Connect(host, port);
            }

            s_luaBegin.BeginPCall();
            s_luaBegin.PCall();
            s_luaBegin.EndPCall();

            Logger.Log("Begin!", "LuaProfiler");
        }


        /// <summary>
        /// 结束数据收集
        /// </summary>
        public static void End()
        {
            GameObject go = Common.go;
            LuaProfiler profiler = go.GetComponent<LuaProfiler>();
            if (profiler == null || !profiler.enabled)
                return;

            profiler.enabled = false;
            if (s_isUDP)
            {
                if (s_udp != null)
                    s_udp.Close();
            }
            else
            {
                if (s_tcp != null)
                    s_tcp.Close();
            }

            s_luaEnd.BeginPCall();
            s_luaEnd.PCall();
            s_luaEnd.EndPCall();

            Logger.Log("Stopped!", "LuaProfiler");
        }



        /// <summary>
        /// 显示或隐藏对应的控制台
        /// </summary>
        /// <param name="show">If set to <c>true</c> show.</param>
        public static void Console(bool show)
        {
            GameObject go = Common.go;
            LuaProfilerConsole console = go.GetComponent<LuaProfilerConsole>();
            if (show)
            {
                if (console == null)
                    console = go.AddComponent<LuaProfilerConsole>();
                if (!console.enabled)
                    console.enabled = true;
            }
            else
            {
                if (console != null && console.enabled)
                    console.enabled = false;
            }
        }



        private static void EventCallback(string type, object data)
        {
            if (data != null)
                Logger.Log("SocketEvent [" + type + "]: " + data, "LuaProfiler");
            else
                Logger.Log("SocketEvent [" + type + "]", "LuaProfiler");

            switch (type)
            {

                case SocketEvent.CONNECTED:
                    break;

                case SocketEvent.MESSAGE:
                    break;

                // Connect Fail or Disconnect
                default:
                    End();
                    break;

            }
        }


        //
    }
}

