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
		private static readonly LuaFunction m_dispatchEvent = Common.luaMgr.state.GetFunction ("PointerEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;



		public void OnPointerEnter (PointerEventData eventData)
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.Push (EVENT_ENTER);
			m_dispatchEvent.Push (eventData);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}

		public void OnPointerExit (PointerEventData eventData)
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.Push (EVENT_EXIT);
			m_dispatchEvent.Push (eventData);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}

		public void OnPointerDown (PointerEventData eventData)
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.Push (EVENT_DOWN);
			m_dispatchEvent.Push (eventData);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}

		public void OnPointerUp (PointerEventData eventData)
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.Push (EVENT_UP);
			m_dispatchEvent.Push (eventData);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}

		public void OnPointerClick (PointerEventData eventData)
		{
			m_dispatchEvent.BeginPCall ();
			m_dispatchEvent.Push (ed);
			m_dispatchEvent.Push (EVENT_CLICK);
			m_dispatchEvent.Push (eventData);
			m_dispatchEvent.PCall ();
			m_dispatchEvent.EndPCall ();
		}


		//
	}
}

