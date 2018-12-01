using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 当 gameObject 与鼠标指针（touch）交互时，派发相关事件。
	/// </summary>
	public class PointerEventDispatcher : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler, IPointerClickHandler
	{
		private const string EVENT_ENTER = "PointerEvent_Enter";
		private const string EVENT_EXIT = "PointerEvent_Exit";
		private const string EVENT_DOWN = "PointerEvent_Down";
		private const string EVENT_UP = "PointerEvent_Up";
		private const string EVENT_CLICK = "PointerEvent_Click";

		/// PointerEvent.lua
		private static LuaFunction s_dispatchEvent = null;

		/// 对应 gameObject.peer._ed
		public LuaTable ed;


		private void DispatchLuaEvent (string type, PointerEventData eventData)
		{
			if (ed == null)
				return;
			
			if (s_dispatchEvent == null)
				s_dispatchEvent = Common.luaMgr.state.GetFunction ("PointerEvent.DispatchEvent");

			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (type);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}


		public void OnPointerEnter (PointerEventData eventData)
		{
			DispatchLuaEvent (EVENT_ENTER, eventData);
		}

		public void OnPointerExit (PointerEventData eventData)
		{
			DispatchLuaEvent (EVENT_EXIT, eventData);
		}

		public void OnPointerDown (PointerEventData eventData)
		{
			DispatchLuaEvent (EVENT_DOWN, eventData);
		}

		public void OnPointerUp (PointerEventData eventData)
		{
			DispatchLuaEvent (EVENT_UP, eventData);
		}

		public void OnPointerClick (PointerEventData eventData)
		{
			DispatchLuaEvent (EVENT_CLICK, eventData);
		}


		//
	}
}

