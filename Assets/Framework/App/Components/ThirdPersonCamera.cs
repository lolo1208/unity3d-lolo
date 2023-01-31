using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;
using ShibaInu;


namespace App
{
    /// <summary>
    /// 第三人称镜头
    /// Author: LOLO
    /// </summary>
    [AddComponentMenu("ShibaInu/Third Person Camera", 402)]
    [DisallowMultipleComponent]
    public class ThirdPersonCamera : MonoBehaviour
    {

        #region Inspector 可编辑属性

        //
        public Transform target
        {
            set
            {
                if (value != m_target)
                {
                    m_target = value;
                    m_lastTargetPos = value.position;
                    m_adjustFrameCount = 30;// 镜头默认过渡到该目标身后
                }
            }
            get { return m_target; }
        }

        [Tooltip("镜头跟随的目标")]
        [FormerlySerializedAs("target"), SerializeField]
        protected Transform m_target;
        //


        [Tooltip("镜头跟随目标时，需要加上的偏移量")]
        public Vector3 targetOffset = new Vector3(0, 1, 0);


        //
        public float back
        {
            set
            {
                if (value != m_back)
                {
                    m_back = value;
                    CalculateDistance();
                }
            }
            get { return m_back; }
        }

        [Tooltip("镜头距离目标背后的距离")]
        [FormerlySerializedAs("back"), SerializeField]
        protected float m_back = 3;
        //



        //
        public float up
        {
            set
            {
                if (value != m_up)
                {
                    m_up = value;
                    CalculateDistance();
                }
            }
            get { return m_up; }
        }

        [Tooltip("镜头距离目标头顶的距离")]
        [FormerlySerializedAs("up"), SerializeField]
        protected float m_up = 1;
        //


        //
        public GameObject dragTarget
        {
            set
            {
                if (value != m_dragTarget)
                {
                    m_dragTarget = value;
                    AddDragTargetEventTrigger();
                }
            }
            get { return m_dragTarget; }
        }

        [Tooltip("拖拽该对象时，将会旋转镜头")]
        [FormerlySerializedAs("dragTarget"), SerializeField]
        protected GameObject m_dragTarget;
        //


        [Tooltip("拖拽灵敏度")]
        [Range(0, 5)]
        public float dragSensitivity = 0.4f;


        [Tooltip("向上拖拽最大限定值")]
        [Range(0, 0.99f)]
        public float dragUpLimit = 0.9f;


        [Tooltip("向下拖拽最大限定值")]
        [Range(0, 0.99f)]
        public float dragDownLimit = 0.2f;

        #endregion


        /// 是否正在拖拽中
        private bool m_dragging = false;
        /// drag event trigger
        private EventTrigger m_dragTrigger;
        /// 上次记录的拖拽位置
        private Vector2 m_lastDragPos;
        /// 当前拖拽位置
        private Vector2 m_curDragPos;

        /// 通过 back 和 up 计算出来的距离值
        private float m_distance;
        /// 矫正镜头过程剩余帧数
        private int m_adjustFrameCount = 20;
        /// 跟踪的 target 上次记录的位置
        private Vector3 m_lastTargetPos;




        void Start()
        {
            if (m_dragTrigger == null)
                AddDragTargetEventTrigger();
            CalculateDistance();
        }



        /// <summary>
        /// 根据 back 和 up 计算出默认距离
        /// </summary>
        private void CalculateDistance()
        {
            m_distance = Mathf.Sqrt(m_back * m_back + m_up * m_up);// vector2.magnitude
        }


        /// <summary>
        /// 矫正镜头到 up 和 back 设置的位置，用时：frameNum 帧
        /// </summary>
        /// <param name="frameNum">Frame number.</param>
        public void AdjustPosition(int frameNum = 20)
        {
            m_adjustFrameCount = frameNum;
        }


        /// <summary>
        /// 添加响应拖拽相关代码
        /// </summary>
        private void AddDragTargetEventTrigger()
        {
            if (m_dragTarget == null)
                return;

            if (m_dragTrigger != null)
                Destroy(m_dragTrigger);

            // 响应拖拽，记录拖拽位置
            m_dragTrigger = m_dragTarget.AddComponent<EventTrigger>();
            EventTrigger.Entry entry;

            // BeginDrag
            entry = new EventTrigger.Entry { eventID = EventTriggerType.BeginDrag };
            entry.callback.AddListener((data) =>
            {
                m_adjustFrameCount = 0;
                m_dragging = true;
                m_lastDragPos = m_curDragPos = ((PointerEventData)data).position;
            });
            m_dragTrigger.triggers.Add(entry);

            // Dragging
            entry = new EventTrigger.Entry { eventID = EventTriggerType.Drag };
            entry.callback.AddListener((data) =>
            {
                m_curDragPos = ((PointerEventData)data).position;
            });
            m_dragTrigger.triggers.Add(entry);

            // EndDrag
            entry = new EventTrigger.Entry { eventID = EventTriggerType.EndDrag };
            entry.callback.AddListener((data) =>
            {
                m_dragging = false;
                m_curDragPos = ((PointerEventData)data).position;
                if (m_target != null)
                    m_lastTargetPos = m_target.position;
            });
            m_dragTrigger.triggers.Add(entry);
        }



        void LateUpdate()
        {
            if (m_target == null)
                return;

            Vector3 curTarPos = m_target.position;// 目标当前位置，未偏移（矫正镜头位置时会作为临时变量使用）
            Vector3 tarPos = curTarPos + targetOffset;// 目标当前位置，已偏移

            // 逐步矫正镜头位置
            if (m_adjustFrameCount > 0)
                m_adjustFrameCount--;
            if (m_adjustFrameCount > 0)
            {
                Vector3 adjustPos = tarPos + m_target.forward * -m_back;// 根据 up 和 back 计算出来的位置
                adjustPos.y += m_up;
                Vector3 camPos = transform.position;
                curTarPos.Set(
                    camPos.x + (adjustPos.x - camPos.x) / m_adjustFrameCount,
                    camPos.y + (adjustPos.y - camPos.y) / m_adjustFrameCount,
                    camPos.z + (adjustPos.z - camPos.z) / m_adjustFrameCount
                );
                transform.position = curTarPos;
            }

            // 目标有移动，先跟随移动
            else if (curTarPos != m_lastTargetPos)
            {
                Vector3 camPos = transform.position;
                camPos.x += curTarPos.x - m_lastTargetPos.x;
                camPos.y += curTarPos.y - m_lastTargetPos.y;
                camPos.z += curTarPos.z - m_lastTargetPos.z;
                m_lastTargetPos = curTarPos;

                // 保持距离
                float d = Vector3.Distance(tarPos, camPos);
                Vector3 pos = Vector3.LerpUnclamped(tarPos, camPos, m_distance / d);
                transform.position = pos;
            }


            // 有拖拽
            float xOffset = m_curDragPos.x - m_lastDragPos.x;
            float yOffset = m_curDragPos.y - m_lastDragPos.y;
            if (m_dragging && (xOffset != 0 || yOffset != 0))
            {
                m_lastDragPos = m_curDragPos;
                float rotRatio = Common.GetFixedScreenScale() * dragSensitivity;

                // 水平轴旋转
                if (xOffset != 0)
                {
                    transform.RotateAround(tarPos, Vector3.up, xOffset * rotRatio);
                }

                // 垂直轴旋转
                Vector3 camPos = transform.position;// 镜头位置
                if (yOffset != 0)
                {
                    transform.RotateAround(tarPos, transform.TransformDirection(Vector3.left), yOffset * rotRatio);
                    Vector3 curPos = transform.position;// 镜头旋转过后的位置

                    // 向下看（镜头向上拉）
                    if (yOffset < 0)
                    {
                        float maxY = tarPos.y + m_distance * dragUpLimit;
                        if (curPos.y > maxY)
                        {
                            camPos.y = maxY;
                            transform.position = camPos;
                        }
                        else
                        {
                            camPos = curPos;
                        }
                    }

                    // 向上看（镜头向下拉）
                    else
                    {
                        float minY = tarPos.y - m_distance * dragDownLimit;
                        if (curPos.y < minY)
                        {
                            camPos.y = minY;
                            transform.position = camPos;
                        }
                        else
                        {
                            camPos = curPos;
                        }
                    }
                }

                // 保持距离
                float d = Vector3.Distance(tarPos, camPos);
                Vector3 pos = Vector3.LerpUnclamped(tarPos, camPos, m_distance / d);
                transform.position = pos;
            }

            transform.LookAt(tarPos);
        }


        //
    }
}

