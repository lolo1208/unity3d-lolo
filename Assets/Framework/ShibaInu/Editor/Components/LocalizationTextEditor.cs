using System;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
	[CustomEditor (typeof(LocalizationText))]
	public class LocalizationTextEditor : BaseEditor
	{
		private SerializedProperty m_languageKey;

		private GUIContent m_c_languageKey = new GUIContent ("Language Key", "内容在语言包中的 Key");
		private GUIContent m_c_apply = new GUIContent ("Apply", "验证 Key 有效性，并且立即在编辑器中显示内容");
		private GUIContent m_c_open = new GUIContent ("   Edit   ", "打开语言包编辑窗口");
		private GUIContent m_c_refresh = new GUIContent ("Refresh", "刷新语言包数据");
		private GUILayoutOption m_w50 = GUILayout.Width (50);

		private LocalizationText m_target;



		protected virtual void OnEnable ()
		{
			m_target = (LocalizationText)target;
			m_languageKey = serializedObject.FindProperty ("m_languageKey");

			if (LocalizationText.langeuage == null)
				LocalizationText.RefreshLanguage ();
		}



		public override void OnInspectorGUI ()
		{
			base.OnInspectorGUI ();


			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.PropertyField (m_languageKey, m_c_languageKey);
			serializedObject.ApplyModifiedProperties ();
//			m_target.languageKey = m_target.languageKey.Trim ();

			if (GUILayout.Button (m_c_apply, EditorStyles.miniButton, m_w50)) {
				m_target.DisplayContent ();
			}
			EditorGUILayout.EndHorizontal ();


			EditorGUILayout.BeginHorizontal ();
			EditorGUILayout.LabelField (new GUIContent ("langeuage: " + LocalizationText.langeuage, "当前使用的语言包"), m_labelWidth);

			if (GUILayout.Button (m_c_open, EditorStyles.miniButton)) {
				LanguageWindow.Open (m_target.languageKey.Trim ());
			}

			if (GUILayout.Button (m_c_refresh, EditorStyles.miniButton)) {
				LocalizationText.RefreshLanguage ();
				m_target.DisplayContent ();
			}
			EditorGUILayout.EndHorizontal ();

		}



		//
	}
}

