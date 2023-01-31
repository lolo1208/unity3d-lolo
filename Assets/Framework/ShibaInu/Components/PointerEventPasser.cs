using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;


namespace ShibaInu
{
    /// <summary>
    /// 可以使 IPointerDownHandler, IPointerUpHandler, IPointerClickHandler 向下穿透一级
    /// </summary>
    [AddComponentMenu("ShibaInu/Pointer Event Passer", 302)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(PointerEventDispatcher))]// PointerEventDispatcher 脚本必须在之前添加好，保证在穿透前自身先抛出事件
    public class PointerEventPasser : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
    {

        /// OnPointerDown 时，穿透击中的目标
        private GameObject m_target;



        public void OnPointerDown(PointerEventData eventData)
        {
            List<RaycastResult> results = new List<RaycastResult>();
            EventSystem.current.RaycastAll(eventData, results);

            bool selfFounded = false;
            foreach (RaycastResult result in results)
            {
                if (result.gameObject == gameObject)
                {
                    selfFounded = true;// 先找到自己

                }
                else if (selfFounded)
                {
                    // 然后向下穿透一级
                    m_target = ExecuteEvents.ExecuteHierarchy(result.gameObject, eventData, ExecuteEvents.pointerDownHandler);
                    if (m_target != null)
                    {
                        return;
                    }
                }
            }
        }


        public void OnPointerUp(PointerEventData eventData)
        {
            if (m_target == null)
                return;
            GameObject target = m_target;
            m_target = null;

            // 触发 target.OnPointerUp()
            ExecuteEvents.Execute(target, eventData, ExecuteEvents.pointerUpHandler);

            // ScrollRect 触发拖动时，就算鼠标或手指还未释放，也会触发 OnPointerUp()
#if UNITY_EDITOR

            if (!Input.GetMouseButtonUp(0))
                return;// 鼠标左键还未释放

#else

			Touch[] touches = Input.touches;
			foreach (Touch touch in touches) {
				if (touch.fingerId == eventData.pointerId) {
					if (touch.phase != TouchPhase.Ended && touch.phase != TouchPhase.Canceled)
						return;// 手指还未释放
					break;
				}
			}

#endif

            // 检测是否可以触发 target.OnPointerClick()
            List<RaycastResult> results = new List<RaycastResult>();
            EventSystem.current.RaycastAll(eventData, results);
            foreach (RaycastResult result in results)
            {
                GameObject go = ExecuteEvents.GetEventHandler<IPointerClickHandler>(result.gameObject);
                if (go == target)
                {
                    ExecuteEvents.Execute(target, eventData, ExecuteEvents.pointerClickHandler);// 触发 click
                    return;
                }
            }
        }


        /// <summary>
        /// 主动释放当前穿透击中的目标，触发 target.OnPointerUp()
        /// </summary>
        public void ReleaseTarget()
        {
            if (m_target == null)
                return;

            PointerEventData eventData = new PointerEventData(EventSystem.current)
            {
                position = StageTouchEventDispatcher.GetPosition()
            };
            ExecuteEvents.Execute(m_target, eventData, ExecuteEvents.pointerUpHandler);
            m_target = null;
        }


        void OnDisable()
        {
            ReleaseTarget();
        }


        //
    }
}

