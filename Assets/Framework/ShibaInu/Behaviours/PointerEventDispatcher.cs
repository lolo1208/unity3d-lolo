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
        private static LuaFunction s_dispatchEvent;

        /// 对应 gameObject.peer._ed
        public LuaTable ed;



        private static void DispatchEvent(LuaTable ed, string type, PointerEventData eventData)
        {
            if (ed == null)
                return;

            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("PointerEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(ed);
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(eventData);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }



        public void OnPointerEnter(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_ENTER, eventData);
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_EXIT, eventData);
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_DOWN, eventData);
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_UP, eventData);
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            DispatchEvent(ed, EVENT_CLICK, eventData);
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

