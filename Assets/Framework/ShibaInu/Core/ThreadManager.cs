using System;
using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{

	/// <summary>
	/// 线程管理
	/// </summary>
	public class ThreadManager : MonoBehaviour
	{
		private static readonly System.Object LOCK_OBJECT = new System.Object ();

		private List<Action> m_actions = new List<Action> ();
		private List<Action> m_runningActions = new List<Action> ();



		/// <summary>
		/// 添加一个 Action 到主线程运行
		/// </summary>
		/// <param name="action">Action.</param>
		public void AddActionToMainThread (Action action)
		{
			lock (LOCK_OBJECT) {
				m_actions.Add (action);
			}
		}


		void Update ()
		{
			// 执行需要在主线程运行的 Action
			lock (LOCK_OBJECT) {
				if (m_actions.Count > 0) {
					m_runningActions.AddRange (m_actions);
					m_actions.Clear ();
				}
			}

			if (m_runningActions.Count > 0) {
				foreach (Action action in m_runningActions) {
					try {
						action ();
					} catch (Exception e) {
						Logger.AddErrorLog (e);
					}
				}
				m_runningActions.Clear ();
			}
		}


		//
	}
}

