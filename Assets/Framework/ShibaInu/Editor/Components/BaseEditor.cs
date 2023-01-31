using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;

// 不要删除该行，2018 - 2020 的 PrefabStageUtility 类在该命名空间内
using UnityEditor.Experimental.SceneManagement;


namespace ShibaInu
{
    /// <summary>
    /// 组件在编辑器环境中的基类
    /// </summary>
    public class BaseEditor : Editor
    {

        /// 可显示的总宽度值
        protected float m_viewWidthValue;
        /// 左侧 label 宽度值
        protected float m_labelWidthValue;
        /// 除了 label 以外，剩余的内容宽度值
        protected float m_widthValue;
        /// 半个内容宽度值
        protected float m_halfWidthValue;
        /// 三分之一内容宽度值
        protected float m_thirdWidthValue;

        /// 左侧 label 宽度 (GUILayoutOption)
        protected GUILayoutOption m_labelWidth;
        /// 除了 label 以外，剩余的内容宽度 (GUILayoutOption)
        protected GUILayoutOption m_width;
        /// 半个内容宽度 (GUILayoutOption)
        protected GUILayoutOption m_halfWidth;
        /// 三分之一内容宽度 (GUILayoutOption)
        protected GUILayoutOption m_thirdWidth;



        public override void OnInspectorGUI()
        {
            m_viewWidthValue = EditorGUIUtility.currentViewWidth - 15;
            m_labelWidthValue = EditorGUIUtility.labelWidth - 4;
            m_widthValue = m_viewWidthValue - m_labelWidthValue - 27;
            m_halfWidthValue = m_widthValue / 2;
            m_thirdWidthValue = m_widthValue / 3;

            m_labelWidth = GUILayout.Width(m_labelWidthValue);
            m_width = GUILayout.Width(m_widthValue);
            m_halfWidth = GUILayout.Width(m_halfWidthValue);
            m_thirdWidth = GUILayout.Width(m_thirdWidthValue);
        }



        public static void MarkSceneDirty(bool isDirty = true)
        {
            if (!Application.isPlaying && isDirty)
            {
#if UNITY_2018_3_OR_NEWER
                var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
                if (prefabStage != null)
                {
                    EditorSceneManager.MarkSceneDirty(prefabStage.scene);
                    return;
                }
#endif
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            }
        }


        //
    }
}
