using System;
using UnityEngine;
using UnityEngine.Serialization;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 翻页列表，需配合 PageList.lua 使用
    /// </summary>
    [AddComponentMenu("ShibaInu/Page List", 103)]
    [DisallowMultipleComponent]
    public class PageList : ViewPager
    {

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
        protected int m_horizontalGap = 0;


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
        protected int m_verticalGap = 0;

        #endregion



        #region lua 相关

        /// 对应的 lua PageList 对象
        public override LuaTable luaTarget
        {
            set
            {
                base.luaTarget = value;
                m_luaSyncPropertys = value.GetLuaFunction("SyncPropertys");
            }
        }

        protected LuaFunction m_luaSyncPropertys;


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
        /// 由 PageList.lua 调用
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


#if UNITY_EDITOR
        void OnValidate()
        {
            SyncPropertysToLua();
        }
#endif

        #endregion



        #region override

        /// 获取 item 容器（兼容 BaseList.lua）
        public RectTransform content
        {
            get { return null; }
        }


        /// <summary>
        /// 通过 index 来获取界面
        /// </summary>
        /// <returns>The view.</returns>
        /// <param name="index">Index.</param>
        public override GameObject GetView(int index)
        {
            if (index >= views.Count || index < 0)
                return null;

            if (views[index] != null)
                return views[index];

            // 新创建的 view
            GameObject view = base.GetView(index);
            LuaHelper.CreateGameObject("Content", view.transform, false);// items 容器
            return view;
        }

        #endregion


        //
    }
}

