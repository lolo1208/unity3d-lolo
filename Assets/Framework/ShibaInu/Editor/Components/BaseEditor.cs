using System;
using UnityEditor;


namespace ShibaInu
{
	/// <summary>
	/// 组件在编辑器环境中的基类
	/// </summary>
	public class BaseEditor :Editor
	{
		/// 可显示的总宽度
		protected float m_viewWidth;
		/// 左侧 label 宽度
		protected float m_labelWidth;
		/// 除了 label 以外，剩余的内容宽度
		protected float m_width;
		/// 半个内容宽度
		protected float m_halfWidth;


		public override void OnInspectorGUI ()
		{
			m_viewWidth = EditorGUIUtility.currentViewWidth - 15;
			m_labelWidth = EditorGUIUtility.labelWidth - 4;
			m_width = m_viewWidth - m_labelWidth - 27;
			m_halfWidth = m_width / 2;
		}


		//
	}
}

