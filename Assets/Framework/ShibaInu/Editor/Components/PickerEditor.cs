using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
	[CustomEditor (typeof(Picker))]
	public class PickerEditor : BaseEditor
	{
		
		protected SerializedProperty m_hitArea;
		protected SerializedProperty m_itemPrefab;
		protected SerializedProperty m_itemOffsetCount;
		protected SerializedProperty m_itemAlphaOffset;
		protected SerializedProperty m_itemScaleOffset;

		private Picker m_picker;



		protected virtual void OnEnable ()
		{
			m_picker = (Picker)target;

			m_hitArea = serializedObject.FindProperty ("m_hitArea");
			m_itemPrefab = serializedObject.FindProperty ("m_itemPrefab");
			m_itemOffsetCount = serializedObject.FindProperty ("m_itemOffsetCount");
			m_itemAlphaOffset = serializedObject.FindProperty ("m_itemAlphaOffset");
			m_itemScaleOffset = serializedObject.FindProperty ("m_itemScaleOffset");
		}


		public override void OnInspectorGUI ()
		{
			base.OnInspectorGUI ();


			// property field
			bool clean = false, changed = false;

			EditorGUILayout.PropertyField (m_hitArea, new GUIContent ("Hit Area", "拖动点击响应区域"));
			serializedObject.ApplyModifiedProperties ();

			EditorGUILayout.PropertyField (m_itemPrefab, new GUIContent ("Item Prefab", "Item 的预制对象"));
			clean = serializedObject.ApplyModifiedProperties ();

			EditorGUILayout.PropertyField (m_itemOffsetCount, new GUIContent ("Item Offset Count", "上下（左右）每个方向最多显示 Item 数量"));
			changed = changed || serializedObject.ApplyModifiedProperties ();

			EditorGUILayout.PropertyField (m_itemAlphaOffset, new GUIContent ("Item Alpha Offset", "Item 透明度偏移"));
			changed = changed || serializedObject.ApplyModifiedProperties ();

			EditorGUILayout.PropertyField (m_itemScaleOffset, new GUIContent ("Item Scale Offset", "Item 缩放偏移"));
			changed = changed || serializedObject.ApplyModifiedProperties ();


			if (changed || clean) {
				m_picker.SerializedPropertyChanged (clean);
			}


			// item position offset
//			EditorGUILayout.BeginHorizontal ();
//			EditorGUILayout.LabelField (new GUIContent ("Item Position Offset", "Item 位置偏移 [ x, y ]"), GUILayout.Width (m_labelWidth));
//			float x = EditorGUILayout.FloatField (m_picker.itemPositionOffset.x, GUILayout.Width (m_halfWidth));
//			float y = EditorGUILayout.FloatField (m_picker.itemPositionOffset.y, GUILayout.Width (m_halfWidth));
//			m_picker.itemPositionOffset = new Vector2 (x, y);
//			EditorGUILayout.EndHorizontal ();


			// isVertical and isBounces
			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("Options", "其他选项"), GUILayout.Width (m_labelWidth));
			m_picker.isVertical = EditorGUILayout.ToggleLeft (new GUIContent ("isVertical", "是否为垂直方向排列"), m_picker.isVertical, GUILayout.Width (m_halfWidth));
			m_picker.isBounces = EditorGUILayout.ToggleLeft (new GUIContent ("isBounces", "是否启用回弹效果"), m_picker.isBounces, GUILayout.Width (m_halfWidth));
			EditorGUILayout.EndHorizontal ();


//			serializedObject.ApplyModifiedProperties ();
		}


		//
	}
}

