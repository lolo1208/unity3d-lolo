using System;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;


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

		/// 左侧 label 宽度 (GUILayoutOption)
		protected GUILayoutOption m_labelWidth;
		/// 除了 label 以外，剩余的内容宽度 (GUILayoutOption)
		protected GUILayoutOption m_width;
		/// 半个内容宽度 (GUILayoutOption)
		protected GUILayoutOption m_halfWidth;



		public override void OnInspectorGUI ()
		{
			m_viewWidthValue = EditorGUIUtility.currentViewWidth - 15;
			m_labelWidthValue = EditorGUIUtility.labelWidth - 4;
			m_widthValue = m_viewWidthValue - m_labelWidthValue - 27;
			m_halfWidthValue = m_widthValue / 2;

			m_labelWidth = GUILayout.Width (m_labelWidthValue);
			m_width = GUILayout.Width (m_widthValue);
			m_halfWidth = GUILayout.Width (m_halfWidthValue);
		}



		protected void MarkSceneDirty (bool isDirty = true)
		{
			if (!Application.isPlaying && isDirty)
				EditorSceneManager.MarkSceneDirty (EditorSceneManager.GetActiveScene ());
		}


		//
	}
}

