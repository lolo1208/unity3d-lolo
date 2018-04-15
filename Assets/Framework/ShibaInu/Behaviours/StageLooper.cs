using System;
using System.Diagnostics;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 在 Start / Update / LateUpdate 触发时，调用 lua 层的 stage._loopHandler 函数。
	/// 更新 lua 层的 TimeUtil.time
	/// 该脚本只挂在 Common.go 上
	/// </summary>
	public class StageLooper : MonoBehaviour
	{
		/// 当前时间（秒）
		public static float time = 0;

		private const string EVENT_UPDATE = "Event_Update";
		private const string EVENT_LATE_UPDATE = "Event_LateUpdate";
		private const string EVENT_FIXED_UPDATE = "Event_FixedUpdate";
		private const string EVENT_RESIZE = "Event_Resize";

		// - View/Stage.lua
		private LuaFunction m_loopHandler;

		private Stopwatch m_stopwatch;
		private float m_screenWidth;
		private float m_screenHeight;



		void Start ()
		{
			m_stopwatch = new Stopwatch ();
			m_stopwatch.Start ();
			m_screenWidth = Screen.width;
			m_screenHeight = Screen.height;
			m_loopHandler = Common.luaMgr.state.GetFunction ("Stage._loopHandler");
		}


		public void UpdateTime ()
		{
			time = (float)m_stopwatch.ElapsedMilliseconds / 1000;
		}


		void Update ()
		{
			UpdateTime ();
			m_loopHandler.BeginPCall ();
			m_loopHandler.Push (EVENT_UPDATE);
			m_loopHandler.Push (time);
			m_loopHandler.PCall ();
			m_loopHandler.EndPCall ();

			// 屏幕尺寸有改变
			if (Screen.width != m_screenWidth || Screen.height != m_screenHeight) {
				m_screenWidth = Screen.width;
				m_screenHeight = Screen.height;
				Stage.Resize ();

				m_loopHandler.BeginPCall ();
				m_loopHandler.Push (EVENT_RESIZE);
				m_loopHandler.Push (time);
				m_loopHandler.PCall ();
				m_loopHandler.EndPCall ();
			}
		}


		void LateUpdate ()
		{
			UpdateTime ();
			m_loopHandler.BeginPCall ();
			m_loopHandler.Push (EVENT_LATE_UPDATE);
			m_loopHandler.Push (time);
			m_loopHandler.PCall ();
			m_loopHandler.EndPCall ();
		}


		void FixedUpdate ()
		{
			UpdateTime ();
			m_loopHandler.BeginPCall ();
			m_loopHandler.Push (EVENT_FIXED_UPDATE);
			m_loopHandler.Push (time);
			m_loopHandler.PCall ();
			m_loopHandler.EndPCall ();
		}



		void OnDestroy ()
		{
			m_stopwatch.Stop ();
			m_stopwatch = null;
		}


		//
	}
}

