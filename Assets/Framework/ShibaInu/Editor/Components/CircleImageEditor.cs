using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.Linq;


namespace ShibaInu
{
    [CustomEditor(typeof(CircleImage))]
    public class CircleImageEditor : BaseEditor
    {

        protected SerializedProperty m_sourceImage;
        protected SerializedProperty m_fan;
        protected SerializedProperty m_ring;
        protected SerializedProperty m_sides;

        protected SerializedProperty m_Color;
        protected SerializedProperty m_Material;
        protected SerializedProperty m_RaycastTarget;

        protected GUIContent m_c_setNativeSize = new GUIContent("Set Native Size", "Sets the size to match the content.");



        protected virtual void OnEnable()
        {
            m_sourceImage = serializedObject.FindProperty("m_sourceImage");
            m_fan = serializedObject.FindProperty("m_fan");
            m_ring = serializedObject.FindProperty("m_ring");
            m_sides = serializedObject.FindProperty("m_sides");

            m_Color = serializedObject.FindProperty("m_Color");
            m_Material = serializedObject.FindProperty("m_Material");
            m_RaycastTarget = serializedObject.FindProperty("m_RaycastTarget");
        }



        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();


            // Image Editor Styles
            EditorGUILayout.PropertyField(m_sourceImage);

            EditorGUILayout.PropertyField(m_Color);
            EditorGUILayout.PropertyField(m_Material);
            EditorGUILayout.PropertyField(m_RaycastTarget);


            // Set Native Size Button
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(m_labelWidthValue);
            if (GUILayout.Button(m_c_setNativeSize, EditorStyles.miniButton))
            {
                foreach (Graphic current in from obj in base.targets
                                            select obj as Graphic)
                {
                    Undo.RecordObject(current.rectTransform, "Set Native Size");
                    current.SetNativeSize();
                    EditorUtility.SetDirty(current);
                }
            }
            EditorGUILayout.EndHorizontal();


            // Circle Image Editor Styles
            EditorGUILayout.PropertyField(m_fan);
            EditorGUILayout.PropertyField(m_ring);
            EditorGUILayout.PropertyField(m_sides);


            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

