using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    [CustomEditor(typeof(BaseList))]
    public class BaseListEditor : BaseEditor
    {

        protected SerializedProperty m_itemPrefab;

        protected GUIContent m_c_itemPrefab = new GUIContent("Item Prefab", "Item 的预制对象");
        protected GUIContent m_c_count = new GUIContent("Count", "排列 [ 行数, 列数 ]");
        protected GUIContent m_c_gap = new GUIContent("Gap", "Item 间隔 [ 水平, 垂直 ]");

        protected bool m_rowCountDisabled = false;
        protected bool m_columnCountDisabled = false;

        protected BaseList m_baseList;



        protected virtual void OnEnable()
        {
            m_baseList = (BaseList)target;

            m_itemPrefab = serializedObject.FindProperty("m_itemPrefab");
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            // item prefab
            EditorGUILayout.PropertyField(m_itemPrefab, m_c_itemPrefab);


            // count
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_count, m_labelWidth);

            int rowCount = EditorGUILayout.IntField((int)m_baseList.rowCount, m_halfWidth);
            uint rowCountVal = (rowCount < 1) ? 1 : (uint)rowCount;
            MarkSceneDirty(rowCountVal != m_baseList.rowCount);
            m_baseList.rowCount = rowCountVal;

            int columnCount = EditorGUILayout.IntField((int)m_baseList.columnCount, m_halfWidth);
            uint columnCountVal = (columnCount < 1) ? 1 : (uint)columnCount;
            MarkSceneDirty(columnCountVal != m_baseList.columnCount);
            m_baseList.columnCount = columnCountVal;

            EditorGUILayout.EndHorizontal();


            // gap
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_gap, m_labelWidth);

            int hGap = EditorGUILayout.IntField(m_baseList.horizontalGap, m_halfWidth);
            MarkSceneDirty(hGap != m_baseList.horizontalGap);
            m_baseList.horizontalGap = hGap;

            int vGap = EditorGUILayout.IntField(m_baseList.verticalGap, m_halfWidth);
            MarkSceneDirty(vGap != m_baseList.verticalGap);
            m_baseList.verticalGap = vGap;

            EditorGUILayout.EndHorizontal();


            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

