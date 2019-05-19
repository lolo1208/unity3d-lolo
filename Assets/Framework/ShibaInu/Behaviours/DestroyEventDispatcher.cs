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
        private static LuaFunction s_dispatchEvent;

        /// 对应 gameObject.peer._ed
        public LuaTable ed;


        void OnDestroy()
        {
            try
            {
                if (s_dispatchEvent == null)
                    s_dispatchEvent = Common.luaMgr.state.GetFunction("DestroyEvent.DispatchEvent");

                s_dispatchEvent.BeginPCall();
                s_dispatchEvent.Push(ed);
                s_dispatchEvent.PCall();
                s_dispatchEvent.EndPCall();
            }
            catch { }
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

