using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using UnityEngine.SceneManagement;
using USceneMgr = UnityEngine.SceneManagement.SceneManager;

using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// 本地化文本
    /// </summary>
    [AddComponentMenu("ShibaInu/Localization Text", 201)]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Text))]
    public class LocalizationText : MonoBehaviour
    {
        private static LuaFunction s_setCurrentLanguage;
        private static LuaFunction s_getCurrentLanguage;
        private static LuaFunction s_getLanguageValueByKey;
        private static readonly Dictionary<string, string> s_data = new Dictionary<string, string>();


        /// 当前语种地区代码
        [NoToLua]
        public static string CurrentLanguage { get { return s_currentLanguage; } }
        private static string s_currentLanguage;



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
        [NoToLua]
        public void DisplayContent()
        {
            m_languageKey = m_languageKey.Trim();
            if (m_languageKey == "")
                return;

            if (Application.isPlaying && m_text == null)
                return;

            if (s_currentLanguage == null)
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
                    Debug.LogError("语言包：" + s_currentLanguage + " 中不包含 key=" + m_languageKey + " 的数据");
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
                s_getLanguageValueByKey.BeginPCall();
                s_getLanguageValueByKey.Push(m_languageKey);
                s_getLanguageValueByKey.PCall();
                value = s_getLanguageValueByKey.CheckString();
                s_getLanguageValueByKey.EndPCall();
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
                Debug.LogError("语言包：" + s_currentLanguage + " 中不包含 key=" + m_languageKey + " 的数据");
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
        [NoToLua]
        public static void RefreshLanguage()
        {
#if UNITY_EDITOR
            // 非运行状态
            if (!Application.isPlaying)
            {

                // 获取当前使用的语种地区代码
                s_currentLanguage = GetCurrentLanguageFromLuaFile();
                if (s_currentLanguage == null)
                {
                    Debug.LogError("无法获取当前使用的语种地区代码！");
                    return;
                }

                // 解析当前语言包
                s_data.Clear();
                string path = "Assets/Lua/Data/Languages/" + s_currentLanguage + ".lua";
                using (StreamReader file = new StreamReader(path))
                {
                    string line;
                    while ((line = file.ReadLine()) != null)
                    {
                        line = line.Trim();
                        if (line.StartsWith("[\"", StringComparison.Ordinal))
                        {
                            string[] arr = Regex.Split(line, "] =");

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

                RefreshAllLocalizationText();
                return;
            }
#endif

            // 运行状态
            if (s_getCurrentLanguage == null)
            {
                s_setCurrentLanguage = Common.luaMgr.state.GetFunction("Config.SetCurrentLanguage");
                s_getCurrentLanguage = Common.luaMgr.state.GetFunction("Config.GetCurrentLanguage");
                s_getLanguageValueByKey = Common.luaMgr.state.GetFunction("Config.GetLanguageValueByKey");
            }
            s_getCurrentLanguage.BeginPCall();
            s_getCurrentLanguage.PCall();
            s_currentLanguage = s_getCurrentLanguage.CheckString();
            s_getCurrentLanguage.EndPCall();
            s_data.Clear();
        }


        /// <summary>
        /// 切换当前使用的语言包
        /// </summary>
        /// <param name="language">Tratget Language.</param>
        [NoToLua]
        public static void SwitchLanguage(string language)
        {
            if (language == s_currentLanguage) return;
            s_currentLanguage = language;

            s_setCurrentLanguage.BeginPCall();
            s_setCurrentLanguage.Push(language);
            s_setCurrentLanguage.PCall();
            s_getCurrentLanguage.EndPCall();

            s_data.Clear();
            RefreshAllLocalizationText();
        }


        /// <summary>
        /// 刷新所有场景内，以及 UICanvas 下的全部 LocalizationText 组件
        /// </summary>
        private static void RefreshAllLocalizationText()
        {
            List<LocalizationText> list = new List<LocalizationText>();
            for (int n = 0; n < USceneMgr.sceneCount; ++n)
            {
                Scene scene = USceneMgr.GetSceneAt(n);
                GameObject[] gameObjects = scene.GetRootGameObjects();
                foreach (GameObject go in gameObjects)
                    list.AddRange(go.GetComponentsInChildren<LocalizationText>(true));
            }

            if (Stage.uiCanvasTra != null)
                list.AddRange(Stage.uiCanvasTra.gameObject.GetComponentsInChildren<LocalizationText>(true));

            foreach (LocalizationText text in list)
                text.DisplayContent();
        }


#if UNITY_EDITOR
        /// <summary>
        /// 从 Config.lua 文件中获取当前语种地区代码
        /// </summary>
        /// <returns></returns>
        [NoToLua]
        public static string GetCurrentLanguageFromLuaFile()
        {
            string path = "Assets/Lua/Data/Config.lua";
            string language = null;
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
                            language = line.Substring(start + 1, end - start - 1);
                            break;
                        }
                    }
                }
            }
            return language;
        }
#endif



        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_currentLanguage = null;
            s_setCurrentLanguage = null;
            s_getCurrentLanguage = null;
            s_getLanguageValueByKey = null;
        }

        #endregion


        //
    }
}

