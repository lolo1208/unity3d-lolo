using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;

using UnityEngine;

using UnityEditor;


namespace ShibaInu
{
    /// <summary>
    /// 语言包管理窗口
    /// </summary>
    public class LanguageWindow : EditorWindow
    {
        private static readonly Vector2 MAX_SIZE = new Vector2(800, 625);
        private static readonly Vector2 MIN_SIZE = new Vector2(600, 625);

        private const int PAGE_SIZE = 19;

        private string m_language = string.Empty;
        private string[] m_languages;
        private int m_languageIdx = -1;
        private readonly List<LanguageItem> m_data = new List<LanguageItem>();
        private readonly List<LanguageItem> m_result = new List<LanguageItem>();
        private int m_curPage = 1;

        private LanguageWindowState m_state = LanguageWindowState.Normal;
        private LanguageWindowState m_lastState = LanguageWindowState.Normal;
        private string m_oKey = "";
        private string m_oValue = "";
        private string m_key = "";
        private string m_value = "";
        private string m_query = "";
        private string m_selectedKey;
        private int m_selectCount;

        private GUILayoutOption m_initialized;
        private GUILayoutOption m_w30;
        private GUILayoutOption m_w50;
        private GUILayoutOption m_w60;
        private GUILayoutOption m_w70;
        private GUILayoutOption m_w90;
        private GUILayoutOption m_w100;
        private GUILayoutOption m_w120;
        private GUILayoutOption m_w400;
        private GUILayoutOption m_h22;
        private GUILayoutOption m_h28;
        private GUILayoutOption m_h150;
        private GUIStyle m_bg1;
        private GUIStyle m_bg2;
        private GUIStyle m_bg3;
        private Color m_color1;
        private Color m_color2;



        public static void Open()
        {
            Open(null);
        }


        public static void Open(string selelctKey)
        {
            LanguageWindow wnd = GetWindow<LanguageWindow>(true, "语言包管理");
            wnd.maxSize = MAX_SIZE;
            wnd.minSize = MIN_SIZE;

            if (selelctKey != null)
                wnd.SelectByKey(selelctKey);
        }



        private void Initialize()
        {
            if (m_initialized != null) return;
            m_initialized = GUILayout.Width(0);

            // 获取当前使用的语种地区代码
            m_language = LocalizationText.GetCurrentLanguageFromLuaFile();

            // 获取语言包列表
            string path = "Assets/Lua/Data/Languages/";
            if (!Directory.Exists(path))
                return;
            List<string> list = new List<string>();
            string[] files = Directory.GetFiles(path);
            foreach (string filePath in files)
            {
                if (filePath.EndsWith(".lua", StringComparison.Ordinal))
                {
                    int start = filePath.LastIndexOf("/", StringComparison.Ordinal) + 1;
                    int end = filePath.Length - start - 4;
                    list.Add(filePath.Substring(start, end));
                }
            }
            m_languages = list.ToArray();


            // 找出当前语言包对应的 index
            for (int i = 0; i < m_languages.Length; i++)
            {
                if (m_languages[i] == m_language)
                {
                    m_languageIdx = i;
                    break;
                }
            }
            if (m_languageIdx == -1)
                return;


            // 解析语言包数据列表
            ParseLanguage();

            m_w30 = GUILayout.Width(30);
            m_w50 = GUILayout.Width(50);
            m_w60 = GUILayout.Width(60);
            m_w70 = GUILayout.Width(70);
            m_w90 = GUILayout.Width(90);
            m_w100 = GUILayout.Width(100);
            m_w120 = GUILayout.Width(120);
            m_w400 = GUILayout.Width(400);

            m_h22 = GUILayout.Height(22);
            m_h28 = GUILayout.Height(28);
            m_h150 = GUILayout.Height(150);

            m_color1 = new Color(0.7f, 0.7f, 0.7f);
            m_color2 = Color.white;
        }


        void OnFocus()
        {
            m_bg1 = new GUIStyle();
            m_bg1.normal.background = new Texture2D(1, 1);
            m_bg1.normal.background.SetPixel(0, 0, new Color(0.23f, 0.23f, 0.23f));
            m_bg1.normal.background.Apply();

            m_bg2 = new GUIStyle();
            m_bg2.normal.background = new Texture2D(1, 1);
            m_bg2.normal.background.SetPixel(0, 0, new Color(0.21f, 0.21f, 0.21f));
            m_bg2.normal.background.Apply();

            m_bg3 = new GUIStyle();
            m_bg3.normal.background = new Texture2D(1, 1);
            m_bg3.normal.background.SetPixel(0, 0, new Color(0.4f, 0.4f, 0.4f));
            m_bg3.normal.background.Apply();
        }


        void OnGUI()
        {
            Initialize();

            if (m_language == string.Empty)
            {
                ShowErrorMessage("无法获取当前使用的语种地区代码！\n请检查：Assets/Lua/Data/Config.lua 文件，是否包含 Config.language 变量！");
                return;
            }

            if (m_languages.Length == 0)
            {
                ShowErrorMessage("目录：Assets/Lua/Data/Languages 中不包含任何语言包文件！");
                return;
            }

            if (m_languageIdx == -1)
            {
                ShowErrorMessage("目录：Assets/Lua/Data/Languages 中不包含 Config.language 指定的语言包文件！");
                return;
            }

            if (m_state == LanguageWindowState.Edit || m_state == LanguageWindowState.Append)
            {
                EditOrAppend();
                return;
            }


            TextAnchor textFieldAlignment = GUI.skin.textField.alignment;
            float wndWidth = this.position.width;
            GUILayout.Space(13);


            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("使用语言包：", m_w70);
            int languageIdx = m_languageIdx;
            m_languageIdx = EditorGUILayout.Popup(m_languageIdx, m_languages, m_w90);
            if (m_languageIdx != languageIdx)
            {
                ParseLanguage();
                if (languageIdx != -1)
                    ChangeLocalization();
            }

            GUILayout.Space(70);
            GUI.skin.textField.alignment = TextAnchor.UpperLeft;
            m_query = EditorGUILayout.TextField(m_query, m_w120);
            GUI.skin.textField.alignment = textFieldAlignment;

            GUILayout.BeginVertical(m_w60);
            bool isClearQuery = m_state == LanguageWindowState.Query && m_query.Trim() == "";
            if (GUILayout.Button(isClearQuery ? "显示全部" : "查询"))
            {
                if (isClearQuery)
                {
                    ChangeState(LanguageWindowState.Normal);
                }
                else
                {
                    m_result.Clear();
                    m_curPage = 1;
                    string query = m_query.ToLower();
                    foreach (var item in m_data)
                    {
                        if (item.key_lower.Contains(query) || item.value_lower.Contains(query))
                            m_result.Add(item);
                    }
                    ChangeState(LanguageWindowState.Query);
                }
            }
            GUILayout.EndVertical();


            GUILayout.Space(wndWidth - 508);
            GUILayout.BeginVertical(m_w60);
            if (GUILayout.Button("+ 新增"))
            {
                m_oKey = m_oValue = m_key = m_value = "";
                ChangeState(LanguageWindowState.Append);
            }
            GUILayout.EndVertical();


            // list
            GUILayout.EndHorizontal();
            GUILayout.Space(12);
            GUILayoutOption keyW = GUILayout.Width((wndWidth - 110) * 0.35f);
            GUILayoutOption valueW = GUILayout.Width((wndWidth - 110) * 0.65f);

            Color labelColor = GUI.skin.label.normal.textColor;
            List<LanguageItem> list = m_state == LanguageWindowState.Query ? m_result : m_data;
            int startIndex = (m_curPage - 1) * PAGE_SIZE;
            for (int i = 0; i < PAGE_SIZE; i++)
            {
                int index = startIndex + i;
                LanguageItem item = (index < list.Count) ? list[index] : null;

                GUIStyle bg;
                if (item != null && item.key == m_selectedKey && m_selectCount > 0)
                {
                    m_selectCount--;
                    bg = m_bg3;
                    GUI.skin.label.normal.textColor = m_color2;
                }
                else
                {
                    bg = (i % 2 == 0) ? m_bg1 : m_bg2;
                    GUI.skin.label.normal.textColor = m_color1;
                }
                GUILayout.BeginHorizontal(bg, m_h28);
                GUILayout.Space(10);

                if (item != null)
                {
                    GUILayout.BeginVertical();
                    GUILayout.Space(6);
                    if (GUILayout.Button(item.key, GUI.skin.label, keyW))
                    {
                        m_selectedKey = item.key;
                        m_selectCount = 10;
                        GUIUtility.systemCopyBuffer = item.key;
                    }
                    GUILayout.EndVertical();

                    GUILayout.Space(10);
                    GUILayout.BeginVertical();
                    GUILayout.Space(6);
                    GUILayout.Label(item.value, valueW);
                    GUILayout.EndVertical();
                    GUILayout.Space(10);

                    GUILayout.BeginVertical();
                    GUILayout.Space(5);
                    if (GUILayout.Button("编辑", m_w60))
                    {
                        m_oKey = m_key = item.key;
                        m_oValue = item.value;
                        m_value = item.value.Replace("\\n", "\n");
                        ChangeState(LanguageWindowState.Edit);
                    }
                    GUILayout.EndVertical();
                }
                GUILayout.Space(10);
                GUILayout.EndHorizontal();
            }
            GUI.skin.label.normal.textColor = labelColor;


            // page
            GUILayout.Space(13);
            GUILayout.BeginHorizontal();
            GUILayout.Space(wndWidth / 2 - 100);

            EditorGUI.BeginDisabledGroup(m_curPage <= 1);
            GUILayout.BeginVertical(m_w60);
            if (GUILayout.Button("上一页"))
            {
                m_curPage--;
            }
            GUILayout.EndVertical();
            EditorGUI.EndDisabledGroup();

            GUILayout.Space(3);
            int pageNum = GetPageNum();
            GUI.skin.textField.alignment = TextAnchor.MiddleCenter;
            m_curPage = EditorGUILayout.IntField(m_curPage, m_w50);
            m_curPage = Mathf.Min(Mathf.Max(1, m_curPage), pageNum);
            GUI.skin.textField.alignment = textFieldAlignment;

            GUILayout.Label("/" + pageNum, m_w30);

            EditorGUI.BeginDisabledGroup(m_curPage >= pageNum);
            GUILayout.BeginVertical(m_w60);
            if (GUILayout.Button("下一页"))
            {
                m_curPage++;
            }
            GUILayout.EndVertical();
            EditorGUI.EndDisabledGroup();

            GUILayout.EndHorizontal();
        }


        /// <summary>
        /// 编辑内容或新增内容
        /// </summary>
        private void EditOrAppend()
        {
            TextAnchor labelAlignment = GUI.skin.label.alignment;
            bool isAppend = m_state == LanguageWindowState.Append;

            GUILayout.Space(30);
            GUILayout.BeginHorizontal();
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("语言包：", m_w100);
            GUI.skin.label.alignment = TextAnchor.MiddleLeft;
            GUILayout.Label(m_language);
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("原 Key：", m_w100);
            GUI.skin.label.alignment = TextAnchor.MiddleLeft;
            GUILayout.Label(isAppend ? "新增一条数据" : m_oKey);
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("Key：", m_w100);
            m_key = EditorGUILayout.TextField(m_key, m_w400);
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUILayout.Label("Value：", m_w100);
            GUI.skin.label.alignment = labelAlignment;
            m_value = EditorGUILayout.TextArea(m_value, m_w400, m_h150);
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUILayout.Space(105);
            if (GUILayout.Button("取消", m_w60))
                ChangeState(m_lastState);


            GUILayout.Space(10);
            EditorGUI.BeginDisabledGroup(isAppend);
            GUILayout.BeginVertical();
            GUILayout.Space(0);
            Color buttonTextColor = GUI.skin.button.normal.textColor;
            GUI.skin.button.normal.textColor = Color.red;
            if (GUILayout.Button("- 删除", m_w60, m_h22))
            {
                if (EditorUtility.DisplayDialog("请确认",
                        "您确定要从语言包: " + m_language + " 中删除这条数据吗？\n\n   Key: " + m_oKey + "\n\nValue: " + m_oValue,
                        "确定", "取消"))
                {
                    ChangeState(m_lastState);
                    RemoveByKey(m_oKey);
                    SaveLanguage();
                }
            }
            GUI.skin.button.normal.textColor = buttonTextColor;
            GUILayout.EndVertical();
            EditorGUI.EndDisabledGroup();


            GUILayout.Space(115);
            GUILayout.BeginVertical();
            GUILayout.Space(0);
            if (GUILayout.Button(isAppend ? "+ 添加" : "* 修改", m_w60, m_h22))
            {
                string key = m_key.Trim();
                string value = m_value.Replace("\n", "\\n").Replace("\r", "");
                if (key != "" && value.Trim() != "")
                {
                    bool isContainsKey = ContainsKey(m_key);
                    if (isAppend)
                    {
                        if (isContainsKey)
                        {
                            EditorUtility.DisplayDialog("提示", "语言包: " + m_language + " 中已包含 Key: " + m_key, "确定");
                        }
                        else
                        {
                            ChangeState(LanguageWindowState.Normal);
                            m_data.Add(new LanguageItem(m_key, value));
                            SaveLanguage();
                            SelectByKey(m_key);
                        }

                    }
                    else
                    {
                        if (m_key != m_oKey && isContainsKey)
                        {
                            EditorUtility.DisplayDialog("提示", "语言包: " + m_language + " 中已包含 Key: " + m_key, "确定");
                        }
                        else
                        {
                            if (m_key != m_oKey)
                            {
                                if (EditorUtility.DisplayDialog("提示", "您确定将 Key: " + m_oKey + " 修改为: " + m_key + " 吗？", "确定", "取消"))
                                {
                                    ChangeState(m_lastState);
                                    ChangeItem(m_key, value, m_oKey);
                                    SaveLanguage();
                                    SelectByKey(m_key);
                                }
                            }
                            else
                            {
                                ChangeState(m_lastState);
                                if (value != m_oValue)
                                {
                                    ChangeItem(m_key, value);
                                    SaveLanguage();
                                    SelectByKey(m_key);
                                }
                            }
                        }
                    }
                    //
                }
            }
            GUILayout.EndVertical();
        }


        /// <summary>
        /// 显示错误消息提示
        /// </summary>
        /// <param name="msg">Message.</param>
        private void ShowErrorMessage(string msg)
        {
            GUILayout.Space(30);
            GUILayout.BeginHorizontal();
            GUILayout.Space(20);
            GUILayout.Label(msg);
            GUILayout.Space(20);
            GUILayout.EndHorizontal();
        }


        /// <summary>
        /// 改变窗口显示状态
        /// </summary>
        /// <param name="state">State.</param>
        private void ChangeState(LanguageWindowState state)
        {
            m_lastState = m_state;
            m_state = state;
            GUI.FocusControl(null);
        }


        /// <summary>
        /// 获取总页数
        /// </summary>
        private int GetPageNum()
        {
            List<LanguageItem> list = m_state == LanguageWindowState.Query ? m_result : m_data;
            return Mathf.Max(Mathf.CeilToInt((float)list.Count / PAGE_SIZE), 1);
        }


        /// <summary>
        /// 先排序数据，再通过 key 选中某条数据，切到对应页，并高亮显示。
        /// </summary>
        /// <param name="key">Key.</param>
        public void SelectByKey(string key)
        {
            m_data.Sort();
            if (m_state == LanguageWindowState.Query)
                m_result.Sort();

            bool isContainsKey = false;
            List<LanguageItem> list = m_state == LanguageWindowState.Query ? m_result : m_data;
            for (int i = 0; i < list.Count; i++)
            {
                LanguageItem item = list[i];
                if (item.key == key)
                {
                    isContainsKey = true;
                    m_curPage = Mathf.FloorToInt((float)i / PAGE_SIZE) + 1;
                    break;
                }
            }

            if (isContainsKey)
            {
                m_selectedKey = key;
                m_selectCount = 10;
            }
            else if (key.Trim() != "")
            {
                m_oKey = m_oValue = m_value = "";
                m_key = key;
                ChangeState(LanguageWindowState.Append);
            }
        }


        #region 解析/修改文件

        /// <summary>
        /// 解析当前语言包
        /// </summary>
        private void ParseLanguage()
        {
            m_curPage = 1;
            ChangeState(LanguageWindowState.Normal);

            m_data.Clear();
            m_language = m_languages[m_languageIdx];
            string path = "Assets/Lua/Data/Languages/" + m_language + ".lua";
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

                        m_data.Add(new LanguageItem(key, value));
                    }
                }
            }
            m_data.Sort();
        }


        /// <summary>
        /// 保存当前语言包
        /// </summary>
        private void SaveLanguage()
        {
            m_data.Sort();
            StringBuilder sb = new StringBuilder();
            sb.Append("return {");
            foreach (var item in m_data)
            {
                sb.Append("\n[\"");
                sb.Append(item.key);
                sb.Append("\"] = \"");
                sb.Append(item.value);
                sb.Append("\",");
            }
            sb.Append("\n}");

            string path = "Assets/Lua/Data/Languages/" + m_language + ".lua";
            using (StreamWriter sw = new StreamWriter(path, false))
            {
                sw.Write(sb.ToString());
            }
        }


        /// <summary>
        /// 修改使用的语言包，语种-地区
        /// </summary>
        private void ChangeLocalization()
        {
            string path = "Assets/Lua/Data/Config.lua";
            StringBuilder sb = new StringBuilder();
            bool needWriteLanguage = true;
            using (StreamReader file = new StreamReader(path))
            {
                string line;
                while ((line = file.ReadLine()) != null)
                {
                    if (needWriteLanguage && line.Trim().StartsWith("Config.language", StringComparison.Ordinal))
                    {
                        sb.Append("Config.language = \"");
                        sb.Append(m_language);
                        sb.Append("\"");
                        needWriteLanguage = false;
                    }
                    else
                    {
                        sb.Append(line);
                    }
                    sb.Append("\n");
                }
            }

            using (StreamWriter sw = new StreamWriter(path, false))
            {
                sw.Write(sb.ToString());
            }
        }

        #endregion



        #region 查询/修改语言包数据

        /// <summary>
        /// 数据中是否包含指定的 key
        /// </summary>
        /// <returns><c>true</c>, if key was containsed, <c>false</c> otherwise.</returns>
        /// <param name="key">Key.</param>
        private bool ContainsKey(string key)
        {
            foreach (var item in m_data)
            {
                if (item.key == key)
                    return true;
            }
            return false;
        }


        /// <summary>
        /// 通过 key 来移除指定的数据
        /// </summary>
        /// <param name="key">Key.</param>
        private void RemoveByKey(string key)
        {
            foreach (var item in m_data)
            {
                if (item.key == key)
                {
                    m_data.Remove(item);
                    break;
                }
            }

            if (m_state == LanguageWindowState.Query)
            {
                foreach (var item in m_result)
                {
                    if (item.key == key)
                    {
                        m_result.Remove(item);
                        break;
                    }
                }
            }

            // 当前页已经不存在了
            int pageNum = GetPageNum();
            if (m_curPage > pageNum)
                m_curPage = pageNum;
        }


        /// <summary>
        /// 通过 key 来修改数据
        /// </summary>
        /// <param name="key">新 Key.</param>
        /// <param name="value">新 Value.</param>
        /// <param name="oKey">原 key.</param>
        private void ChangeItem(string key, string value, string oKey = null)
        {
            string k = oKey ?? key;
            foreach (var item in m_data)
            {
                if (item.key == k)
                {
                    item.key = key;
                    item.value = value;
                    break;
                }
            }
        }

        #endregion


        void OnDestroy()
        {
            if (m_language == string.Empty || m_languages.Length == 0 || m_languageIdx == -1)
                return;

            LocalizationText.RefreshLanguage();
        }


        //
    }


    /// <summary>
    /// 语言包数据条目
    /// </summary>
    public class LanguageItem : IComparable<LanguageItem>
    {
        public string key;
        public string value;
        public string key_lower;
        public string value_lower;

        public LanguageItem(string key, string value)
        {
            this.key = key;
            this.value = value;
            this.key_lower = this.key.ToLower();
            this.value_lower = this.value.ToLower();
        }

        public int CompareTo(LanguageItem other)
        {
            return string.Compare(key, other.key, StringComparison.Ordinal);
        }
    }


    /// <summary>
    /// 语言包窗口状态
    /// </summary>
    public enum LanguageWindowState
    {
        /// 正常
        Normal,
        /// 添加新数据
        Append,
        /// 编辑数据
        Edit,
        /// 查询
        Query,
    }
}

