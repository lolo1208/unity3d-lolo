using System;
using System.Text;
using System.IO;
using UnityEngine;
using UnityEngine.Profiling;
using LuaInterface;


namespace ShibaInu
{
	public class LuaProfiler : MonoBehaviour
	{
		private static UdpSocket s_udp = new UdpSocket ();
		private static StringBuilder s_sb = new StringBuilder ();

		// - Utils/Optimize/Profiler.lua
		private static LuaFunction s_luaBegin;
		private static LuaFunction s_luaEnd;
		private static LuaFunction s_luaGetData;


		void Awake ()
		{
			s_luaBegin = Common.luaMgr.state.GetFunction ("Profiler.Begin");
			s_luaEnd = Common.luaMgr.state.GetFunction ("Profiler.End");
			s_luaGetData = Common.luaMgr.state.GetFunction ("Profiler.GetData");
		}



		void LateUpdate ()
		{
			s_luaGetData.BeginPCall ();
			s_luaGetData.PCall ();
			string data = s_luaGetData.CheckString ();
			s_luaGetData.EndPCall ();

			s_sb.Clear ();
			s_sb.Append ("{\"f\":");// 帧编号
			s_sb.Append (Time.frameCount);

			s_sb.Append (",\"r\":");// 帧率
			s_sb.Append (1 / Time.deltaTime);

			// s_sb.Append (",\"m\":");// 已申请最大内存量
			// s_sb.Append (Profiler.GetTotalReservedMemoryLong () * 1f / 1024 / 1024);

			s_sb.Append (",\"c\":");// 当前使用内存
			s_sb.Append (Profiler.GetTotalAllocatedMemoryLong () * 1f / 1024 / 1024);

			s_sb.Append (",\"d\":");// 统计数据
			s_sb.Append (data);
			s_sb.Append ("}");

			s_udp.Send (s_sb.ToString ());
			s_sb.Clear ();
		}



		public static void Begin (string host, int port)
		{
			GameObject go = Common.go;
			LuaProfiler profiler = go.GetComponent<LuaProfiler> ();
			if (profiler == null)
				profiler = go.AddComponent<LuaProfiler> ();
			else {
				if (profiler.enabled)
					return;
				profiler.enabled = true;
			}

			Debug.Log ("Lua Profiler Begin!");

			s_udp.callback = EventCallback;
			s_udp.Connect (host, port, (UInt32)port);

			s_luaBegin.BeginPCall ();
			s_luaBegin.PCall ();
			s_luaBegin.EndPCall ();
		}


		public static void End ()
		{
			GameObject go = Common.go;
			LuaProfiler profiler = go.GetComponent<LuaProfiler> ();
			if (profiler == null || !profiler.enabled)
				return;
			
			profiler.enabled = false;
			s_udp.Close ();

			s_luaEnd.BeginPCall ();
			s_luaEnd.PCall ();
			s_luaEnd.EndPCall ();

			Debug.Log ("Lua Profiler Stopped!");
		}


		private static void EventCallback (string type, System.Object data)
		{
			if (data != null)
				Debug.Log (type + ",   " + data.ToString ());
			else
				Debug.Log (type);
			
			switch (type) {

			case SocketEvent.CONNECTED:
				break;

			case SocketEvent.MESSAGE:
				break;

			// Connect Fail or Disconnect
			default:
				End ();
				break;

			}
		}



		//
	}
}

