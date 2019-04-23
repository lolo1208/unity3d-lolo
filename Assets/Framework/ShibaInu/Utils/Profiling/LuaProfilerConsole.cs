using System;
using UnityEngine;


namespace ShibaInu
{
	/// <summary>
	/// Lua profiler 工具对应的控制台
	/// </summary>
	public class LuaProfilerConsole : MonoBehaviour
	{
		private GUIStyle m_labelStyle;
		private GUIStyle m_tfStyle;
		private GUIStyle m_btnStyle;

		private Rect m_p1 = new Rect (30, 47, 0, 0);
		private Rect m_p2 = new Rect (90, 40, 240, 50);
		private Rect m_p3 = new Rect (350, 47, 0, 0);
		private Rect m_p4 = new Rect (430, 40, 130, 50);
		private Rect m_p5 = new Rect (90, 120, 130, 50);
		private Rect m_p6 = new Rect (250, 115, 170, 60);
		private Rect m_p7 = new Rect (510, 120, 50, 50);

		private string m_ip;
		private string m_port;
		private bool m_isUDP;
		private LuaProfiler m_profiler;


		void Awake ()
		{
			m_ip = PlayerPrefs.GetString ("LuaProfiler.ip");
			if (m_ip == "")
				m_ip = "192.168.x.x";

			m_port = PlayerPrefs.GetString ("LuaProfiler.port");
			if (m_port == "")
				m_port = "1208";

			m_isUDP = PlayerPrefs.GetInt ("LuaProfiler.isUDP") == 1;
		}


		void OnGUI ()
		{
			if (m_labelStyle == null) {
				m_labelStyle = new GUIStyle ();
				m_labelStyle.normal.textColor = Color.white;
				m_labelStyle.fontSize = 30;

				m_tfStyle = new GUIStyle (GUI.skin.textField);
				m_tfStyle.alignment = TextAnchor.MiddleCenter;
				m_tfStyle.fontSize = 30;

				m_btnStyle = new GUIStyle (GUI.skin.button);
				m_btnStyle.fontSize = 30;
			}


			if (m_profiler == null)
				m_profiler = Common.go.GetComponent<LuaProfiler> ();
			bool notRunning = m_profiler == null || !m_profiler.enabled;


			// ip and port
			GUI.enabled = notRunning;
			GUI.Label (m_p1, "ip :", m_labelStyle);
			m_ip = GUI.TextField (m_p2, m_ip, m_tfStyle);
			GUI.Label (m_p3, "port :", m_labelStyle);
			m_port = GUI.TextField (m_p4, m_port, m_tfStyle);

			if (m_isUDP) {
				m_isUDP = GUI.Button (m_p5, "tcp", m_btnStyle);
			} else {
				m_isUDP = !GUI.Button (m_p5, "udp", m_btnStyle);
			}
			GUI.enabled = true;

			// begin or end
			if (notRunning) {
				if (GUI.Button (m_p6, "BEGIN", m_btnStyle)) {
					LuaProfiler.Begin (m_ip, Int32.Parse (m_port), m_isUDP);
					PlayerPrefs.SetString ("LuaProfiler.ip", m_ip);
					PlayerPrefs.SetString ("LuaProfiler.port", m_port);
					PlayerPrefs.SetInt ("LuaProfiler.isUDP", m_isUDP ? 1 : 0);
				}
			} else {
				if (GUI.Button (m_p6, "END", m_btnStyle))
					LuaProfiler.End ();
			}

			// close
			if (GUI.Button (m_p7, "x", m_btnStyle))
				this.enabled = false;
		}


		//
	}
}

