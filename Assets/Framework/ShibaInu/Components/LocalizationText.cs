using System;
using System.IO;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using UnityEngine.SceneManagement;

using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 本地化文本
    /// </summary>
    [AddComponentMenu("ShibaInu/Localization Text", 107)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Text))]
    public class LocalizationText : MonoBehaviour
    {
        /// 当前语种地区代码
        public static string langeuage;

        private static readonly Dictionary<string, string> s_data = new Dictionary<string, string>();
        private static LuaFunction s_getCurrentLanguage;
        private static LuaFunction s_getLanguageByKey;

        private Text m_text;



        /// 语言包 ID
        public string languageKey
        {
            set
            {
                if (value != m_languageKey)
                {
                    m_languageKey = value;
                    DisplayContent();
                }
            }
            get { return m_languageKey; }
        }

        [FormerlySerializedAs("languageKey"), SerializeField]
        protected string m_languageKey = "";



        void Start()
        {
#if UNITY_EDITOR
            if (!Common.Initialized)
                return;
#endif
            m_text = GetComponent<Text>();
            DisplayContent();
        }


        /// <summary>
        /// 显示当前 key 对应的内容
        /// </summary>
        public void DisplayContent()
        {
            m_languageKey = m_languageKey.Trim();
            if (m_languageKey == "")
                return;

            if (langeuage == null)
                RefreshLanguage();
            string value = null;


            // 非运行状态
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                if (s_data.ContainsKey(m_languageKey))
                {
                    s_data.TryGetValue(m_languageKey, out value);
                    GetComponent<Text>().text = value.Replace("\\n", "\n");
                }
                else
                {
                    Debug.LogError("语言包：" + langeuage + " 中不包含 key=" + m_languageKey + " 的数据");
                }
                return;
            }
#endif


            // 运行状态
            if (s_data.ContainsKey(m_languageKey))
            {
                s_data.TryGetValue(m_languageKey, out value);
            }
            else
            {
                s_getLanguageByKey.BeginPCall();
                s_getLanguageByKey.Push(m_languageKey);
                s_getLanguageByKey.PCall();
                value = s_getLanguageByKey.CheckString();
                s_getLanguageByKey.EndPCall();
                if (value != null)
                {
                    s_data.Add(m_languageKey, value);
                }
            }
            if (value != null)
            {
                m_text.text = value;
            }
            else
            {
                Debug.LogError("语言包：" + langeuage + " 中不包含 key=" + m_languageKey + " 的数据");
            }
        }


        /// <summary>
        /// 设置文本内容，并将 languageKey 置空
        /// </summary>
        /// <param name="text">Text.</param>
        public void SetText(string text)
        {
            languageKey = "";
            m_text.text = text;
        }




        /// <summary>
        /// 更新语言包数据
        /// </summary>
        public static void RefreshLanguage()
        {
            // 非运行状态
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {

                // 获取当前使用的语种地区代码
                langeuage = null;
                string path = "Assets/Lua/Data/Config.lua";
                if (File.Exists(path))
                {
                    using (StreamReader file = new StreamReader(path))
                    {
                        string line;
                        while ((line = file.ReadLine()) != null)
                        {
                            line = line.Trim();
                            if (line.StartsWith("Config.language", StringComparison.Ordinal))
                            {
                                int start = line.IndexOf('"');
                                int end = line.LastIndexOf('"');
                                langeuage = line.Substring(start + 1, end - start - 1);
                            }
                        }
                    }
                }
                if (langeuage == null)
                {
                    Debug.LogError("无法获取当前使用的语种地区代码！");
                    return;
                }

                // 解析当前语言包
                s_data.Clear();
                path = "Assets/Lua/Data/Languages/" + langeuage + ".lua";
                using (StreamReader file = new StreamReader(path))
                {
                    string line;
                    while ((line = file.ReadLine()) != null)
                    {
                        line = line.Trim();
                        if (line.StartsWith("[\"", StringComparison.Ordinal))
                        {
                            string[] arr = line.Split('=');

                            string key = arr[0];
                            int start = key.IndexOf('"');
                            int end = key.LastIndexOf('"');
                            key = key.Substring(start + 1, end - start - 1);

                            string value = arr[1];
                            start = value.IndexOf('"');
                            end = value.LastIndexOf('"');
                            value = value.Substring(start + 1, end - start - 1);

                            s_data.Add(key, value);
                        }
                    }
                }

                // 更新场景中所有的 LocalizationText
                List<LocalizationText> list = new List<LocalizationText>();
                Scene scene = SceneManager.GetActiveScene();
                foreach (GameObject go in scene.GetRootGameObjects())
                {
                    list.AddRange(go.GetComponentsInChildren<LocalizationText>(true));
                }
                foreach (LocalizationText text in list)
                {
                    text.DisplayContent();
                }

                return;
            }
#endif


            // 运行状态
            if (s_getCurrentLanguage == null)
            {
                s_getCurrentLanguage = Common.luaMgr.state.GetFunction("Config._GetCurrentLanguage");
                s_getLanguageByKey = Common.luaMgr.state.GetFunction("Config._GetLanguageByKey");
            }
            s_getCurrentLanguage.BeginPCall();
            s_getCurrentLanguage.PCall();
            langeuage = s_getCurrentLanguage.CheckString();
            s_getCurrentLanguage.EndPCall();

            s_data.Clear();
        }



        #region 清空所有引用（在动更结束后重启 app 时）

        public static void ClearReference()
        {
            langeuage = null;
            s_getCurrentLanguage = null;
            s_getLanguageByKey = null;
        }

        #endregion


        //
    }
}

