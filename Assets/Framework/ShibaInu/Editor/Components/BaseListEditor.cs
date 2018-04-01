using System;
using UnityEngine;
using UnityEditor;

namespace ShibaInu
{
	[CustomEditor (typeof(BaseList))]
	public class BaseListEditor : BaseEditor
	{
		protected SerializedProperty m_itemPrefab;
		// protected SerializedProperty m_columnCount;
		// protected SerializedProperty m_rowCount;
		// protected SerializedProperty m_horizontalGap;
		// protected SerializedProperty m_verticalGap;

		protected bool m_rowCountDisabled = false;
		protected bool m_columnCountDisabled = false;

		private BaseList m_baseList;


		protected virtual void OnEnable ()
		{
			m_baseList = (BaseList)target;

			m_itemPrefab = serializedObject.FindProperty ("m_itemPrefab");
			// m_columnCount = serializedObject.FindProperty ("m_columnCount");
			// m_rowCount = serializedObject.FindProperty ("m_rowCount");
			// m_horizontalGap = serializedObject.FindProperty ("m_horizontalGap");
			// m_verticalGap = serializedObject.FindProperty ("m_verticalGap");
		}


		public override void OnInspectorGUI ()
		{
			base.OnInspectorGUI ();

			// item prefab
			EditorGUILayout.PropertyField (m_itemPrefab, new GUIContent ("Item Prefab", "Item 的预制对象"));


			// count
			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("Count", "排列 [ 行数, 列数 ]"), GUILayout.Width (m_labelWidth));

			EditorGUI.BeginDisabledGroup (m_rowCountDisabled);
			int rowCount = EditorGUILayout.IntField ((int)m_baseList.rowCount, GUILayout.Width (m_halfWidth));
			m_baseList.rowCount = (rowCount < 1) ? 1 : (uint)rowCount;
			EditorGUI.EndDisabledGroup ();

			EditorGUI.BeginDisabledGroup (m_columnCountDisabled);
			int columnCount = EditorGUILayout.IntField ((int)m_baseList.columnCount, GUILayout.Width (m_halfWidth));
			m_baseList.columnCount = (columnCount < 1) ? 1 : (uint)columnCount;
			EditorGUI.EndDisabledGroup ();

			EditorGUILayout.EndHorizontal ();
			// EditorGUILayout.PropertyField (m_rowCount, new GUIContent ("Row", "行数"));
			// EditorGUILayout.PropertyField (m_columnCount, new GUIContent ("Column", "列数"));


			// gap
			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("Gap", "Item 间隔 [ 水平, 垂直 ]"), GUILayout.Width (m_labelWidth));
			m_baseList.horizontalGap = EditorGUILayout.IntField (m_baseList.horizontalGap, GUILayout.Width (m_halfWidth));
			m_baseList.verticalGap = EditorGUILayout.IntField (m_baseList.verticalGap, GUILayout.Width (m_halfWidth));
			EditorGUILayout.EndHorizontal ();
			// EditorGUILayout.PropertyField (m_horizontalGap, new GUIContent ("Horizontal Gap", "Item 水平间隔"));
			// EditorGUILayout.PropertyField (m_verticalGap, new GUIContent ("Vertical Gap", "Item 垂直间隔"));


			serializedObject.ApplyModifiedProperties ();
		}


		//
	}
}

