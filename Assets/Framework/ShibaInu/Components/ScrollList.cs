using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 滚动列表，需配合 ScrollList.lua 使用
	/// </summary>
	[AddComponentMenu ("ShibaInu/Scroll List", 103)]
	[DisallowMultipleComponent]
	public class ScrollList : BaseList
	{
		/// 对应的 lua ScrollList 对象
		public override LuaTable luaTarget {
			set {
				base.luaTarget = value;
				m_luaUpdate = value.GetLuaFunction ("Update");
			}
		}

		protected LuaFunction m_luaUpdate;



		/// 是否为垂直方向滚动
		public bool isVertical {
			set {
				if (value != m_isVertical) {
					m_isVertical = value;
					if (m_scrollRect) {
						m_scrollRect.horizontal = !m_isVertical;
						m_scrollRect.vertical = m_isVertical;
					}
					ResetContentPosition ();
					SyncPropertysToLua ();
				}
			}
			get { return m_isVertical; }
		}

		[FormerlySerializedAs ("isVertical"), SerializeField]
		protected bool m_isVertical = true;




		/// <summary>
		/// 设置显示区域宽高
		/// </summary>
		/// <param name="width">Width.</param>
		/// <param name="height">Height.</param>
		public void SetViewportSize (uint width, uint height)
		{
			m_viewportSize.Set (width, height);
			if (m_viewport)
				m_viewport.sizeDelta = m_viewportSize;
			ResetContentPosition ();
			SyncPropertysToLua ();
		}

		[FormerlySerializedAs ("viewportSize"), SerializeField]
		protected Vector2 m_viewportSize = new Vector2 (100, 100);



		/// <summary>
		/// 设置滚动内容宽高
		/// 由 ScrollList.lua 调用
		/// </summary>
		/// <param name="width">Width.</param>
		/// <param name="height">Height.</param>
		public void SetContentSize (uint width, uint height)
		{
			m_content.sizeDelta = new Vector2 (width, height);
		}



		/// 显示区域容器
		public RectTransform viewport {
			get{ return m_viewport; }
		}

		protected RectTransform m_viewport;


		/// 对应的 ScrollRect 组件
		public ScrollRect scrollRect { 
			get { return m_scrollRect; }
		}

		protected ScrollRect m_scrollRect;



		/// <summary>
		/// 属性有改变时，将 C# 中的属性同步到 lua 中
		/// </summary>
		protected override void SyncPropertysToLua ()
		{
			if (m_luaSyncPropertys == null)
				return;

			m_luaSyncPropertys.BeginPCall ();
			m_luaSyncPropertys.Push (m_luaTarget);
			m_luaSyncPropertys.Push (m_itemPrefab);
			m_luaSyncPropertys.Push (m_rowCount);
			m_luaSyncPropertys.Push (m_columnCount);
			m_luaSyncPropertys.Push (m_horizontalGap);
			m_luaSyncPropertys.Push (m_verticalGap);
			m_luaSyncPropertys.Push (m_isVertical);
			m_luaSyncPropertys.Push (m_viewportSize.x);
			m_luaSyncPropertys.Push (m_viewportSize.y);
			m_luaSyncPropertys.PCall ();
			m_luaSyncPropertys.EndPCall ();
		}


		/// <summary>
		/// 同步 lua 相关属性
		/// 由 ScrollList.lua 调用
		/// </summary>
		public void SyncPropertys (
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

			m_viewportSize.Set (viewportWidth, viewportHeight);
			m_viewport.sizeDelta = m_viewportSize;
		}



		protected override void Awake ()
		{
			GameObject viewport = LuaHelper.CreateGameObject ("Viewport", transform, false);
			Mask mask = viewport.gameObject.AddComponent<Mask> ();
			mask.showMaskGraphic = false;
			viewport.gameObject.AddComponent<Image> ();
			m_viewport = (RectTransform)viewport.transform;
			m_viewport.pivot = Vector2.up;
			m_viewport.sizeDelta = m_viewportSize;

			m_content = (RectTransform)LuaHelper.CreateGameObject ("Content", m_viewport, false).transform;
			m_content.pivot = Vector2.up;

			m_scrollRect = gameObject.AddComponent<ScrollRect> ();
			m_scrollRect.content = m_content;
			m_scrollRect.viewport = m_viewport;
			m_scrollRect.horizontal = !m_isVertical;
			m_scrollRect.vertical = m_isVertical;
			m_scrollRect.onValueChanged.AddListener (ScrollRect_ValueChanged);
		}



		/// <summary>
		/// ScrollRect 滚动中
		/// </summary>
		/// <param name="value">Value.</param>
		private void ScrollRect_ValueChanged (Vector2 value)
		{
			m_luaUpdate.BeginPCall ();
			m_luaUpdate.Push (m_luaTarget);
			m_luaUpdate.PCall ();
			m_luaUpdate.EndPCall ();
		}


		/// <summary>
		/// 在 viewportSize 和 isVertical 更改时，需要根据 isVertical 重新设置内容的位置
		/// </summary>
		public void ResetContentPosition ()
		{
			if (m_content) {
				Vector3 pos = m_content.localPosition;
				if (m_isVertical)
					pos.x = 0f;
				else
					pos.y = 0f;
				m_content.localPosition = pos;
			}
		}


		//
	}
}

