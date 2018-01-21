using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using UnityEngine.EventSystems;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 基础列表，需配合 BaseList.lua 使用
	/// </summary>
	[AddComponentMenu ("ShibaInu/Base List", 102)]
	[DisallowMultipleComponent]
	public class BaseList : UIBehaviour
	{
		
		/// 对应的 lua BaseList 对象
		public virtual LuaTable luaTarget {
			set {
				m_luaTarget = value;
				m_luaSyncPropertys = value.GetLuaFunction ("SyncPropertys");
			}
		}

		protected LuaTable m_luaTarget;
		protected LuaFunction m_luaSyncPropertys;



		#region Inspector 可编辑属性

		/// Item 的预制对象
		public GameObject itemPrefab {
			set {
				if (value != m_itemPrefab) {
					m_itemPrefab = value;
					SyncPropertysToLua ();
				}
			}
			get { return m_itemPrefab; }
		}

		[FormerlySerializedAs ("itemPrefab"), SerializeField]
		protected GameObject m_itemPrefab;


		/// 行数
		public uint rowCount {
			set {
				if (value != m_rowCount) {
					m_rowCount = value;
					SyncPropertysToLua ();
				}
			}
			get { return m_rowCount; }
		}

		[FormerlySerializedAs ("rowCount"), SerializeField]
		protected uint m_rowCount = 3;


		/// 列数
		public uint columnCount {
			set {
				if (value != m_columnCount) {
					m_columnCount = value;
					SyncPropertysToLua ();
				}
			}
			get { return m_columnCount; }
		}

		[FormerlySerializedAs ("columnCount"), SerializeField]
		protected uint m_columnCount = 3;


		/// Item 水平间隔
		public int horizontalGap {
			set {
				if (value != m_horizontalGap) {
					m_horizontalGap = value;
					SyncPropertysToLua ();
				}
			}
			get { return m_horizontalGap; }
		}

		[FormerlySerializedAs ("horizontalGap"), SerializeField]
		protected int m_horizontalGap = 0;


		/// Item 垂直间隔
		public int verticalGap {
			set {
				if (value != m_verticalGap) {
					m_verticalGap = value;
					SyncPropertysToLua ();
				}
			}
			get { return m_verticalGap; }
		}

		[FormerlySerializedAs ("verticalGap"), SerializeField]
		protected int m_verticalGap = 0;




		/// <summary>
		/// 属性有改变时，将 C# 中的属性同步到 lua 中
		/// </summary>
		protected virtual void SyncPropertysToLua ()
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
			m_luaSyncPropertys.PCall ();
			m_luaSyncPropertys.EndPCall ();
		}


		/// <summary>
		/// 同步 lua 相关属性
		/// 由 BaseList.lua 调用
		/// </summary>
		public void SyncPropertys (
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



		/// Item 容器
		public RectTransform content {
			get{ return m_content; }
		}

		protected RectTransform m_content;




		protected override void Awake ()
		{
			m_content = (RectTransform)LuaHelper.CreateGameObject ("Content", transform, false).transform;
			m_content.pivot = Vector2.up;
		}


		#if UNITY_EDITOR

		protected override void OnValidate ()
		{
			SyncPropertysToLua ();
		}

		#endif


		//
	}
}

