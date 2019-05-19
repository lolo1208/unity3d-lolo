using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 场景 touch 相关事件判定和派发。只判断单点触摸，响应第一次点击的手指
    /// </summary>
    public static class StageTouchEventDispatcher
    {
        private const string TOUCH_BEGIN = "TouchEvent_Begin";
        private const string TOUCH_MOVE = "TouchEvent_Move";
        private const string TOUCH_END = "TouchEvent_End";

        /// PointerEvent.lua
        private static LuaFunction s_dispatchEvent;


        /// 是否正在触摸中
        private static bool s_touching;
        /// 上次记录的位置
        private static Vector2 s_pos = new Vector2();
        /// 当前 touch 对象的 ID。移动平台为 touch.fingerId
        private static int s_id = -1;

        private static Vector2 s_deltaPos = new Vector2();


        public static void Update()
        {
            // standalone
#if UNITY_EDITOR

            Vector3 p = Input.mousePosition;
            if (s_touching)
            {
                s_deltaPos.Set(p.x - s_pos.x, p.y - s_pos.y);
                if (Input.GetMouseButtonUp(0))
                {
                    s_touching = false;
                    s_pos.Set(p.x, p.y);
                    DispatchEvent(TOUCH_END);

                }
                else if (s_deltaPos.x != 0 || s_deltaPos.y != 0)
                {
                    s_pos.Set(p.x, p.y);
                    DispatchEvent(TOUCH_MOVE);
                }

            }
            else
            {
                if (Input.GetMouseButtonDown(0))
                {
                    s_touching = true;
                    s_pos.Set(p.x, p.y);
                    s_deltaPos.Set(0, 0);
                    DispatchEvent(TOUCH_BEGIN);
                }
            }


            // mobile
#else

			int touchCount = Input.touchCount;
			if (touchCount == 0) {
				// 容错
				if (s_touching) {
					s_touching = false;
					s_deltaPos.Set (0, 0);
					DispatchEvent (TOUCH_END);
				}
				return;
			}

			Touch touch;
			Vector2 p;
			int i;
			if (s_touching) {
				for (i = 0; i < touchCount; i++) {
					touch = Input.GetTouch (i);
					if (touch.fingerId == s_id) {

						p = touch.position;
						s_deltaPos.Set (p.x - s_pos.x, p.y - s_pos.y);

						if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled) {
							s_touching = false;
							s_pos.Set (p.x, p.y);
							DispatchEvent (TOUCH_END);
						} else if (s_deltaPos.x != 0 || s_deltaPos.y != 0) {
							s_pos.Set (p.x, p.y);
							DispatchEvent (TOUCH_MOVE);
						}
						break;
					}
				}


			} else {
				for (i = 0; i < touchCount; i++) {
					touch = Input.GetTouch (i);
					if (touch.phase == TouchPhase.Began) {
						s_touching = true;
						s_id = touch.fingerId;
						p = touch.position;
						s_pos.Set (p.x, p.y);
						s_deltaPos.Set (0, 0);
						DispatchEvent (TOUCH_BEGIN);
						break;
					}
				}
			}

#endif
        }


        /// <summary>
        /// 获取当前（上次）记录的 finger/mouse 位置
        /// </summary>
        /// <returns>The position.</returns>
        public static Vector2 GetPosition()
        {
            return s_pos;
        }



        private static void DispatchEvent(string type)
        {
            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("TouchEvent.StageDispatchEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(s_id);
            s_dispatchEvent.Push(s_pos);
            s_dispatchEvent.Push(s_deltaPos);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
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

