using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 翻页组件，可在两个界面间拖拽切换。
    /// 需配合 ViewPager.lua 使用。
    /// </summary>
    [AddComponentMenu("ShibaInu/View Pager", 105)]
    [DisallowMultipleComponent]
    public class ViewPager : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler, IInitializePotentialDragHandler
    {

        #region Inspector 可编辑属性

        [Tooltip("是否为垂直方向翻页")]
        [FormerlySerializedAs("isVertical"), SerializeField]
        protected bool m_isVertical = false;

        public bool isVertical
        {
            set { m_isVertical = value; }
            get { return m_isVertical; }
        }


        [Tooltip("视图尺寸（显示范围）")]
        [FormerlySerializedAs("viewSize"), SerializeField]
        protected Vector2 m_viewSize = new Vector2(100, 100);

        public Vector2 viewSize
        {
            set
            {
                if (!value.Equals(m_viewSize))
                {
                    m_viewSize = value;
                    ((RectTransform)transform).sizeDelta = value;
                }
            }
            get { return m_viewSize; }
        }


        [Tooltip("最大拖动比例（距离）")]
        [Range(0.5f, 1.0f)]
        [FormerlySerializedAs("maxDragScale"), SerializeField]
        protected float m_maxDragScale = 0.97f;

        public float maxDragScale
        {
            set { m_maxDragScale = value; }
            get { return m_maxDragScale; }
        }


        [Tooltip("回弹或切换时，滚动效果持续时长（秒）")]
        [FormerlySerializedAs("scrollDuration"), SerializeField]
        protected float m_scrollDuration = 0.15f;

        public float scrollDuration
        {
            set { m_scrollDuration = value; }
            get { return m_scrollDuration; }
        }


        /// 视图总数量
        public int viewCount
        {
            set
            {
                if (value < 0)
                    value = 0;
                int count = views.Count;

                if (value < count)
                {
                    if (Common.Initialized && value <= m_currentViewIndex)
                    {
                        EndScroll();
                        SetViewVisible(m_currentViewIndex, false);
                        SetViewSelected(m_currentViewIndex, false);

                        if (value == 0)
                        {
                            m_currentView = null;
                        }
                        else
                        {
                            m_currentViewIndex = value - 1;
                            m_currentView = GetView(m_currentViewIndex);
                            SetViewVisible(m_currentViewIndex, true);
                            SetViewSelected(m_currentViewIndex, true);
                        }
                    }

                    for (int i = count - 1; i > value - 1; i--)
                    {
                        GameObject view = views[i];
                        views.RemoveAt(i);
                        DispatchEvent(EVNET_REMOVED, i, view);
                    }

                }
                else if (value > count)
                {
                    for (int i = 0; i < value - count; i++)
                    {
                        views.Add(null);
                        DispatchEvent(EVNET_ADDED, views.Count - 1);
                    }
                    SelectDefaultView();
                }
            }
            get { return views.Count; }
        }

        /// 视图列表
        [NoToLua]
        public List<GameObject> views = new List<GameObject>();

#if UNITY_EDITOR
        /// 缓存的视图列表
        [NoToLua]
        public List<GameObject> viewsCache = new List<GameObject>();
#endif


        /// 当前（默认）选中视图索引
        public int currentViewIndex
        {
            set
            {
                int count = views.Count;
                if (count == 0)
                {
                    m_currentViewIndex = 0;
                    return;
                }
                if (value >= count)
                    value = count - 1;
                else if (value < 0)
                    value = 0;

                if (value != m_currentViewIndex)
                {
                    int lastViewIndex = m_currentViewIndex;
                    m_currentViewIndex = value;

                    // scroll 切换
                    if (Common.Initialized)
                    {
                        SetViewVisible(m_otherViewIndex, false);
                        m_currentView = GetView(m_currentViewIndex);
                        m_otherView = GetView(lastViewIndex);
                        m_otherViewIndex = lastViewIndex;
                        SetViewVisible(m_currentViewIndex, true);
                        SetViewVisible(m_otherViewIndex, true);

                        m_otherIsNext = lastViewIndex > m_currentViewIndex;
                        m_curScale = m_otherIsNext ? m_curScale - 1 : m_curScale + 1;
                        m_sizeVal = m_isVertical ? m_viewSize.y : m_viewSize.x;
                        StartScroll();
                    }
                }
            }
            get { return m_currentViewIndex; }
        }

        [SerializeField]
        protected int m_currentViewIndex = 0;


        /// 页面转换效果类型
        public PageTransformerType transformerType
        {
            set
            {
                m_transformerType = value;
                EndScroll();
                switch (value)
                {
                    case PageTransformerType.Scroll:
                        m_transformer = PageTransformer.Scroll;
                        break;
                    case PageTransformerType.Fade:
                        m_transformer = PageTransformer.Fade;
                        break;
                    case PageTransformerType.ZoomOut:
                        m_transformer = PageTransformer.ZoomOut;
                        break;
                    case PageTransformerType.Depth:
                        m_transformer = PageTransformer.Depth;
                        break;
                }
            }
            get { return m_transformerType; }
        }

        [SerializeField]
        protected PageTransformerType m_transformerType = PageTransformerType.Scroll;

        #endregion



        #region lua 相关

        // lua PageEvent.DispatchEvent()
        protected static LuaFunction s_dispatchEvent;


        /// 对应的 lua ViewPager 对象
        public virtual LuaTable luaTarget
        {
            set
            {
                m_luaTarget = value;
                if (s_dispatchEvent == null)
                    s_dispatchEvent = Common.luaMgr.state.GetFunction("PageEvent.DispatchEvent");
            }
        }

        protected LuaTable m_luaTarget;


        /// <summary>
        /// 在 lua 层抛出 PageEvent
        /// </summary>
        /// <param name="type">Type.</param>
        /// <param name="index">Index.</param>
        /// <param name="view">View.</param>
        /// <param name="value">If set to <c>true</c> value.</param>
        protected void DispatchEvent(string type, int index, GameObject view = null, bool value = false)
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif

            if (m_luaTarget == null)
                return;

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(m_luaTarget);
            s_dispatchEvent.Push(type);
            s_dispatchEvent.Push(index);
            s_dispatchEvent.Push(view);
            s_dispatchEvent.Push(value);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion



        #region 变量声明

        protected const string EVNET_VISIBILITY_CHANGED = "PageEvent_VisibilityChanged";
        protected const string EVNET_SELECTION_CHANGED = "PageEvent_SelectionChanged";
        protected const string EVNET_ADDED = "PageEvent_Added";
        protected const string EVNET_REMOVED = "PageEvent_Removed";

        /// 自增长key
        protected static int s_autoIncrementKey;

        /// 当前页面
        protected GameObject m_currentView;
        /// 拖动/滚动 时，显示的另外一个界面
        protected GameObject m_otherView;
        /// 另外一个界面的索引
        protected int m_otherViewIndex = -1;
        /// 上次选中视图索引
        protected int m_lastViewIndex;
        /// 显示范围值
        protected float m_sizeVal;
        /// 页面切换效果，默认：滚动
        protected Action<GameObject, float, float, bool> m_transformer;

        /// 拖动时，开始的时间
        protected float m_startTime;
        /// 拖动时，开始的位置
        protected float m_startPosVal;
        /// 当前拖动到的位置
        protected float m_curPosVal;
        /// 当前已拖动的比例（位置）
        protected float m_curScale;

        /// 是否正在回弹中或切换中
        protected bool m_scrolling;
        /// scroll 时每秒递增的 scale
        protected float m_addScale;
        /// scroll 剩余持续时间
        protected float m_remainTime;
        /// scroll 时另一个界面是否为 next view
        protected bool m_otherIsNext;

        #endregion



        #region 初始化

        void Awake()
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif

            // size
            if (gameObject.GetComponent<RectMask2D>() == null)
                gameObject.AddComponent<RectMask2D>();
            ((RectTransform)transform).sizeDelta = m_viewSize;

            // views
            if (views.Count > 0)
            {
                m_lastViewIndex = m_currentViewIndex;
                for (int i = 0; i < views.Count; i++)
                {
                    GameObject view = views[i];
                    if (view != null && view.activeSelf)
                        view.SetActive(false);// 当前选中的也设置不可见，是为了触发 visible:true

                    if (i == m_currentViewIndex)
                    {
                        if (view == null)
                            view = GetView(i);
                        m_currentView = view;
                        Vector3 pos = view.transform.localPosition;
                        pos.x = pos.y = 0;// 保留 z
                        view.transform.localPosition = pos;
                        SetViewVisible(m_currentViewIndex, true);
                        SetViewSelected(m_currentViewIndex, true);
                    }
                }
            }

            // transformer
            transformerType = m_transformerType;
        }

        #endregion



        #region 拖拽翻页

        public void OnBeginDrag(PointerEventData eventData)
        {
            if (views.Count == 0)
                return;

            m_scrolling = false;
            m_curScale = 0;
            m_startTime = TimeUtil.GetTimeSec();
            m_startPosVal = (m_isVertical ? eventData.position.y : eventData.position.x) * Common.GetFixedScreenScale();
            m_sizeVal = m_isVertical ? m_viewSize.y : m_viewSize.x;
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (views.Count == 0)
                return;

            DragHandler(eventData);
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            if (views.Count == 0)
                return;

            DragHandler(eventData);

            // 拖动距离 或 拖动速度 已经达到切换至下一个界面的限定值
            float speed = (m_curPosVal - m_startPosVal) / (TimeUtil.GetTimeSec() - m_startTime);
            bool isFlip = Mathf.Abs(m_curScale) > 0.4f || speed > 500;

            // other view is next?
            if (m_isVertical)
                m_otherIsNext = m_curPosVal > m_startPosVal;
            else
                m_otherIsNext = m_curPosVal < m_startPosVal;

            // 翻页
            if (isFlip && m_otherView != null)
            {
                m_otherView = m_currentView;
                m_otherViewIndex = m_currentViewIndex;
                m_currentViewIndex += m_otherIsNext ? 1 : -1;
                m_currentView = GetView(m_currentViewIndex);
                m_curScale = m_otherIsNext ? m_curScale + 1 : m_curScale - 1;
                m_otherIsNext = !m_otherIsNext;
            }
            StartScroll();
        }


        public void OnInitializePotentialDrag(PointerEventData eventData)
        {
            // 兼容其他实现了 IInitializePotentialDragHandler 接口的组件
        }


        protected void DragHandler(PointerEventData eventData)
        {
            Vector2 pos = eventData.position * Common.GetFixedScreenScale();
            m_curPosVal = m_isVertical ? pos.y : pos.x;
            float scale = Mathf.Abs((m_curPosVal - m_startPosVal) / m_sizeVal);
            // 超过一半尺寸 scale 开始衰减
            if (scale > 0.5f)
            {
                scale -= 0.5f;
                if (scale > 5f)
                    scale = 5f;
                scale = Mathf.Sin(scale * 0.5f);
                scale += 0.5f;
                if (scale > m_maxDragScale)
                    scale = m_maxDragScale;
            }

            // 没有拖动值（刚开始拖动时）
            if (scale == 0)
                return;

            bool otherIsNext = false;
            if (m_isVertical)
            {
                // 向上拖动
                if (m_curPosVal > m_startPosVal)
                {
                    otherIsNext = true;
                    scale = -scale;
                }
            }
            else
            {
                // 向左拖动
                if (m_curPosVal < m_startPosVal)
                {
                    otherIsNext = true;
                    scale = -scale;
                }
            }
            m_curScale = scale;

            // 显示另一个界面
            int otherViewIndex = m_currentViewIndex + (otherIsNext ? 1 : -1);
            GameObject otherView = GetView(otherViewIndex);
            if (otherView != m_otherView)
            {
                SetViewVisible(m_otherViewIndex, false);
                m_otherView = otherView;
                m_otherViewIndex = otherViewIndex;
                SetViewVisible(otherViewIndex, true);
            }

            // 调用 Page Transformer
            m_transformer(m_currentView, scale, m_sizeVal, m_isVertical);
            if (m_otherView != null)
                m_transformer(m_otherView, scale + (otherIsNext ? 1 : -1), m_sizeVal, m_isVertical);
        }

        #endregion



        #region scroll 回弹或切换

        /// <summary>
        /// 开始回弹或切换
        /// </summary>
        protected void StartScroll()
        {
            m_addScale = -m_curScale / m_scrollDuration;
            m_remainTime = m_scrollDuration > 0 ? m_scrollDuration : -1;
            m_remainTime = m_scrollDuration;
            m_scrolling = true;
        }

        /// <summary>
        /// 立即结束回弹或切换，触发 view selected
        /// </summary>
        protected void EndScroll()
        {
            if (m_scrolling)
            {
                m_remainTime = -1;
                Update();
            }
            else
            {
                m_otherView = null;
                m_otherViewIndex = -1;
            }
        }


        void Update()
        {
            if (!m_scrolling)
            {
                return;
            }

            float deltaTime = Time.deltaTime;
            if (deltaTime < m_remainTime)
            {
                m_remainTime -= deltaTime;
                m_curScale += m_addScale * deltaTime;
            }
            else
            {
                m_curScale = 0;
            }
            m_transformer(m_currentView, m_curScale, m_sizeVal, m_isVertical);
            if (m_otherView != null)
                m_transformer(m_otherView, m_curScale + (m_otherIsNext ? 1 : -1), m_sizeVal, m_isVertical);

            // end scrolling
            if (m_curScale == 0)
            {
                m_scrolling = false;
                // transformer 还原
                m_transformer(m_currentView, 0, m_sizeVal, m_isVertical);
                if (m_otherView != null)
                    m_transformer(m_otherView, 0, m_sizeVal, m_isVertical);

                SetViewVisible(m_otherViewIndex, false);
                m_otherView = null;
                m_otherViewIndex = -1;
                if (m_lastViewIndex != m_currentViewIndex)
                {
                    SetViewSelected(m_lastViewIndex, false);
                    SetViewSelected(m_currentViewIndex, true);
                    m_lastViewIndex = m_currentViewIndex;
                }

            }
        }

        #endregion



        #region view 相关操作

        /// <summary>
        /// 通过 index 来获取界面
        /// </summary>
        /// <returns>The view.</returns>
        /// <param name="index">Index.</param>
        public virtual GameObject GetView(int index)
        {
            if (index >= views.Count || index < 0)
                return null;

            // 如果界面不存在，创建一个空节点
            GameObject view = views[index];
            if (view == null)
            {
                view = new GameObject("view" + (++s_autoIncrementKey), typeof(RectTransform));
                Transform tra = view.transform;
                tra.SetParent(transform);
                tra.localScale = Vector3.one;
                tra.localPosition = Vector3.zero;
                view.layer = gameObject.layer;
                views[index] = view;
                view.SetActive(false);// 默认不可见，之后使用时可先触发 visible:true
            }

            return view;
        }

        /// <summary>
        /// 获取界面对应的索引
        /// </summary>
        /// <returns>The view index.</returns>
        /// <param name="view">View.</param>
        public int GetViewIndex(GameObject view)
        {
            if (view == null)
                return -1;
            return views.IndexOf(view);
        }

        /// <summary>
        /// 获取当前页
        /// </summary>
        /// <returns>The current view.</returns>
        public GameObject GetCurrentView()
        {
            return m_currentView;
        }

        /// <summary>
        /// 获取当前页索引
        /// </summary>
        /// <returns>The current view index.</returns>
        public int GetCurrentViewIndex()
        {
            return m_currentViewIndex;
        }



        /// <summary>
        /// 添加一个界面到末尾，并返回该界面的索引
        /// </summary>
        /// <returns>The view.</returns>
        /// <param name="view">View.</param>
        public int AddView(GameObject view = null)
        {
            int index = views.Count;
            views.Add(view);
            SelectDefaultView();
            DispatchEvent(EVNET_ADDED, index, view);
            return index;
        }

        /// <summary>
        /// 将元界面插入指定索引处
        /// </summary>
        /// <param name="index">Index.</param>
        /// <param name="view">View.</param>
        public void InsertView(int index, GameObject view = null)
        {
            EndScroll();
            views.Insert(index, view);
            // 插入在当前位置或之前位置
            if (index <= m_currentViewIndex)
            {
                m_currentViewIndex = m_lastViewIndex = m_currentViewIndex + 1;
            }
            SelectDefaultView();
        }

        /// <summary>
        /// 移除指定索引的界面，并返回该界面
        /// </summary>
        /// <returns>The <see cref="UnityEngine.GameObject"/>.</returns>
        /// <param name="index">Index.</param>
        public GameObject RemoveViewAt(int index)
        {
            EndScroll();
            GameObject view = views[index];

            if (index == m_currentViewIndex)
            {
                // 移除的是当前位置
                SetViewVisible(m_currentViewIndex, false);
                SetViewSelected(m_currentViewIndex, false);
                views.RemoveAt(index);
                if (views.Count > 0)
                {
                    if (m_currentViewIndex >= views.Count)
                        m_currentViewIndex = views.Count - 1;
                    m_currentView = GetView(m_currentViewIndex);
                    SetViewVisible(m_currentViewIndex, true);
                    SetViewSelected(m_currentViewIndex, true);

                }
                else
                {
                    // 已经没有 item 了
                    m_currentViewIndex = 0;
                    m_lastViewIndex = -1;
                    m_currentView = null;
                }

            }
            else if (index < m_currentViewIndex)
            {
                // 移除的是之前位置
                m_currentViewIndex = m_lastViewIndex = m_currentViewIndex - 1;
                views.RemoveAt(index);

            }
            else
            {
                // 移除的是之后的位置
                views.RemoveAt(index);
            }

            DispatchEvent(EVNET_REMOVED, index, view);
            return view;
        }

        /// <summary>
        /// 移除指定界面，并返回该界面
        /// </summary>
        /// <returns>The view.</returns>
        /// <param name="view">View.</param>
        public GameObject RemoveView(GameObject view)
        {
            if (view != null)
            {
                return RemoveViewAt(views.IndexOf(view));
            }
            return null;
        }

        /// <summary>
        /// 将指定索引处的界面（oldView）替换成 newView，并返回 oldView
        /// 该操作可能会触发：
        ///   oldView visible:false, selected:false
        ///   newView visible:true, newView:true
        /// </summary>
        /// <returns>The <see cref="UnityEngine.GameObject"/>.</returns>
        /// <param name="index">Index.</param>
        /// <param name="newView">New view.</param>
        public GameObject SetViewAt(int index, GameObject newView)
        {
            EndScroll();
            GameObject oldView = views[index];
            bool isCurView = index == m_currentViewIndex;

            // 先将老界面隐藏以及取消选中
            SetViewVisible(index, false);
            if (isCurView)
                SetViewSelected(m_currentViewIndex, false);

            // 显示新界面以及选中
            views[index] = newView;
            if (isCurView)
            {
                if (newView == null)
                    newView = GetView(index);
                else
                    newView.SetActive(false);// 为了触发 visible:true

                m_currentView = newView;
                SetViewVisible(index, true);
                SetViewSelected(m_currentViewIndex, true);
            }

            return oldView;
        }

        /// <summary>
        /// 将 oldView 替换成 newView，并返回 oldView
        /// 该操作可能会触发：
        ///   oldView visible:false, selected:false
        ///   newView visible:true, newView:true
        /// </summary>
        /// <returns>The view.</returns>
        /// <param name="oldView">Old view.</param>
        /// <param name="newView">New view.</param>
        public GameObject SetView(GameObject oldView, GameObject newView)
        {
            if (oldView != null)
            {
                int index = views.IndexOf(oldView);
                if (index != -1)
                    return SetViewAt(index, newView);
            }
            return null;
        }



        /// <summary>
        /// 设置界面是否可见
        /// </summary>
        /// <param name="index">Index.</param>
        /// <param name="visible">If set to <c>true</c> visible.</param>
        protected void SetViewVisible(int index, bool visible)
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif

            GameObject view = GetView(index);
            if (view == null)
                return;

            bool changed = visible ? !view.activeSelf : view.activeSelf;
            if (changed)
            {
                view.SetActive(visible);
                DispatchEvent(EVNET_VISIBILITY_CHANGED, index, view, visible);
            }
        }

        /// <summary>
        /// 设置界面是否选中
        /// </summary>
        /// <param name="index">Index.</param>
        /// <param name="selected">If set to <c>true</c> selected.</param>
        protected void SetViewSelected(int index, bool selected)
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif

            GameObject view = GetView(index);
            if (view == null)
                return;

            DispatchEvent(EVNET_SELECTION_CHANGED, index, view, selected);
        }

        /// <summary>
        /// 选中默认的视图
        /// </summary>
        protected void SelectDefaultView()
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif

            if (m_currentView == null && views.Count > 0)
            {
                m_currentViewIndex = 0;
                m_currentView = GetView(0);
                SetViewVisible(0, true);
                SetViewSelected(0, true);
            }
        }

        #endregion



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

