using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 当 gameObject 与鼠标指针（touch）交互时，派发相关事件。
	/// </summary>
	public class PointerEventDispatcher : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler
	{
		/// PointerEvent.lua
		private static readonly LuaFunction _dispatchEvent = Common.lua.state.GetFunction ("PointerEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;



		public void OnPointerEnter (PointerEventData eventData)
		{
			DispatchLuaEvent (ed, "PointerEvent_Enter", eventData);
		}

		public void OnPointerExit (PointerEventData eventData)
		{
			DispatchLuaEvent (ed, "PointerEvent_Exit", eventData);
		}

		public void OnPointerDown (PointerEventData eventData)
		{
			DispatchLuaEvent (ed, "PointerEvent_Down", eventData);
		}

		public void OnPointerUp (PointerEventData eventData)
		{
			DispatchLuaEvent (ed, "PointerEvent_Up", eventData);
		}

		public void OnPointerClick (PointerEventData eventData)
		{
			DispatchLuaEvent (ed, "PointerEvent_Click", eventData);
		}



		private static void DispatchLuaEvent (LuaTable ed, string type, PointerEventData eventData)
		{
			_dispatchEvent.BeginPCall ();
			_dispatchEvent.Push (ed);
			_dispatchEvent.Push (type);
			_dispatchEvent.Push (eventData);
			_dispatchEvent.PCall ();
			_dispatchEvent.EndPCall ();
		}


		//
	}
}

