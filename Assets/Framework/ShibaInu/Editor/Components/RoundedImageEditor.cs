using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Linq;


namespace ShibaInu
{
    [CustomEditor(typeof(RoundedImage))]
    public class RoundedImageEditor : BaseEditor
    {
        protected SerializedProperty m_sourceImage;
        protected SerializedProperty m_isIndependent;
        protected SerializedProperty m_radius;
        protected SerializedProperty m_radiuses;

        protected SerializedProperty m_Color;
        protected SerializedProperty m_RaycastTarget;

        protected RoundedImage m_target;

        protected GUIContent m_c_setNativeSize = new GUIContent("Set Native Size", "Sets the size to match the content.");
        protected GUIContent m_c_isIndependent = new GUIContent("Is Independent", "是否单独设置四个角的半径");



        protected virtual void OnEnable()
        {
            m_target = (RoundedImage)target;

            m_sourceImage = serializedObject.FindProperty("m_sourceImage");
            m_isIndependent = serializedObject.FindProperty("m_isIndependent");
            m_radius = serializedObject.FindProperty("m_radius");
            m_radiuses = serializedObject.FindProperty("m_radiuses");

            m_Color = serializedObject.FindProperty("m_Color");
            m_RaycastTarget = serializedObject.FindProperty("m_RaycastTarget");
        }



        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            EditorGUILayout.PropertyField(m_sourceImage);

            // Set Native Size Button
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(m_labelWidthValue);
            if (GUILayout.Button(m_c_setNativeSize, EditorStyles.miniButton))
            {
                foreach (Graphic current in from obj in targets
                                            select obj as Graphic)
                {
                    Undo.RecordObject(current.rectTransform, "Set Native Size");
                    current.SetNativeSize();
                    EditorUtility.SetDirty(current);
                }
            }
            EditorGUILayout.EndHorizontal();

            bool isIndependent = GUILayout.Toggle(m_target.isIndependent, m_c_isIndependent);
            MarkSceneDirty(isIndependent != m_target.isIndependent);
            m_target.isIndependent = isIndependent;

            EditorGUI.BeginDisabledGroup(isIndependent);
            EditorGUILayout.PropertyField(m_radius);
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!isIndependent);
            EditorGUILayout.PropertyField(m_radiuses);
            EditorGUI.EndDisabledGroup();

            EditorGUILayout.PropertyField(m_Color);
            EditorGUILayout.PropertyField(m_RaycastTarget);

            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

