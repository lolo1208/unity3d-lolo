using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
	[CustomEditor (typeof(ScrollList))]
	public class ScrollListEditor : BaseListEditor
	{
		protected SerializedProperty m_viewportSize;

		private ScrollList m_scrollList;



		protected override void OnEnable ()
		{
			base.OnEnable ();

			m_scrollList = (ScrollList)target;

			m_viewportSize = serializedObject.FindProperty ("m_viewportSize");
		}


		public override void OnInspectorGUI ()
		{
			base.OnInspectorGUI ();

			// direction
			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("Direction", "滚动方向"), GUILayout.Width (m_labelWidth));
			bool isVertical = m_scrollList.isVertical;
			bool isH = GUILayout.Toggle (!isVertical, new GUIContent ("Horizontal", "水平"), GUILayout.Width (m_halfWidth));
			bool isV = GUILayout.Toggle (isVertical, new GUIContent ("Vertical", "垂直"), GUILayout.Width (m_halfWidth));
			if (isVertical) {
				if (isH)
					m_scrollList.isVertical = false;
			} else {
				if (isV)
					m_scrollList.isVertical = true;
			}
			EditorGUILayout.EndHorizontal ();
			m_rowCountDisabled = m_scrollList.isVertical;
			m_columnCountDisabled = !m_scrollList.isVertical;


			// viewport size
			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("Viewport Size", "显示范围 [ 宽, 高 ]"), GUILayout.Width (m_labelWidth));
			Vector2 viewportSize = m_viewportSize.vector2Value;
			int vpw = EditorGUILayout.IntField ((int)viewportSize.x, GUILayout.Width (m_halfWidth));
			int vph = EditorGUILayout.IntField ((int)viewportSize.y, GUILayout.Width (m_halfWidth));
			m_scrollList.SetViewportSize ((uint)(vpw < 0 ? 0 : vpw), (uint)(vph < 0 ? 0 : vph));
			EditorGUILayout.EndHorizontal ();


			serializedObject.ApplyModifiedProperties ();
		}


		//
	}
}

