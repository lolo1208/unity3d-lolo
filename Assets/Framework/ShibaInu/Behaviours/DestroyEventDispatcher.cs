using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 当 gameObject 销毁时，在 lua 层（gameObject上）派发 DestroyEvent.DESTROY 事件。
	/// </summary>
	public class DestroyEventDispatcher : MonoBehaviour
	{
		/// PointerEvent.lua
		private static readonly LuaFunction m_dispatchEvent = Common.luaMgr.state.GetFunction ("DestroyEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;


		void OnDestroy ()
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}


		//
	}
}

