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
		private static readonly LuaFunction s_dispatchEvent = Common.luaMgr.state.GetFunction ("PointerEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;



		public void OnPointerEnter (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_ENTER);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnPointerExit (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_EXIT);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnPointerDown (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_DOWN);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnPointerUp (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_UP);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnPointerClick (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_CLICK);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}


		//
	}
}

