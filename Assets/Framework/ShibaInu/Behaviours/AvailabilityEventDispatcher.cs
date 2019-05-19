using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 当 gameObject 可用性有改变时（OnEnable() / OnDisable()），派发 AvailabilityEvent.CHANGED 事件
    /// </summary>
    public class AvailabilityEventDispatcher : MonoBehaviour
    {
        /// PointerEvent.lua
        private static LuaFunction s_dispatchEvent;

        /// 对应 gameObject.peer._ed
        public LuaTable ed;



        private static void DispatchEvent(LuaTable ed, bool enabled)
        {
            if (ed == null)
                return;

            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("AvailabilityEvent.DispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(ed);
            s_dispatchEvent.Push(enabled);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }



        void OnEnable()
        {
            DispatchEvent(ed, true);
        }


        void OnDisable()
        {
            DispatchEvent(ed, false);
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

