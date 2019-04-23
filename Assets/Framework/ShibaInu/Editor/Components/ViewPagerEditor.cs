using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    [CustomEditor(typeof(ViewPager))]
    public class ViewPagerEditor : BaseEditor
    {

        protected SerializedProperty m_maxDragScale;
        protected SerializedProperty m_scrollDuration;
        protected SerializedProperty m_viewSize;
        protected SerializedProperty m_isVertical;

        protected GUIContent m_c_viewCount = new GUIContent("View Count", "视图总数量");
        protected GUIContent m_c_viewsVisible = new GUIContent("Views", "视图列表");
        protected GUIContent m_c_currentViewIndex = new GUIContent("View Index", "当前（默认）选中视图索引");
        protected GUIContent m_c_transformerType = new GUIContent("Transformer", "ViewPager 页面转换效果");

        protected ViewPager m_viewPager;
        protected bool m_viewsVisible = true;

        protected bool m_viewInfoVisible = true;



        protected virtual void OnEnable()
        {
            m_viewPager = (ViewPager)target;
            m_maxDragScale = serializedObject.FindProperty("m_maxDragScale");
            m_scrollDuration = serializedObject.FindProperty("m_scrollDuration");
            m_viewSize = serializedObject.FindProperty("m_viewSize");
            m_isVertical = serializedObject.FindProperty("m_isVertical");
        }


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();


            // propertys
            EditorGUILayout.PropertyField(m_maxDragScale);
            EditorGUILayout.PropertyField(m_scrollDuration);
            EditorGUILayout.PropertyField(m_viewSize);
            EditorGUILayout.PropertyField(m_isVertical);


            PageTransformerType ptt = (PageTransformerType)EditorGUILayout.EnumPopup(m_c_transformerType, m_viewPager.transformerType);
            if (ptt != m_viewPager.transformerType)
            {
                m_viewPager.transformerType = ptt;
                MarkSceneDirty();
            }


            List<GameObject> views = m_viewPager.views;
            List<GameObject> cache = m_viewPager.viewsCache;


            if (m_viewInfoVisible)
            {

                // view index
                int viewCount = views.Count;
                int curIdx = EditorGUILayout.IntField(m_c_currentViewIndex, m_viewPager.currentViewIndex);
                if (curIdx < 0)
                    curIdx = 0;
                else if (curIdx >= viewCount)
                    curIdx = viewCount - 1;
                MarkSceneDirty(curIdx != m_viewPager.currentViewIndex);
                m_viewPager.currentViewIndex = curIdx;


                // view count
                viewCount = EditorGUILayout.IntField(m_c_viewCount, viewCount);
                MarkSceneDirty(viewCount != m_viewPager.viewCount);
                m_viewPager.viewCount = viewCount;


                // add cache
                if (!Application.isPlaying)
                {
                    int num = viewCount - cache.Count;
                    for (int i = 0; i < num; i++)
                        cache.Add(null);
                }


                // views
                m_viewsVisible = EditorGUILayout.Foldout(m_viewsVisible, m_c_viewsVisible);
                if (m_viewsVisible && viewCount > 0)
                {
                    GUILayout.BeginVertical("HelpBox");
                    for (int i = 0; i < viewCount; i++)
                    {
                        GameObject view = views[i];
                        if (!Application.isPlaying && view == null)
                            view = cache[i];
                        GameObject newView = (GameObject)EditorGUILayout.ObjectField("\t" + i, view, typeof(GameObject), true);
                        MarkSceneDirty(newView != view);
                        views[i] = newView;
                        if (!Application.isPlaying)
                            cache[i] = newView;
                    }
                    GUILayout.EndVertical();
                }

            }


            serializedObject.ApplyModifiedProperties();
        }


        //
    }
}

