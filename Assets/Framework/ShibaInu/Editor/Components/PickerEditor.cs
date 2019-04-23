using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    [CustomEditor(typeof(Picker))]
    public class PickerEditor : BaseEditor
    {

        protected SerializedProperty m_hitArea;
        protected SerializedProperty m_itemPrefab;
        protected SerializedProperty m_itemOffsetCount;
        protected SerializedProperty m_itemAlphaOffset;
        protected SerializedProperty m_itemScaleOffset;
        protected SerializedProperty m_scrollRatio;

        protected GUIContent m_c_hitArea = new GUIContent("Hit Area", "拖动点击响应区域");
        protected GUIContent m_c_itemPrefab = new GUIContent("Item Prefab", "Item 的预制对象");
        protected GUIContent m_c_itemOffsetCount = new GUIContent("Item Offset Count", "上下（左右）每个方向最多显示 Item 数量");
        protected GUIContent m_c_itemAlphaOffset = new GUIContent("Item Alpha Offset", "Item 透明度偏移");
        protected GUIContent m_c_itemScaleOffset = new GUIContent("Item Scale Offset", "Item 缩放偏移");
        protected GUIContent m_c_options = new GUIContent("Options", "其他选项");
        protected GUIContent m_c_isVertical = new GUIContent("isVertical", "是否为垂直方向排列");
        protected GUIContent m_c_isBounces = new GUIContent("isBounces", "是否启用回弹效果");
        protected GUIContent m_c_scrollRatio = new GUIContent("Scroll Ratio", "拖拽结束后，继续滚动距离比例");

        protected Picker m_picker;



        protected virtual void OnEnable()
        {
            m_picker = (Picker)target;

            m_hitArea = serializedObject.FindProperty("m_hitArea");
            m_itemPrefab = serializedObject.FindProperty("m_itemPrefab");
            m_itemOffsetCount = serializedObject.FindProperty("m_itemOffsetCount");
            m_itemAlphaOffset = serializedObject.FindProperty("m_itemAlphaOffset");
            m_itemScaleOffset = serializedObject.FindProperty("m_itemScaleOffset");
            m_scrollRatio = serializedObject.FindProperty("m_scrollRatio");
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();


            // property field
            bool clean, changed = false;

            EditorGUILayout.PropertyField(m_hitArea, m_c_hitArea);
            serializedObject.ApplyModifiedProperties();

            EditorGUILayout.PropertyField(m_itemPrefab, m_c_itemPrefab);
            clean = serializedObject.ApplyModifiedProperties();

            EditorGUILayout.PropertyField(m_itemOffsetCount, m_c_itemOffsetCount);
            changed = changed || serializedObject.ApplyModifiedProperties();

            EditorGUILayout.PropertyField(m_itemAlphaOffset, m_c_itemAlphaOffset);
            changed = changed || serializedObject.ApplyModifiedProperties();

            EditorGUILayout.PropertyField(m_itemScaleOffset, m_c_itemScaleOffset);
            changed = changed || serializedObject.ApplyModifiedProperties();


            if (changed || clean)
            {
                m_picker.SerializedPropertyChanged(clean);
            }


            // isVertical and isBounces
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_options, m_labelWidth);
            bool isVertical = EditorGUILayout.ToggleLeft(m_c_isVertical, m_picker.isVertical, m_halfWidth);
            MarkSceneDirty(isVertical != m_picker.isVertical);
            m_picker.isVertical = isVertical;
            bool isBounces = EditorGUILayout.ToggleLeft(m_c_isBounces, m_picker.isBounces, m_halfWidth);
            MarkSceneDirty(isBounces != m_picker.isBounces);
            m_picker.isBounces = isBounces;
            EditorGUILayout.EndHorizontal();


            EditorGUILayout.PropertyField(m_scrollRatio, m_c_scrollRatio);
            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

