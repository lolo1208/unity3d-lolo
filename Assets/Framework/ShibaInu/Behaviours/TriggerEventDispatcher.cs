using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 当 gameObject 产生 Trigger 相关行为时，派发事件。
    /// </summary>
    public class TriggerEventDispatcher : MonoBehaviour
    {
        private const string EVENT_ENTER = "TriggerEvent_Enter";
        private const string EVENT_STAY = "TriggerEvent_Stay";
        private const string EVENT_EXIT = "TriggerEvent_Exit";

        /// TriggerEvent.lua
        private static LuaFunction s_dispatchEvent;

        /// 对应 gameObject.peer._ed
        public LuaTable ed;



        private static void DispatchEvent(LuaTable ed, string type, Collider eventData)
        {
            if (ed == null)
                return;

            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("TriggerEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(ed);
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(eventData);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }



        void OnTriggerEnter(Collider other)
        {
            DispatchEvent(ed, EVENT_ENTER, other);
        }


        void OnTriggerStay(Collider other)
        {
            DispatchEvent(ed, EVENT_STAY, other);
        }


        void OnTriggerExit(Collider other)
        {
            DispatchEvent(ed, EVENT_EXIT, other);
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
