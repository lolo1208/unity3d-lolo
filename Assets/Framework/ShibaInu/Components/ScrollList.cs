using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using UnityEngine.EventSystems;
using LuaInterface;
using DG.Tweening;


namespace ShibaInu
{
    /// <summary>
    /// 滚动列表，需配合 ScrollList.lua 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Scroll List", 102)]
    [DisallowMultipleComponent]
    public class ScrollList : BaseList, IInitializePotentialDragHandler
    {
        protected const string ELEMENT_VIEWPORT = "Viewport";


        /// 对应的 lua ScrollList 对象
        public override LuaTable luaTarget
        {
            set
            {
                base.luaTarget = value;
                m_luaUpdate = value.GetLuaFunction("UpdateScroll");
            }
        }
        protected LuaFunction m_luaUpdate;



        /// 是否为垂直方向滚动
        public bool isVertical
        {
            set
            {
                if (value != m_isVertical)
                {
                    m_isVertical = value;
                    if (m_scrollRect)
                    {
                        m_scrollRect.horizontal = !m_isVertical;
                        m_scrollRect.vertical = m_isVertical;
                    }
                    ResetContentPosition();
                    SyncPropertysToLua();
                }
            }
            get { return m_isVertical; }
        }

        [FormerlySerializedAs("isVertical"), SerializeField]
        protected bool m_isVertical = true;



        /// <summary>
        /// 设置显示区域宽高
        /// </summary>
        /// <param name="width">Width.</param>
        /// <param name="height">Height.</param>
        public void SetViewportSize(uint width, uint height)
        {
            m_viewportSize.Set(width, height);
            if (!m_isAutoSize && m_viewport)
                m_viewport.sizeDelta = m_viewportSize;
            ResetContentPosition();
            SyncPropertysToLua();
        }

        public Vector2 GetViewportSize() { return m_viewportSize; }

        [FormerlySerializedAs("viewportSize"), SerializeField]
        protected Vector2 m_viewportSize = new Vector2(100, 100);



        /// <summary>
        /// 设置滚动内容宽高
        /// 由 ScrollList.lua 调用
        /// </summary>
        /// <param name="width">Width.</param>
        /// <param name="height">Height.</param>
        public void SetContentSize(uint width, uint height)
        {
            m_content.sizeDelta = new Vector2(width, height);
            ResetContentPosition();
        }



        /// 显示区域容器
        public RectTransform viewport
        {
            get { return m_viewport; }
        }
        protected RectTransform m_viewport;


        /// 对应的 ScrollRect 组件
        public ScrollRect scrollRect
        {
            get { return m_scrollRect; }
        }
        protected ScrollRect m_scrollRect;


        /// 是否根据当前节点尺寸，来设置显示区域尺寸和位置
        public override bool isAutoSize
        {
            set
            {
                if (value == m_isAutoSize) return;

                m_isAutoSize = value;
                RectTransform viewport = CreateOrGetElement_Viewport();
                if (viewport != null)
                {
                    if (value)
                    {
                        viewport.anchorMin = Vector2.zero;
                        viewport.anchorMax = Vector2.one;
                        viewport.sizeDelta = Vector2.zero;
                    }
                    else
                    {
                        viewport.anchorMin = viewport.anchorMax = new Vector2(0.5f, 0.5f);
                        viewport.sizeDelta = new Vector2(100, 100);
                    }
                }
            }
            get { return m_isAutoSize; }
        }



        /// <summary>
        /// 属性有改变时，将 C# 中的属性同步到 lua 中
        /// </summary>
        protected override void SyncPropertysToLua()
        {
            if (m_luaSyncPropertys == null)
                return;

            m_luaSyncPropertys.BeginPCall();
            m_luaSyncPropertys.Push(m_luaTarget);
            m_luaSyncPropertys.Push(m_itemPrefab);
            m_luaSyncPropertys.Push(m_rowCount);
            m_luaSyncPropertys.Push(m_columnCount);
            m_luaSyncPropertys.Push(m_horizontalGap);
            m_luaSyncPropertys.Push(m_verticalGap);
            m_luaSyncPropertys.Push(m_isVertical);
            m_luaSyncPropertys.Push(m_viewportSize.x);
            m_luaSyncPropertys.Push(m_viewportSize.y);
            m_luaSyncPropertys.PCall();
            m_luaSyncPropertys.EndPCall();
        }


        /// <summary>
        /// 同步 lua 相关属性
        /// 由 ScrollList.lua 调用
        /// </summary>
        public void SyncPropertys(
            GameObject itmePrefab,
            uint rowCount,
            uint columnCount,
            int horizontalGap,
            int verticalGap,
            bool isVertical,
            uint viewportWidth,
            uint viewportHeight
        )
        {
            m_itemPrefab = itmePrefab;
            m_rowCount = rowCount;
            m_columnCount = columnCount;
            m_horizontalGap = horizontalGap;
            m_verticalGap = verticalGap;

            m_isVertical = isVertical;
            m_scrollRect.horizontal = !m_isVertical;
            m_scrollRect.vertical = m_isVertical;

            m_viewportSize.Set(viewportWidth, viewportHeight);
            if (!m_isAutoSize)
                m_viewport.sizeDelta = m_viewportSize;
        }



        /// <summary>
        /// ScrollRect 滚动中
        /// </summary>
        /// <param name="value">Value.</param>
        private void ScrollRect_ValueChanged(Vector2 value)
        {
            try
            {
                m_luaUpdate.BeginPCall();
                m_luaUpdate.Push(m_luaTarget);
                m_luaUpdate.PCall();
                m_luaUpdate.EndPCall();
            }
            catch { } // Relaunch() 时，该函数会被触发一次，但那时 m_luaUpdate 已被销毁
        }


        /// <summary>
        /// 在 viewportSize 和 isVertical 更改时，需要根据 isVertical 重新设置内容的位置
        /// </summary>
        public void ResetContentPosition()
        {
            if (m_content)
            {
                Vector3 pos = m_content.localPosition;
                if (m_isVertical)
                    pos.x = 0f;
                else
                    pos.y = 0f;
                m_content.localPosition = pos;
            }
        }



        /// <summary>
        /// 滚动到指定位置 0~1
        /// </summary>
        /// <param name="position">Position.</param>
        /// <param name="duration">Duration.</param>
        /// <param name="ease">Ease.</param>
        public void ScrollToPosition(float position, float duration = 0.4f, Ease ease = Ease.OutCubic)
        {
            OnInitializePotentialDrag();

            position = Mathf.Max(0, Mathf.Min(position, 1));
            if (duration > 0)
            {
                if (m_isVertical)
                    m_scrollTweener = m_scrollRect.DOVerticalNormalizedPos(position, duration).SetEase(ease);
                else
                    m_scrollTweener = m_scrollRect.DOHorizontalNormalizedPos(position, duration).SetEase(ease);
            }
            else
            {
                if (m_isVertical)
                    m_scrollRect.verticalNormalizedPosition = position;
                else
                    m_scrollRect.horizontalNormalizedPosition = position;
            }
        }

        [NoToLua]
        public void OnInitializePotentialDrag(PointerEventData eventData = null)
        {
            if (m_scrollTweener != null)
            {
                m_scrollTweener.Kill();
                m_scrollTweener = null;
            }
        }

        private Tweener m_scrollTweener;



        /// <summary>
        /// 初始化
        /// </summary>
        protected override void Initialize()
        {
            if (m_initialized) return;
            m_initialized = true;

            // 创建子节点和组件，并赋值
            m_viewport = CreateOrGetElement_Viewport();
            m_content = CreateOrGetElement_Content();
            AddAllComponents();

            m_scrollRect = gameObject.GetComponent<ScrollRect>();
            m_scrollRect.content = m_content;
            m_scrollRect.viewport = m_viewport;
            m_scrollRect.horizontal = !m_isVertical;
            m_scrollRect.vertical = m_isVertical;
            m_scrollRect.onValueChanged.AddListener(ScrollRect_ValueChanged);
        }



        /// <summary>
        /// 创建或获取子节点 ELEMENT_VIEWPORT
        /// </summary>
        /// <returns>The or get element content.</returns>
        protected virtual RectTransform CreateOrGetElement_Viewport()
        {
            RectTransform tra = (RectTransform)transform.Find(ELEMENT_VIEWPORT);
            if (tra == null)
            {
                tra = (RectTransform)new GameObject(ELEMENT_VIEWPORT, typeof(RectTransform))
                { layer = gameObject.layer }.transform;
                tra.SetParent(transform, false);
                tra.pivot = Vector2.up;
                m_isAutoSize = !m_isAutoSize;
                isAutoSize = !m_isAutoSize;
            }
            return tra;
        }


        /// <summary>
        /// 创建或获取子节点 ELEMENT_CONTENT
        /// </summary>
        /// <returns>The or get element content.</returns>
        protected override RectTransform CreateOrGetElement_Content()
        {
            RectTransform viewport = (RectTransform)transform.Find(ELEMENT_VIEWPORT);
            RectTransform tra = (RectTransform)viewport.Find(ELEMENT_CONTENT);
            if (tra == null)
            {
                tra = (RectTransform)new GameObject(ELEMENT_CONTENT, typeof(RectTransform))
                { layer = gameObject.layer }.transform;
                tra.SetParent(viewport, false);
                tra.pivot = Vector2.up;
            }
            return tra;
        }


        /// <summary>
        /// 添加所需组件，包括子节点
        /// </summary>
        /// <returns><c>true</c>, if children components was added, <c>false</c> otherwise.</returns>
        private bool AddAllComponents()
        {
            bool dirty = false;
            GameObject viewport = transform.Find(ELEMENT_VIEWPORT).gameObject;

            if (gameObject.GetComponent<ScrollRect>() == null)
            {
                gameObject.AddComponent<ScrollRect>();
                dirty = true;
            }

            if (viewport.GetComponent<RectMask2D>() == null)
            {
                viewport.AddComponent<RectMask2D>();
                dirty = true;
            }
            if (viewport.GetComponent<Image>() == null)
            {
                viewport.AddComponent<Image>().color = Color.clear;
                dirty = true;
            }

            return dirty;
        }



#if UNITY_EDITOR

        [NoToLua]
        public override bool CreateElements()
        {
            bool dirty = false;

            Transform viewport = transform.Find(ELEMENT_VIEWPORT);
            if (viewport == null)
            {
                viewport = CreateOrGetElement_Viewport();
                dirty = true;
            }

            if (viewport.Find(ELEMENT_CONTENT) == null)
            {
                CreateOrGetElement_Content();
                dirty = true;
            }

            dirty = dirty || AddAllComponents();

            return dirty;
        }

#endif

        //
    }
}

