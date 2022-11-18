using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 主循环
    /// </summary>
    public class Looper : MonoBehaviour
    {
        private const string EVENT_UPDATE = "Event_Update";
        private const string EVENT_LATE_UPDATE = "Event_LateUpdate";
        private const string EVENT_FIXED_UPDATE = "Event_FixedUpdate";
        private const string EVENT_RESIZE = "Event_Resize";
        private const string EVENT_ACTIVATED = "Event_Activated";
        private const string EVENT_DEACTIVATED = "Event_Deactivated";

        /// 锁对象
        private static readonly object LOCK_OBJECT = new object();


        // - View/Stage.lua
        private LuaFunction m_dispatchEvent;
        /// 网络相关回调列表
        private readonly List<Action> m_netActions = new List<Action>();
        /// 其他需要在主线程执行的回调列表
        private readonly List<Action> m_threadActions = new List<Action>();
        /// 临时存储的回调列表
        private readonly List<Action> m_tempActions = new List<Action>();
        // 当前屏幕尺寸
        private Vector2 m_screenSize = new Vector2();
        // 当前程序是否已激活
        private bool m_activated = true;

        /// 场景尺寸有改变时的回调列表
        public readonly MultiCall<object> ResizeHandler = new MultiCall<object>();
        /// 设备方向有改变时的回调列表
        public readonly MultiCall<object> ScreenOrientationHandler = new MultiCall<object>();




        /// <summary>
        /// 添加一个网络相关回调到主线程运行
        /// </summary>
        /// <param name="action">Action.</param>
        public void AddNetAction(Action action)
        {
            lock (LOCK_OBJECT)
            {
                m_netActions.Add(action);
            }
        }


        /// <summary>
        /// 添加一个 Action 到主线程运行
        /// </summary>
        /// <param name="action">Action.</param>
        public void AddActionToMainThread(Action action)
        {
            lock (LOCK_OBJECT)
            {
                m_threadActions.Add(action);
            }
        }



        void Start()
        {
            m_screenSize.Set(Screen.width, Screen.height);
            m_dispatchEvent = Common.luaMgr.state.GetFunction("Stage._loopHandler");
            DeviceHelper.UpdateSafeInsets();

#if UNITY_EDITOR
            if (Common.IsOptimizeResolution)
                ResizeHandler.Add(Common.OptimizeResolution);
#endif
        }



        /// <summary>
        /// 向 lua 层抛出事件
        /// </summary>
        /// <param name="type">Type.</param>
        private void DispatchLuaEvent(string type)
        {
            if (m_dispatchEvent == null) return;
            m_dispatchEvent.BeginPCall();
            m_dispatchEvent.Push(type);
            m_dispatchEvent.Push(TimeUtil.timeSec);
            m_dispatchEvent.PCall();
            m_dispatchEvent.EndPCall();
        }



        void Update()
        {
#if UNITY_EDITOR
            // Unity2018 FrameDebugger 窗口会更新内容，导致无法查看数据
            if (UnityEditor.EditorApplication.isPaused) return;
#endif

            TimeUtil.Update();
            Timer.Update();
            UdpSocket.Update();
            NetHelper.Update();


            lock (LOCK_OBJECT)
            {
                // 需要在主线程运行的 Action
                if (m_threadActions.Count > 0)
                {
                    m_tempActions.AddRange(m_threadActions);
                    m_threadActions.Clear();
                }

                // 网络相关回调
                if (m_netActions.Count > 0)
                {
                    m_tempActions.AddRange(m_netActions);
                    m_netActions.Clear();
                }
            }

            if (m_tempActions.Count > 0)
            {
                foreach (Action action in m_tempActions)
                {
                    try
                    {
                        action();
                    }
                    catch (Exception e)
                    {
                        Logger.LogException(e);
                    }
                }
                m_tempActions.Clear();
            }


            // 设备方向有变化
            if (DeviceHelper.Update())
            {
                ScreenOrientationHandler.Call();
            }

            // 屏幕尺寸有改变
            int screenWidth = Screen.width;
            int screenHeight = Screen.height;
            if (screenWidth != m_screenSize.x || screenHeight != m_screenSize.y)
            {
                DeviceHelper.UpdateSafeInsets();
                m_screenSize.Set(screenWidth, screenHeight);
                ResizeHandler.Call();
                DispatchLuaEvent(EVENT_RESIZE);
            }

            // 全局屏幕 Touch 相关
            StageTouchEventDispatcher.Update();

            // lua Update
            DispatchLuaEvent(EVENT_UPDATE);
        }



        void LateUpdate()
        {
#if UNITY_EDITOR
            if (UnityEditor.EditorApplication.isPaused) return;
#endif

            TimeUtil.Update();
            DispatchLuaEvent(EVENT_LATE_UPDATE);
        }



        void FixedUpdate()
        {
#if UNITY_EDITOR
            if (UnityEditor.EditorApplication.isPaused) return;
#endif

            TimeUtil.Update();
            DispatchLuaEvent(EVENT_FIXED_UPDATE);
        }



        void OnApplicationFocus(bool hasFocus)
        {
            ActivationChanged(hasFocus);
        }

        void OnApplicationPause(bool pauseStatus)
        {
            ActivationChanged(!pauseStatus);
        }

        private void ActivationChanged(bool activated)
        {
#if UNITY_EDITOR
            if (UnityEditor.EditorApplication.isPaused) return;
#endif

            if (activated)
            {
                if (!m_activated)
                {
                    m_activated = true;
                    TimeUtil.Update();
                    DispatchLuaEvent(EVENT_ACTIVATED);
                }
            }
            else
            {
                if (m_activated)
                {
                    m_activated = false;
                    TimeUtil.Update();
                    DispatchLuaEvent(EVENT_DEACTIVATED);
                }
            }
        }


        /// <summary>
        /// 收到 Native 发来的消息
        /// </summary>
        /// <param name="msg"></param>
        protected void OnReceiveNativeMessage(string msg)
        {
            NativeHelper.OnReceiveNativeMessage(msg);
        }



        void OnDestroy()
        {
            LogFileWriter.Destroy();
        }


        //
    }
}

