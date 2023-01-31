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
        protected GUIContent m_c_autoCount = new GUIContent("Auto", "是否根据显示区域自动调整 item 数量");
        protected GUIContent m_c_autoGap = new GUIContent("Auto", "是否根据显示区域自动调整 item 间隔");
        protected GUIContent m_c_isAutoSize = new GUIContent("Auto Size", "是否根据当前节点尺寸，自动设置显示区域尺寸和 item 偏移位置");

        protected BaseList m_baseList;



        protected virtual void OnEnable()
        {
            m_baseList = (BaseList)target;

            m_itemPrefab = serializedObject.FindProperty("m_itemPrefab");

            if (!EditorApplication.isPlaying && m_baseList.CreateElements())
                MarkSceneDirty();
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            // item prefab
            EditorGUILayout.PropertyField(m_itemPrefab, m_c_itemPrefab);


            // count
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_count, m_labelWidth);

            EditorGUI.BeginDisabledGroup(!RowCountEnabled);
            int rowCount = EditorGUILayout.IntField((int)m_baseList.rowCount, m_thirdWidth);
            uint rowCountVal = (rowCount < 1) ? 1 : (uint)rowCount;
            MarkSceneDirty(rowCountVal != m_baseList.rowCount);
            m_baseList.rowCount = rowCountVal;
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!ColumnCountEnabled);
            int columnCount = EditorGUILayout.IntField((int)m_baseList.columnCount, m_thirdWidth);
            uint columnCountVal = (columnCount < 1) ? 1 : (uint)columnCount;
            MarkSceneDirty(columnCountVal != m_baseList.columnCount);
            m_baseList.columnCount = columnCountVal;
            EditorGUI.EndDisabledGroup();

            //EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);
            EditorGUI.BeginDisabledGroup(!AutoItemCountEnabled);
            bool isAutoItemCount = GUILayout.Toggle(m_baseList.isAutoItemCount, m_c_autoCount);
            MarkSceneDirty(isAutoItemCount != m_baseList.isAutoItemCount);
            m_baseList.isAutoItemCount = isAutoItemCount;
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.EndHorizontal();
            //EditorGUI.EndDisabledGroup();


            // gap
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(m_c_gap, m_labelWidth);

            EditorGUI.BeginDisabledGroup(!HGapEnabled);
            int hGap = EditorGUILayout.IntField(m_baseList.horizontalGap, m_thirdWidth);
            MarkSceneDirty(hGap != m_baseList.horizontalGap);
            m_baseList.horizontalGap = hGap;
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!VGapEnabled);
            int vGap = EditorGUILayout.IntField(m_baseList.verticalGap, m_thirdWidth);
            MarkSceneDirty(vGap != m_baseList.verticalGap);
            m_baseList.verticalGap = vGap;
            EditorGUI.EndDisabledGroup();

            //EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);
            EditorGUI.BeginDisabledGroup(!AutoItemGapEnabled);
            bool isAutoItemGap = GUILayout.Toggle(m_baseList.isAutoItemGap, m_c_autoGap);
            MarkSceneDirty(isAutoItemGap != m_baseList.isAutoItemGap);
            m_baseList.isAutoItemGap = isAutoItemGap;
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.EndHorizontal();
            //EditorGUI.EndDisabledGroup();


            // auto size
            //EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);
            EditorGUILayout.BeginHorizontal();
            EditorGUI.BeginDisabledGroup(!AutoSizeEnabled);
            GUILayout.Space(EditorGUIUtility.labelWidth);
            bool isAutoSize = GUILayout.Toggle(m_baseList.isAutoSize, m_c_isAutoSize);
            MarkSceneDirty(isAutoSize != m_baseList.isAutoSize);
            m_baseList.isAutoSize = isAutoSize;
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.EndHorizontal();
            //EditorGUI.EndDisabledGroup();


            serializedObject.ApplyModifiedProperties();
        }



        public virtual bool RowCountEnabled
        {
            get { return !m_baseList.isAutoItemCount; }
        }

        public virtual bool ColumnCountEnabled
        {
            get { return !m_baseList.isAutoItemCount; }
        }


        public virtual bool HGapEnabled
        {
            get { return !m_baseList.isAutoItemGap; }
        }

        public virtual bool VGapEnabled
        {
            get { return !m_baseList.isAutoItemGap; }
        }

        public virtual bool AutoItemCountEnabled
        {
            get { return true; }
        }

        public virtual bool AutoItemGapEnabled
        {
            get { return true; }
        }

        public virtual bool AutoSizeEnabled
        {
            get { return true; }
        }

        //
    }
}

