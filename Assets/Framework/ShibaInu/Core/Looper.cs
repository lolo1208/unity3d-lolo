using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 主循环
	/// </summary>
	public class Looper : MonoBehaviour
	{
		private const string EVENT_UPDATE = "Event_Update";
		private const string EVENT_LATE_UPDATE = "Event_LateUpdate";
		private const string EVENT_FIXED_UPDATE = "Event_FixedUpdate";
		private const string EVENT_RESIZE = "Event_Resize";

		/// 锁对象
		private static readonly System.Object LOCK_OBJECT = new System.Object ();


		// - View/Stage.lua
		private LuaFunction m_luaLoopHandler;
		// 上次记录的屏幕宽高
		private Vector2 m_screenSize = new Vector2 ();
		/// 网络相关回调列表
		private List<Action> m_netActions = new List<Action> ();
		/// 其他需要在主线程执行的回调列表
		private List<Action> m_threadActions = new List<Action> ();
		/// 临时存储的回调列表
		private List<Action> m_tempActions = new List<Action> ();

		/// 场景尺寸有改变时的回调列表
		public HashSet<Action> resizeHandler = new HashSet<Action> ();




		/// <summary>
		/// 添加一个网络相关回调到主线程运行
		/// </summary>
		/// <param name="action">Action.</param>
		public void AddNetAction (Action action)
		{
			lock (LOCK_OBJECT) {
				m_netActions.Add (action);
			}
		}


		/// <summary>
		/// 添加一个 Action 到主线程运行
		/// </summary>
		/// <param name="action">Action.</param>
		public void AddActionToMainThread (Action action)
		{
			lock (LOCK_OBJECT) {
				m_threadActions.Add (action);
			}
		}



		void Start ()
		{
			m_screenSize.Set (Screen.width, Screen.height);
			m_luaLoopHandler = Common.luaMgr.state.GetFunction ("Stage._loopHandler");

			#if UNITY_EDITOR
			if (Common.IsOptimizeResolution)
				resizeHandler.Add (Common.OptimizeResolution);
			#endif
		}



		void Update ()
		{
			TimeUtil.Update ();
			Timer.Update ();
			UdpSocket.Update ();


			// 执行需要在主线程运行的 Action
			lock (LOCK_OBJECT) {
				if (m_threadActions.Count > 0) {
					m_tempActions.AddRange (m_threadActions);
					m_threadActions.Clear ();
				}
			}
			if (m_tempActions.Count > 0) {
				foreach (Action action in m_tempActions) {
					try {
						action ();
					} catch (Exception e) {
						Logger.LogException (e);
					}
				}
				m_tempActions.Clear ();
			}


			// 执行网络相关回调
			lock (LOCK_OBJECT) {
				if (m_netActions.Count > 0) {
					m_tempActions.AddRange (m_netActions);
					m_netActions.Clear ();
				}
			}
			if (m_tempActions.Count > 0) {
				foreach (Action action in m_tempActions) {
					try {
						action ();
					} catch (Exception e) {
						Logger.LogException (e);
					}
				}
				m_tempActions.Clear ();
			}


			// 屏幕尺寸有改变
			if (Screen.width != m_screenSize.x || Screen.height != m_screenSize.y) {
				m_screenSize.Set (Screen.width, Screen.height);
				List<Action> removes = new List<Action> ();
				foreach (Action handler in resizeHandler) {
					try {
						handler ();
					} catch (Exception e) {
						removes.Add (handler);
						Logger.LogException (e);
					}
				}
				// 移除执行时报错的 action
				foreach (Action handler in removes)
					resizeHandler.Remove (handler);

				// lua Resize
				m_luaLoopHandler.BeginPCall ();
				m_luaLoopHandler.Push (EVENT_RESIZE);
				m_luaLoopHandler.Push (TimeUtil.timeSec);
				m_luaLoopHandler.PCall ();
				m_luaLoopHandler.EndPCall ();
			}

			StageTouchEventDispatcher.Update ();

			// lua Update
			m_luaLoopHandler.BeginPCall ();
			m_luaLoopHandler.Push (EVENT_UPDATE);
			m_luaLoopHandler.Push (TimeUtil.timeSec);
			m_luaLoopHandler.PCall ();
			m_luaLoopHandler.EndPCall ();
		}



		void LateUpdate ()
		{
			TimeUtil.Update ();
			m_luaLoopHandler.BeginPCall ();
			m_luaLoopHandler.Push (EVENT_LATE_UPDATE);
			m_luaLoopHandler.Push (TimeUtil.timeSec);
			m_luaLoopHandler.PCall ();
			m_luaLoopHandler.EndPCall ();
		}



		void FixedUpdate ()
		{
			TimeUtil.Update ();
			m_luaLoopHandler.BeginPCall ();
			m_luaLoopHandler.Push (EVENT_FIXED_UPDATE);
			m_luaLoopHandler.Push (TimeUtil.timeSec);
			m_luaLoopHandler.PCall ();
			m_luaLoopHandler.EndPCall ();
		}



		void OnDestroy ()
		{
			LogFileWriter.Destroy ();
		}


		//
	}
}

