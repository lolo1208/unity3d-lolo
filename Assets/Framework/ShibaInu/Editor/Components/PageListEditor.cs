using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    [CustomEditor(typeof(PageList))]
    public class PageListEditor : ViewPagerEditor
    {

        protected SerializedProperty m_itemPrefab;

        protected GUIContent m_c_itemPrefab = new GUIContent("Item Prefab", "Item 的预制对象");
        protected GUIContent m_c_count = new GUIContent("Count", "排列 [ 行数, 列数 ]");
        protected GUIContent m_c_gap = new GUIContent("Gap", "Item 间隔 [ 水平, 垂直 ]");

        protected PageList m_pageList;



        public PageListEditor()
        {
            m_viewInfoVisible = false;
        }


        protected override void OnEnable()
        {
            base.OnEnable();

            m_pageList = (PageList)target;
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

            int rowCount = EditorGUILayout.IntField((int)m_pageList.rowCount, m_halfWidth);
            uint rowCountVal = (rowCount < 1) ? 1 : (uint)rowCount;
            MarkSceneDirty(rowCountVal != m_pageList.rowCount);
            m_pageList.rowCount = rowCountVal;

            int columnCount = EditorGUILayout.IntField((int)m_pageList.columnCount, m_halfWidth);
            uint columnCountVal = (columnCount < 1) ? 1 : (uint)columnCount;
            MarkSceneDirty(columnCountVal != m_pageList.columnCount);
            m_pageList.columnCount = columnCountVal;

            EditorGUILayout.EndHorizontal();


            // gap
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_gap, m_labelWidth);

            int hGap = EditorGUILayout.IntField(m_pageList.horizontalGap, m_halfWidth);
            MarkSceneDirty(hGap != m_pageList.horizontalGap);
            m_pageList.horizontalGap = hGap;

            int vGap = EditorGUILayout.IntField(m_pageList.verticalGap, m_halfWidth);
            MarkSceneDirty(vGap != m_pageList.verticalGap);
            m_pageList.verticalGap = vGap;

            EditorGUILayout.EndHorizontal();


            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

