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
		private static readonly LuaFunction _dispatchEvent = Common.lua.state.GetFunction ("DestroyEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;


		void OnDestroy ()
		{
			_dispatchEvent.BeginPCall ();
			_dispatchEvent.Push (ed);
			_dispatchEvent.PCall ();
			_dispatchEvent.EndPCall ();
		}


		//
	}
}

