using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 当 gameObject 可用性有改变时（OnEnable() / OnDisable()），派发 AvailabilityEvent.CHANGED 事件
	/// </summary>
	public class AvailabilityEventDispatcher : MonoBehaviour
	{
		private const string EVENT_CHANGED = "AvailabilityEvent_Changed";

		/// PointerEvent.lua
		private static LuaFunction s_dispatchEvent;

		/// 对应 gameObject.peer._ed
		public LuaTable ed;



		private static void DispatchLuaEvent (LuaTable ed, bool enabled)
		{
			if (ed == null)
				return;

			if (s_dispatchEvent == null)
				s_dispatchEvent = Common.luaMgr.state.GetFunction ("AvailabilityEvent.DispatchEvent");

			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (enabled);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}



		void OnEnable ()
		{
			DispatchLuaEvent (ed, true);
		}


		void OnDisable ()
		{
			DispatchLuaEvent (ed, false);
		}


		//
	}
}

