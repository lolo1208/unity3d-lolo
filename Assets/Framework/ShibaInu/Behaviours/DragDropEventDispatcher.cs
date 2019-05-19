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
        private static LuaFunction s_dispatchEvent;

        /// 对应 gameObject.peer._ed
        public LuaTable ed;



        private static void DispatchEvent(LuaTable ed, string type, PointerEventData eventData)
        {
            if (ed == null)
                return;

            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("DragDropEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(ed);
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(eventData);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }



        public void OnBeginDrag(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_BEGIN_DRAG, eventData);
        }

        public void OnDrag(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_DRAG, eventData);
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_END_DRAG, eventData);
        }

        public void OnInitializePotentialDrag(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_INITIALIZE_POTENTIAL_DRAG, eventData);
        }

        public void OnDrop(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_DROP, eventData);
        }



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_dispatchEvent = null;
        }

        #endregion


        //
    }
}

