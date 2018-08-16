using System;
using UnityEngine;
using UnityEngine.EventSystems;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 当 gameObject 与鼠标指针（touch）交互时，派发拖放相关事件。
	/// </summary>
	public class DragDropEventDispatcher : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler, IInitializePotentialDragHandler, IDropHandler
	{
		private const string EVENT_BEGIN_DRAG = "DragDropEvent_BeginDrag";
		private const string EVENT_DRAG = "DragDropEvent_Drag";
		private const string EVENT_END_DRAG = "DragDropEvent_EndDrag";
		private const string EVENT_INITIALIZE_POTENTIAL_DRAG = "DragDropEvent_InitializePotentialDrag";
		private const string EVENT_DROP = "DragDropEvent_Drop";

		/// PointerEvent.lua
		private static readonly LuaFunction s_dispatchEvent = Common.luaMgr.state.GetFunction ("DragDropEvent.DispatchEvent");

		/// 对应 gameObject.peer._ed
		public LuaTable ed;


		public void OnBeginDrag (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_BEGIN_DRAG);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnDrag (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_DRAG);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnEndDrag (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_END_DRAG);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnInitializePotentialDrag (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_INITIALIZE_POTENTIAL_DRAG);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}

		public void OnDrop (PointerEventData eventData)
		{
			s_dispatchEvent.BeginPCall ();
			s_dispatchEvent.Push (ed);
			s_dispatchEvent.Push (EVENT_DROP);
			s_dispatchEvent.Push (eventData);
			s_dispatchEvent.PCall ();
			s_dispatchEvent.EndPCall ();
		}


		//
	}
}

