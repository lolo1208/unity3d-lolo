using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 基础列表，需配合 BaseList.lua 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Base List", 101)]
    [DisallowMultipleComponent]
    public class BaseList : MonoBehaviour
    {
        protected const string ELEMENT_CONTENT = "Content";


        /// 对应的 lua BaseList 对象
        public virtual LuaTable luaTarget
        {
            set
            {
                m_luaTarget = value;
                m_luaSyncPropertys = value.GetLuaFunction("SyncPropertys");
                Initialize();
            }
        }

        protected LuaTable m_luaTarget;
        protected LuaFunction m_luaSyncPropertys;



        #region Inspector 可编辑属性

        /// Item 的预制对象
        public GameObject itemPrefab
        {
            set
            {
                if (value != m_itemPrefab)
                {
                    m_itemPrefab = value;
                    SyncPropertysToLua();
                }
            }
            get { return m_itemPrefab; }
        }

        [FormerlySerializedAs("itemPrefab"), SerializeField]
        protected GameObject m_itemPrefab;


        /// 行数
        public uint rowCount
        {
            set
            {
                if (value != m_rowCount)
                {
                    m_rowCount = value;
                    SyncPropertysToLua();
                }
            }
            get { return m_rowCount; }
        }

        [FormerlySerializedAs("rowCount"), SerializeField]
        protected uint m_rowCount = 3;


        /// 列数
        public uint columnCount
        {
            set
            {
                if (value != m_columnCount)
                {
                    m_columnCount = value;
                    SyncPropertysToLua();
                }
            }
            get { return m_columnCount; }
        }

        [FormerlySerializedAs("columnCount"), SerializeField]
        protected uint m_columnCount = 3;


        /// Item 水平间隔
        public int horizontalGap
        {
            set
            {
                if (value != m_horizontalGap)
                {
                    m_horizontalGap = value;
                    SyncPropertysToLua();
                }
            }
            get { return m_horizontalGap; }
        }

        [FormerlySerializedAs("horizontalGap"), SerializeField]
        protected int m_horizontalGap;


        /// Item 垂直间隔
        public int verticalGap
        {
            set
            {
                if (value != m_verticalGap)
                {
                    m_verticalGap = value;
                    SyncPropertysToLua();
                }
            }
            get { return m_verticalGap; }
        }

        [FormerlySerializedAs("verticalGap"), SerializeField]
        protected int m_verticalGap;



        /// 是否根据当前节点尺寸，来设置显示区域尺寸和位置
        public virtual bool isAutoSize
        {
            set { m_isAutoSize = value; }
            get { return m_isAutoSize; }
        }

        [FormerlySerializedAs("isAutoSize"), SerializeField]
        protected bool m_isAutoSize;


        /// 是否根据显示区域自动调整 item 数量
        public bool isAutoItemCount
        {
            set { m_isAutoItemCount = value; }
            get { return m_isAutoItemCount; }
        }

        [FormerlySerializedAs("isAutoItemCount"), SerializeField]
        protected bool m_isAutoItemCount;


        /// 是否根据显示区域自动调整 item 间隔
        public bool isAutoItemGap
        {
            set { m_isAutoItemGap = value; }
            get { return m_isAutoItemGap; }
        }

        [FormerlySerializedAs("isAutoItemGap"), SerializeField]
        protected bool m_isAutoItemGap;



        /// <summary>
        /// 属性有改变时，将 C# 中的属性同步到 lua 中
        /// </summary>
        protected virtual void SyncPropertysToLua()
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
            m_luaSyncPropertys.PCall();
            m_luaSyncPropertys.EndPCall();
        }


        /// <summary>
        /// 同步 lua 相关属性
        /// 由 BaseList.lua 调用
        /// </summary>
        public void SyncPropertys(
            GameObject itmePrefab,
            uint rowCount,
            uint columnCount,
            int horizontalGap,
            int verticalGap
        )
        {
            m_itemPrefab = itmePrefab;
            m_rowCount = rowCount;
            m_columnCount = columnCount;
            m_horizontalGap = horizontalGap;
            m_verticalGap = verticalGap;
        }

        #endregion



        /// 获取 item 容器
        public RectTransform content
        {
            get { return m_content; }
        }

        protected RectTransform m_content;



        /// <summary>
        /// 初始化
        /// </summary>
        protected virtual void Initialize()
        {
            if (m_initialized) return;
            m_initialized = true;

            m_content = CreateOrGetElement_Content();
        }

        protected bool m_initialized;



        /// <summary>
        /// 创建或获取子节点 ELEMENT_CONTENT
        /// </summary>
        /// <returns>The or get element content.</returns>
        protected virtual RectTransform CreateOrGetElement_Content()
        {
            RectTransform tra = (RectTransform)transform.Find(ELEMENT_CONTENT);
            if (tra == null)
            {
                tra = (RectTransform)new GameObject(ELEMENT_CONTENT, typeof(RectTransform))
                { layer = gameObject.layer }.transform;
                tra.SetParent(transform, false);
                tra.anchorMin = Vector2.zero;
                tra.anchorMax = Vector2.one;
                tra.sizeDelta = Vector2.zero;
            }
            return tra;
        }



#if UNITY_EDITOR

        void OnValidate()
        {
            SyncPropertysToLua();
        }


        [NoToLua]
        public virtual bool CreateElements()
        {
            if (transform.Find(ELEMENT_CONTENT) == null)
            {
                CreateOrGetElement_Content();
                return true;
            }
            return false;
        }

#endif

        //
    }
}

