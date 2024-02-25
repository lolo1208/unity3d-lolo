using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;
using DG.Tweening;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 选择器列表，需配合 Picker.lua 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Picker", 106)]
    [DisallowMultipleComponent]
    public class Picker : MonoBehaviour
    {

        #region lua 相关

        /// 对应的 lua Picker 对象
        public virtual LuaTable luaTarget
        {
            set
            {
                m_luaTarget = value;
                m_luaAddItem = value.GetLuaFunction("AddItem");
                m_luaRemoveItem = value.GetLuaFunction("RemoveItem");
                m_luaSelectItem = value.GetLuaFunction("SelectItem");
            }
        }

        protected LuaTable m_luaTarget;
        protected LuaFunction m_luaAddItem;
        protected LuaFunction m_luaRemoveItem;
        protected LuaFunction m_luaSelectItem;

        #endregion



        #region Inspector 可编辑属性

        /// 拖动点击响应区域
        public GameObject hitArea
        {
            set
            {
                if (value != m_hitArea)
                {
                    m_hitArea = value;
                }
            }
            get { return m_hitArea; }
        }

        [FormerlySerializedAs("hitArea"), SerializeField]
        protected GameObject m_hitArea;


        /// Item 的预制对象
        public GameObject itemPrefab
        {
            set
            {
                if (value != m_itemPrefab)
                {
                    m_itemPrefab = value;
                    m_renderDirty = true;
                    Clean();
                    ResetItemSize();
                }
            }
            get { return m_itemPrefab; }
        }

        [FormerlySerializedAs("itemPrefab"), SerializeField]
        protected GameObject m_itemPrefab;


        /// 上下（左右）每个方向最多显示 Item 数量
        public uint itemOffsetCount
        {
            set
            {
                if (value != m_itemOffsetCount)
                {
                    m_itemOffsetCount = value;
                    m_renderDirty = true;
                }
            }
            get { return m_itemOffsetCount; }
        }

        [FormerlySerializedAs("itemOffsetCount"), SerializeField]
        protected uint m_itemOffsetCount = 3;


        /// Item 透明度偏移
        public float itemAlphaOffset
        {
            set
            {
                if (value != m_itemAlphaOffset)
                {
                    m_itemAlphaOffset = value;
                    m_renderDirty = true;
                }
            }
            get { return m_itemAlphaOffset; }
        }

        [Range(0, 1)]
        [FormerlySerializedAs("itemAlphaOffset"), SerializeField]
        protected float m_itemAlphaOffset = 0;


        /// Item 缩放偏移
        public float itemScaleOffset
        {
            set
            {
                if (value != m_itemScaleOffset)
                {
                    m_itemScaleOffset = value;
                    m_renderDirty = true;
                }
            }
            get { return m_itemScaleOffset; }
        }

        [FormerlySerializedAs("itemScaleOffset"), SerializeField]
        protected float m_itemScaleOffset = 0;


        /// 是否为垂直方向排列
        public bool isVertical
        {
            set
            {
                if (value != m_isVertical)
                {
                    m_isVertical = value;
                    m_renderDirty = true;
                    ResetItemSizeValue();
                    if (m_content)
                        ScrollToSelectedItem(0);
                }
            }
            get { return m_isVertical; }
        }

        [FormerlySerializedAs("isVertical"), SerializeField]
        protected bool m_isVertical = true;


        /// 是否启用回弹效果
        public bool isBounces
        {
            set { m_isBounces = value; }
            get { return m_isBounces; }
        }

        [FormerlySerializedAs("isBounces"), SerializeField]
        protected bool m_isBounces = true;


        /// 拖拽结束后，继续滚动距离比例
        public float scrollRatio
        {
            set { m_scrollRatio = value; }
            get { return m_scrollRatio; }
        }

        [Range(0, 1)]
        [FormerlySerializedAs("scrollRatio"), SerializeField]
        protected float m_scrollRatio = 0.5f;

        #endregion




        #region 功能实现

        /// Item 容器
        public RectTransform content
        {
            get { return m_content; }
        }

        protected RectTransform m_content;


        /// Item 数量
        public uint itemCount
        {
            set
            {
                if (value != m_itemCount)
                {
                    m_itemCount = value;
                    m_renderDirty = true;
                    ResetPosRect();

                    // 设置的数量比当前 index 小
                    int maxIdx = (int)value - 1;
                    if (m_index > maxIdx)
                        index = maxIdx;
                }
            }
            get { return m_itemCount; }
        }

        protected uint m_itemCount = 0;


        /// 当前所选 item 的索引
        public int index
        {
            set
            {
                if (value != m_index)
                {
                    // index 比 itemCount 还大
                    int maxIdx = (int)m_itemCount - 1;
                    if (value > maxIdx)
                    {
                        value = maxIdx;
                    }
                    else if (value < 0)
                    {
                        value = (m_itemCount > 0) ? 0 : -1;
                    }

                    m_index = value;
                    if (m_index > -1)
                        ScrollToSelectedItem();
                }
            }
            get { return m_index; }
        }

        protected int m_index = -1;



        /// Item 缓存池
        protected Stack<GameObject> m_itemPool = new Stack<GameObject>();
        /// 正在显示的 Item 列表，index 为 key
        protected Dictionary<int, GameObject> m_itemList = new Dictionary<int, GameObject>();
        /// 临时使用的 item 索引列表
        protected HashSet<int> m_itemIdxList = new HashSet<int>();
        /// Item 的尺寸
        protected Vector2 m_itemSize = new Vector2();
        /// Item 尺寸的值
        protected float m_itemSizeValue;
        /// 当前帧是否需要进行渲染
        protected bool m_renderDirty;


        /// 拖动时，当前帧的位置
        protected float m_curDragPos;
        /// 拖动时，上一帧的位置
        protected float m_lastDragPos;
        /// 是否正在拖动中
        protected bool m_dragging;
        /// 最小滚动位置
        protected float m_minPos;
        /// 最大滚动位置
        protected float m_maxPos;
        /// index 偏移（绝对）值
        protected float m_indexOffset;
        /// index 偏移值是否为正数
        protected bool m_isIOG0;
        /// 本次更新 index 是否有改变
        protected bool m_isIndexChanged;
        /// m_content 的缓动对象
        protected Tweener m_contentTweener;

        /// 临时使用的 Vector3 对象
        protected static Vector3 tmpVec3 = new Vector3();


        /// 拖动时，记录当前帧的位置
        protected void SetDragPosition(PointerEventData data)
        {
            m_curDragPos = (m_isVertical ? data.position.y : data.position.x) * Common.GetFixedScreenScale();
        }



        void Awake()
        {
            m_content = (RectTransform)LuaHelper.CreateGameObject("Content", transform, false).transform;
            m_content.SetAsFirstSibling();
            ResetItemSize();

            // 响应点击区域相关事件
            EventTrigger trigger = m_hitArea.AddComponent<EventTrigger>();
            EventTrigger.Entry entry;

            // PointerDown
            entry = new EventTrigger.Entry { eventID = EventTriggerType.PointerDown };
            entry.callback.AddListener((data) =>
            {
                if (m_contentTweener != null)
                    m_contentTweener.Kill();
            });
            trigger.triggers.Add(entry);

            // PointerUp
            entry = new EventTrigger.Entry { eventID = EventTriggerType.PointerUp };
            entry.callback.AddListener((data) =>
            {
                if (!m_dragging)
                    ScrollToSelectedItem();
            });
            trigger.triggers.Add(entry);

            // BeginDrag
            entry = new EventTrigger.Entry { eventID = EventTriggerType.BeginDrag };
            entry.callback.AddListener((data) =>
            {
                m_dragging = true;
                SetDragPosition((PointerEventData)data);
                m_lastDragPos = m_curDragPos;
                StartRecordVelocity();
            });
            trigger.triggers.Add(entry);

            // Dragging
            entry = new EventTrigger.Entry { eventID = EventTriggerType.Drag };
            entry.callback.AddListener((data) =>
            {
                SetDragPosition((PointerEventData)data);
                RecordVelocity();
            });
            trigger.triggers.Add(entry);

            // EndDrag
            entry = new EventTrigger.Entry { eventID = EventTriggerType.EndDrag };
            entry.callback.AddListener((data) =>
            {
                SetDragPosition((PointerEventData)data);
                m_dragging = false;
                EndRecordVelocity();
            });
            trigger.triggers.Add(entry);
        }



        void LateUpdate()
        {
            if ((!m_renderDirty && !m_dragging && m_contentTweener == null) || m_itemCount == 0)
                return;

            // 拖动时，计算位置偏移
            Vector3 pos = m_content.localPosition;
            float contentPos = m_isVertical ? pos.y : pos.x;
            float p = contentPos;
            if (m_dragging)
            {
                float dragPos = m_curDragPos - m_lastDragPos;
                p = contentPos + dragPos;
                if (m_isBounces)
                {
                    if (p < m_minPos || p > m_maxPos)
                        p = contentPos + dragPos / 2;
                }
                else
                {
                    if (p < m_minPos)
                        p = m_minPos;
                    else if (p > m_maxPos)
                        p = m_maxPos;
                }

                if (m_isVertical)
                    pos.y = p;
                else
                    pos.x = p;
                m_content.localPosition = pos;
                m_lastDragPos = m_curDragPos;
            }

            // 计算 index 前，将当前位置设定在范围内
            if (p < m_minPos)
                p = m_minPos;
            else if (p > m_maxPos)
                p = m_maxPos;

            // 当前选中 item 的索引
            float fIdx = (m_isVertical ? p : -p) / m_itemSizeValue;
            int index = (int)Mathf.Round(fIdx);
            m_indexOffset = index - fIdx;
            m_isIOG0 = m_indexOffset > 0;
            m_indexOffset = Mathf.Abs(m_indexOffset);


            // selected item 有改变
            m_isIndexChanged = index != m_index;
            m_index = index;
            m_renderDirty = false;


            // 记录当前选中的 item
            m_itemIdxList.Clear();
            m_itemIdxList.Add(index);
            ShowItem(index);
            int totalCount = 1;
            if (m_isIndexChanged)
            {
                m_luaSelectItem.BeginPCall();
                m_luaSelectItem.Push(m_luaTarget);
                m_luaSelectItem.Push(index);
                m_luaSelectItem.PCall();
                m_luaSelectItem.EndPCall();
            }

            // 向下（右）创建 item
            int idx = index;
            int count = 0;
            while (idx < m_itemCount - 1 && count < m_itemOffsetCount && totalCount < m_itemCount)
            {
                idx++;
                count++;
                ShowItem(idx);
            }

            // 向上（左）创建 item
            idx = index;
            count = 0;
            while (idx > 0 && count < m_itemOffsetCount && totalCount < m_itemCount)
            {
                idx--;
                count++;
                ShowItem(idx);
            }

            // 移除无需显示的 item
            List<int> itemsToRemove = new List<int>();
            foreach (KeyValuePair<int, GameObject> entry in m_itemList)
            {
                if (!m_itemIdxList.Contains(entry.Key))
                {
                    m_itemPool.Push(entry.Value);
                    itemsToRemove.Add(entry.Key);
                }
            }
            foreach (int itemIdx in itemsToRemove)
            {
                m_itemList.Remove(itemIdx);

                m_luaRemoveItem.BeginPCall();
                m_luaRemoveItem.Push(m_luaTarget);
                m_luaRemoveItem.Push(itemIdx);
                m_luaRemoveItem.PCall();
                m_luaRemoveItem.EndPCall();
            }

            // 隐藏缓存池中的 Item
            foreach (GameObject go in m_itemPool)
            {
                if (go.activeSelf)
                    go.SetActive(false);
            }
        }


        /// <summary>
        /// 显示 index 对应的 item，计算出对应的属性
        /// </summary>
        /// <param name="index">Index.</param>
        protected void ShowItem(int index)
        {
            GameObject item;
            if (m_itemList.ContainsKey(index))
            {// item 是否已显示
                m_itemList.TryGetValue(index, out item);
            }
            else
            {
                item = GetItem();
                if (!item.activeSelf)
                    item.SetActive(true);

                m_luaAddItem.BeginPCall();
                m_luaAddItem.Push(m_luaTarget);
                m_luaAddItem.Push(index);
                m_luaAddItem.Push(item);
                m_luaAddItem.PCall();
                m_luaAddItem.EndPCall();

                // 默认选中
                if (index == m_index)
                {
                    m_luaSelectItem.BeginPCall();
                    m_luaSelectItem.Push(m_luaTarget);
                    m_luaSelectItem.Push(index);
                    m_luaSelectItem.PCall();
                    m_luaSelectItem.EndPCall();
                }
            }

            // 记录到 m_itemIdxList 和 m_itemList
            m_itemIdxList.Add(index);
            if (!m_itemList.ContainsKey(index))
                m_itemList.Add(index, item);

            // 计算偏移量
            float offsetNum = Mathf.Abs(index - m_index);
            bool isCurIdx = index == m_index;// 是否为当前 index
            bool isBigIdx = index > m_index;// 是否为比当前 index 要大
            bool isFlag = (m_isIOG0 && (isBigIdx || isCurIdx)) || (!m_isIOG0 && !isBigIdx);// 超复杂的条件（正数，上面的 item 需要 + 偏移）
            Transform tra = item.transform;


            // 透明度偏移
            CanvasGroup cg = item.GetComponent<CanvasGroup>();
            if (cg == null)
                cg = item.AddComponent<CanvasGroup>();
            float alpha = 1 - offsetNum * m_itemAlphaOffset;
            float iovAlpha = m_itemAlphaOffset * m_indexOffset;
            if (isFlag)
                alpha -= iovAlpha;
            else
                alpha += iovAlpha;
            cg.alpha = alpha;


            // 缩放偏移
            float scale = 1 - offsetNum * m_itemScaleOffset;
            float iovScale = m_itemScaleOffset * m_indexOffset;
            if (isFlag)
                scale -= iovScale;
            else
                scale += iovScale;
            tmpVec3.Set(scale, scale, 1);
            tra.localScale = tmpVec3;


            // 正常位置
            float posVal = index * m_itemSizeValue;
            if (m_isVertical)
            {
                tmpVec3.Set(0, -posVal, 0);
            }
            else
            {
                tmpVec3.Set(posVal, 0, 0);
            }


            // offset position
            float op = 0;
            bool isFirst = true;

            // 基于 m_indexOffset 和 m_itemScaleOffset 得出的偏移量
            if (!isFlag)
                iovScale = -iovScale;

            // 根据缩放量计算位置的偏移
            float iovScaleVal = iovScale * m_itemSizeValue;
            while (offsetNum > 0)
            {
                op += (m_itemScaleOffset * offsetNum + iovScale) * m_itemSizeValue;
                if (isFirst)
                {// 第一次计算（自身），需要除2（前提是 item 的 pivot = 0.5）
                    isFirst = false;
                    op /= 2;
                    if (isFlag)
                        op -= iovScaleVal;
                    else
                        op += iovScaleVal;
                }
                offsetNum--;
            }

            // 除了 m_index 所对应的 item 以外，其他 item 都需要再次偏移
            if (!isCurIdx)
            {
                float iovDynScaleVal = iovScaleVal * 1.5f;// 动态偏移值 x1.5
                if (!m_isIOG0)
                {
                    if (isBigIdx)
                        op -= iovDynScaleVal;
                    else
                        op += iovDynScaleVal;
                }
                else
                {
                    if (isBigIdx)
                        op += iovDynScaleVal;
                    else
                        op -= iovDynScaleVal;
                }

                // index 有改变时，内容也需要进行偏移
                if (m_isIndexChanged)
                {
                    m_isIndexChanged = false;
                    bool isLast = m_index == m_itemCount - 1;// 是否为最后一个 item
                    Vector3 p = m_content.localPosition;
                    if (m_isVertical)
                    {
                        if (isLast)
                            p.y -= iovScaleVal;
                        else
                            p.y += iovScaleVal;
                    }
                    else
                    {
                        if (isLast)
                            p.x += iovScaleVal;
                        else
                            p.x -= iovScaleVal;
                    }
                    m_content.localPosition = p;
                }
            }


            // 根据水平和垂直 以及 isBigIdx 来设定 item.localPosition
            if (m_isVertical)
            {
                if (isBigIdx)
                {
                    tmpVec3.y += op;
                }
                else
                {
                    tmpVec3.y -= op;
                }
            }
            else
            {
                if (isBigIdx)
                {
                    tmpVec3.x -= op;
                }
                else
                {
                    tmpVec3.x += op;
                }
            }
            tra.localPosition = tmpVec3;
        }


        /// <summary>
        /// 创建 或 从缓存池中获取一个 item
        /// </summary>
        /// <returns>The item.</returns>
        protected GameObject GetItem()
        {
            return (m_itemPool.Count > 0)
                ? m_itemPool.Pop()
                : (GameObject)Instantiate(m_itemPrefab, m_content);
        }


        /// <summary>
        /// 重置 item 的宽高
        /// 临时创建一个 itemPrefab，拿到宽高后放入池中
        /// </summary>
        protected void ResetItemSize()
        {
            if (m_itemPrefab != null && m_content != null)
            {
                GameObject tempItem = (GameObject)Instantiate(m_itemPrefab, m_content);
                RectTransform itemRect = (RectTransform)tempItem.transform;
                Vector2 sizeDelta = itemRect.sizeDelta;
                m_itemSize.Set(sizeDelta.x, sizeDelta.y);
                ResetItemSizeValue();
                m_itemPool.Push(tempItem);
                tempItem.SetActive(false);
                m_renderDirty = true;
            }
        }


        /// <summary>
        /// Resets the item size value.
        /// </summary>
        protected void ResetItemSizeValue()
        {
            m_itemSizeValue = m_isVertical ? m_itemSize.y : m_itemSize.x;
            ResetPosRect();
        }

        /// <summary>
        /// Resets the position rect.
        /// </summary>
        protected void ResetPosRect()
        {
            if (m_isVertical)
            {
                m_minPos = 0;
                m_maxPos = (m_itemCount - 1) * m_itemSizeValue;
            }
            else
            {
                m_minPos = (m_itemCount - 1) * -m_itemSizeValue;
                m_maxPos = 0;
            }
        }

        #endregion




        #region public functions

        /// <summary>
        /// 缓动到 index 对应的 item 位置
        /// </summary>
        /// <param name="index">Index.</param>
        /// <param name="duration">Duration.</param>
        public void ScrollByIndex(int index, float duration = 0.2f)
        {
            float posVal = index * m_itemSizeValue;
            if (m_isVertical)
                tmpVec3.Set(0, posVal, 0);
            else
                tmpVec3.Set(-posVal, 0, 0);

            if (m_contentTweener != null)
                m_contentTweener.Kill();
            m_contentTweener = m_content.DOLocalMove(tmpVec3, duration).OnComplete(() =>
            {
                m_contentTweener = null;
                m_renderDirty = true;
            });
        }



        /// <summary>
        /// 缓动到当前所选的 item 位置
        /// </summary>
        /// <param name="duration">Duration.</param>
        public void ScrollToSelectedItem(float duration = 0.2f)
        {
            ScrollByIndex(m_index, duration);
        }



        /// <summary>
        /// 清理并销毁所有的 Item
        /// </summary>
        public void Clean()
        {
            if (m_content != null)
            {
                Destroy(m_content.gameObject);
                m_content = (RectTransform)LuaHelper.CreateGameObject("Content", transform, false).transform;
                m_content.SetSiblingIndex(0);
            }
            m_itemPool.Clear();
            m_itemList.Clear();
            m_itemIdxList.Clear();
            m_itemCount = 0;
            m_index = -1;
        }

        #endregion




        #region 跟随拖拽手势自动滚动

        /// 速度的权重列表。index越小，越是最近发生的
        private static readonly float[] VELOCITY_WEIGHTS = { 2.33f, 2f, 1.66f, 1.33f, 1f };
        /// 最多记录几次速度值
        private static readonly int VELOCITY_MAX_COUNT = VELOCITY_WEIGHTS.Length;
        /// 速度值记录间隔
        private const float VELOCITY_INTERVAL = 0.01f;
        /// 最小的改变速度，解决浮点数精度问题
        private const float MINIMUM_VELOCITY = 0.02f;
        /// 当容器自动滚动时并且滚动位置超出容器范围时要额外应用的摩擦系数
        private const float EXTRA_FRICTION = 0.95f;
        /// 当容器自动滚动时要应用的摩擦系数
        private const float FRICTION = 0.998f;
        /// 摩擦系数的自然对数
        private static readonly float FRICTION_LOG = Mathf.Log(FRICTION);

        /// 记录的速度列表
        private readonly Queue<float> m_velocitys = new Queue<float>();
        /// 上次记录的时间
        private float m_lastTime;
        /// 上次记录的位置
        private float m_lastPosition;


        /// <summary>
        /// 开始记录拖动速度
        /// </summary>
        private void StartRecordVelocity()
        {
            m_velocitys.Clear();
            m_lastTime = TimeUtil.timeSec;
            Vector3 pos = m_content.localPosition;
            m_lastPosition = m_curDragPos;
        }


        /// <summary>
        /// 拖动中，记录拖动速度
        /// </summary>
        private void RecordVelocity()
        {
            float curTime = TimeUtil.timeSec;
            float offsetTime = curTime - m_lastTime;
            if (offsetTime < VELOCITY_INTERVAL)
                return;

            float offsetPosition = m_lastPosition - m_curDragPos;
            m_velocitys.Enqueue(offsetPosition / offsetTime * 0.5f);
            while (m_velocitys.Count > VELOCITY_MAX_COUNT)
                m_velocitys.Dequeue();
            m_lastTime = curTime;
            m_lastPosition = m_curDragPos;
        }


        /// <summary>
        /// 结束记录拖动速度
        /// </summary>
        private void EndRecordVelocity()
        {
            // 根据速度，计算拖动重力
            float velocity = 0;
            float weight = 0;
            float[] velocitys = m_velocitys.ToArray();
            Array.Reverse(velocitys);
            for (int i = 0; i < velocitys.Length; i++)
            {
                velocity += velocitys[i] * VELOCITY_WEIGHTS[i];
                weight += VELOCITY_WEIGHTS[i];
            }

            // 继续滚动
            float pixelsPerMS = velocity / 1000 / weight * m_scrollRatio;
            float absPixelsPerMS = Mathf.Abs(pixelsPerMS);
            float duration = 0;
            float posTo = 0;
            float min = m_minPos;
            float max = m_maxPos;
            Vector3 cp = m_content.localPosition;
            float pos = m_isVertical ? cp.y : cp.x;
            if (absPixelsPerMS > MINIMUM_VELOCITY)
            {
                posTo = pos + (pixelsPerMS - MINIMUM_VELOCITY) / FRICTION_LOG * 2;
                if (posTo < min || posTo > max)
                {
                    posTo = pos;
                    while (Mathf.Abs(pixelsPerMS) > MINIMUM_VELOCITY)
                    {
                        posTo -= pixelsPerMS;
                        if (posTo < min || posTo > max)
                        {
                            pixelsPerMS *= FRICTION * EXTRA_FRICTION;
                        }
                        else
                        {
                            pixelsPerMS *= FRICTION;
                        }
                        duration++;
                    }
                }
                else
                {
                    duration = Mathf.Log(MINIMUM_VELOCITY / absPixelsPerMS) / FRICTION_LOG;
                }
            }
            else
            {
                posTo = pos;
            }

            // 慢速拖动，不需要继续再滚动了
            if (Mathf.Abs(pos - posTo) < 100 || (TimeUtil.timeSec - m_lastTime) > 0.15)
            {
                duration = 0;
            }

            if (duration > 0)
            {
                if (!m_isBounces)
                {
                    if (posTo < min)
                        posTo = min;
                    else if (posTo > max)
                        posTo = max;
                }

                // 是否在边界内
                bool inside = posTo > min && posTo < max;
                if (inside)
                {
                    float fIdx = posTo / m_itemSizeValue;
                    posTo = (int)Mathf.Round(fIdx) * m_itemSizeValue;
                }

                // 继续滚动
                if (m_isVertical)
                    tmpVec3.Set(0, posTo, 0);
                else
                    tmpVec3.Set(posTo, 0, 0);

                if (m_contentTweener != null)
                    m_contentTweener.Kill();
                m_contentTweener = m_content.DOLocalMove(tmpVec3, duration / 2000).OnComplete(() =>
                {
                    m_contentTweener = null;
                    m_renderDirty = true;
                    if (!inside)
                        ScrollToSelectedItem();
                });

            }
            else
            {
                ScrollToSelectedItem();
            }
        }

        #endregion




        #region 编辑器相关

#if UNITY_EDITOR
        void OnValidate()
        {
            // hitArea 可在编辑器编辑
            if (m_hitArea == null)
            {
                m_hitArea = LuaHelper.CreateGameObject("HitArea", transform, false);
                Image img = m_hitArea.AddComponent<Image>();
                img.color = Color.clear;
                m_hitArea.AddComponent<PointerEventPasser>();
            }
        }
#endif


        public void SerializedPropertyChanged(bool clean)
        {
#if UNITY_EDITOR
            if (clean)
            {
                Clean();
                ResetItemSize();
            }
            m_renderDirty = true;
#endif
        }

        #endregion


        //
    }
}

