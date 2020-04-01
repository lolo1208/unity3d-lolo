using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

using UnityEngine;

using UnityEditor;


namespace ShibaInu
{
    /// <summary>
    /// 日志查看窗口
    /// </summary>
    public class LogWindow : EditorWindow
    {
        private static readonly Rect WND_RECT = new Rect(0, 0, 800, 630);
        private const int PAGE_SIZE = 50;

        private readonly string[] TYPEs = { "全部", "报错 & 异常 & 断言", "普通", "警告", "全部网络日志", "发包成功 & 失败", "后端推送" };

        private readonly List<LogItem> m_data = new List<LogItem>();
        private readonly List<LogItem> m_result = new List<LogItem>();
        private int m_curPage = 1;
        private string m_path;
        private bool m_openStackTrace;
        private string m_errorMsg;
        private Vector2 m_scrollPos = Vector2.zero;

        private string[] m_types;
        private int m_typeIndex;
        private string m_customType = "";
        private string m_query = "";

        private GUIStyle m_bg1;
        private GUIStyle m_bg2;
        private Color m_colorNormal;
        private Color m_colorError;
        private Texture2D m_infoTex;
        private Texture2D m_warnTex;
        private Texture2D m_errorTex;

        private GUILayoutOption m_initialized;
        private GUILayoutOption m_w20;
        private GUILayoutOption m_w30;
        private GUILayoutOption m_w45;
        private GUILayoutOption m_w50;
        private GUILayoutOption m_w60;
        private GUILayoutOption m_w67;
        private GUILayoutOption m_w70;
        private GUILayoutOption m_w75;
        private GUILayoutOption m_w80;
        private GUILayoutOption m_w90;
        private GUILayoutOption m_w100;
        private GUILayoutOption m_w120;
        private GUILayoutOption m_w390;
        private GUILayoutOption m_h504;
        private bool m_refresh;



        public static void Open()
        {
            GetWindowWithRect<LogWindow>(WND_RECT, true, "查看日志");
        }



        private void Initialize()
        {
            if (m_initialized != null) return;
            m_initialized = GUILayout.Width(0);

            m_colorNormal = new Color(0.7f, 0.7f, 0.7f);
            m_colorError = new Color(0.9f, 0.9f, 0.9f);

            m_infoTex = EditorGUIUtility.Load("icons/console.infoicon.sml.png") as Texture2D;
            m_warnTex = EditorGUIUtility.Load("icons/console.warnicon.sml.png") as Texture2D;
            m_errorTex = EditorGUIUtility.Load("icons/console.erroricon.sml.png") as Texture2D;

            m_w20 = GUILayout.Width(20);
            m_w30 = GUILayout.Width(30);
            m_w45 = GUILayout.Width(45);
            m_w50 = GUILayout.Width(50);
            m_w60 = GUILayout.Width(60);
            m_w67 = GUILayout.Width(67);
            m_w70 = GUILayout.Width(70);
            m_w75 = GUILayout.Width(75);
            m_w80 = GUILayout.Width(80);
            m_w90 = GUILayout.Width(90);
            m_w100 = GUILayout.Width(100);
            m_w120 = GUILayout.Width(120);
            m_w390 = GUILayout.Width(390);

            m_h504 = GUILayout.Height(504);

            m_types = TYPEs;
            m_path = Path.GetFullPath(LogFileWriter.FILE_PATH);
            LoadLogFile();
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
        }


        void OnGUI()
        {
            Initialize();

            GUILayout.Space(15);
            GUILayout.BeginHorizontal();

            GUILayout.Space(10);
            GUILayout.Label("日志文件路径：", m_w80);

            TextAnchor textFieldAlignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleRight;
            m_path = GUILayout.TextField(m_path, m_w390);
            GUI.skin.textField.alignment = textFieldAlignment;

            GUILayout.Space(2);
            GUILayout.BeginVertical(m_w45);
            if (GUILayout.Button("浏览"))
            {
                string file = EditorUtility.OpenFilePanel("Open File Dialog", m_path, "log,txt");
                if (file != "")
                {
                    m_path = file;
                    LoadLogFile();
                }
            }
            GUILayout.EndVertical();

            GUILayout.Space(2);
            GUILayout.BeginVertical(m_w75);
            if (GUILayout.Button("加载/刷新"))
            {
                LoadLogFile();
            }
            GUILayout.EndVertical();

            GUILayout.Space(13);
            GUILayout.BeginVertical(m_w70);
            if (GUILayout.Button("查看文件"))
            {
#if UNITY_EDITOR_OSX
                //System.Diagnostics.Process.Start ("open", Path.GetDirectoryName (m_path));
                System.Diagnostics.Process.Start("open", m_path);
#else
				System.Diagnostics.Process.Start ("Explorer", "/select," + m_path);
#endif
            }
            GUILayout.EndVertical();

            GUILayout.EndHorizontal();


            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);
            GUILayout.Label("筛选指定类型：", m_w80);
            int typeIndex = m_typeIndex;
            m_typeIndex = EditorGUILayout.Popup(m_typeIndex, m_types, m_w120);

            GUILayout.Space(10);
            GUILayout.Label("自定义类型：", m_w67);
            m_customType = GUILayout.TextField(m_customType, m_w90);
            GUILayout.BeginVertical(m_w45);
            if (GUILayout.Button("筛选"))
            {
                string customType = m_customType.Trim().ToLower();
                if (customType != "")
                {
                    // 可能已有该类型
                    m_typeIndex = 0;
                    for (int i = TYPEs.Length; i < m_types.Length; i++)
                    {
                        if (customType == m_types[i])
                        {
                            m_typeIndex = i;
                            break;
                        }
                    }
                    // 新增自定义类型
                    if (m_typeIndex == 0)
                    {
                        List<string> types = new List<string>(m_types) { customType };
                        m_typeIndex = m_types.Length;
                        m_types = types.ToArray();
                    }
                }
            }

            // 类型筛选有改变
            if (m_typeIndex != typeIndex || m_refresh)
            {
                HashSet<string> typeList = new HashSet<string>();
                string typeName = m_types[m_typeIndex];
                switch (m_typeIndex)
                {
                    case 0:
                        m_result.Clear();
                        break;
                    case 1:
                        typeList.Add(LogData.TYPE_ERROR);
                        typeList.Add(LogData.TYPE_EXCEPTION);
                        typeList.Add(LogData.TYPE_ASSERT);
                        break;
                    case 2:
                        typeList.Add(LogData.TYPE_LOG);
                        break;
                    case 3:
                        typeList.Add(LogData.TYPE_WARNING);
                        break;
                    case 4:
                        typeList.Add(LogData.TYPE_NET_SUCC);
                        typeList.Add(LogData.TYPE_NET_FAIL);
                        typeList.Add(LogData.TYPE_NET_PUSH);
                        break;
                    case 5:
                        typeList.Add(LogData.TYPE_NET_SUCC);
                        typeList.Add(LogData.TYPE_NET_FAIL);
                        break;
                    case 6:
                        typeList.Add(LogData.TYPE_NET_PUSH);
                        break;
                    default:
                        typeList.Add(typeName);
                        break;
                }

                if (typeList.Count > 0)
                {
                    m_result.Clear();
                    foreach (LogItem item in m_data)
                    {
                        if (m_typeIndex >= TYPEs.Length && typeList.Contains(item.type_lower))
                        {
                            m_result.Add(item);
                        }
                        else if (typeList.Contains(item.type))
                        {
                            m_result.Add(item);
                        }
                    }
                    if (m_result.Count == 0)
                    {
                        m_typeIndex = 0;
                        ShowNotification(new GUIContent("没有类型为 [" + typeName + "] 的日志"));
                    }
                    ScrollToLastItem();
                }
            }
            GUILayout.EndVertical();

            GUILayout.Space(43);
            GUILayout.Label("匹配关键字：", m_w67);
            m_query = GUILayout.TextField(m_query, m_w100);
            GUILayout.BeginVertical(m_w45);
            if (m_result.Count > 0 && m_query.Trim() == "")
            {
                if (GUILayout.Button("全部"))
                {
                    m_typeIndex = 0;
                    m_result.Clear();
                    ScrollToLastItem();
                }
            }
            else
            {
                if (GUILayout.Button("查询") || m_refresh)
                {
                    m_typeIndex = 0;
                    m_result.Clear();
                    string query = m_query.ToLower();
                    foreach (var item in m_data)
                    {
                        if (item.title_lower.Contains(query) || item.stackTrace_lower.Contains(query))
                        {
                            m_result.Add(item);
                        }
                    }
                    if (m_result.Count == 0)
                    {
                        ShowNotification(new GUIContent("没有查询到任何匹配 [" + m_query + "] 的日志"));
                    }
                    ScrollToLastItem();
                }
            }
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();


            GUILayout.Space(10);
            GUILayout.BeginHorizontal();
            GUILayout.Space(10);

            if (m_errorMsg != null)
            {
                GUILayout.Label(m_errorMsg);
                GUILayout.EndHorizontal();
                return;
            }
            GUILayout.EndHorizontal();


            m_scrollPos = GUILayout.BeginScrollView(m_scrollPos, m_h504);
            Color textColor = GUI.skin.label.normal.textColor;

            var list = m_result.Count > 0 ? m_result : m_data;
            int startIndex = (m_curPage - 1) * PAGE_SIZE;
            int count = Mathf.Min(PAGE_SIZE, list.Count - startIndex);
            for (int i = 0; i < count; i++)
            {
                int index = startIndex + i;
                LogItem item = list[index];

                GUIStyle bg = (i % 2 == 0) ? m_bg1 : m_bg2;
                GUI.skin.label.normal.textColor = item.isError ? m_colorError : m_colorNormal;
                GUILayout.BeginHorizontal(bg);// item
                GUILayout.Space(15);

                // icon
                GUILayout.BeginVertical(m_w20); // icon or space
                GUILayout.Space(5);
                if (item.hasStackTrace)
                {
                    Texture2D tex;
                    if (item.isError)
                        tex = m_errorTex;
                    else if (item.isWarn)
                        tex = m_warnTex;
                    else
                        tex = m_infoTex;

                    if (GUILayout.Button(tex, GUI.skin.label))
                    {
                        item.openStackTrace = !item.openStackTrace;
                    }
                    GUILayout.Space(2);
                }
                else
                {
                    GUILayout.Label("");
                    GUILayout.Space(5);
                }
                GUILayout.EndVertical(); //end icon or space

                // title
                GUILayout.BeginVertical(); // title and stackTrace
                GUILayout.Space(6);
                if (GUILayout.Button(item.title, GUI.skin.label))
                {
                    item.openStackTrace = !item.openStackTrace;
                    CopyToSCB(item);
                }

                // stackTrace
                if (item.hasStackTrace && item.openStackTrace)
                {
                    GUILayout.Space(-2);
                    GUI.skin.label.normal.textColor = m_colorNormal;
                    if (GUILayout.Button(item.stackTrace, GUI.skin.label))
                    {
                        CopyToSCB(item);
                    }
                    GUILayout.Space(6);
                }
                GUILayout.EndVertical(); //end title and stackTrace


                GUILayout.EndHorizontal();// end item
            }

            GUI.skin.label.normal.textColor = textColor;
            GUILayout.EndScrollView();


            // page
            GUILayout.Space(10);
            GUILayout.BeginHorizontal();

            GUILayout.Space(15);
            bool openStackTrace = m_openStackTrace;
            m_openStackTrace = GUILayout.Toggle(m_openStackTrace, "展开堆栈信息", m_w90);
            if (m_openStackTrace != openStackTrace)
            {
                foreach (var item in m_data)
                    item.openStackTrace = m_openStackTrace;
            }

            GUILayout.Space(180);

            EditorGUI.BeginDisabledGroup(m_curPage <= 1);
            GUILayout.BeginVertical(m_w60);
            if (GUILayout.Button("上一页"))
            {
                m_curPage--;
                m_scrollPos.y = float.MaxValue;
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
                m_scrollPos.y = float.MinValue;
            }
            GUILayout.EndVertical();
            EditorGUI.EndDisabledGroup();

            GUILayout.EndHorizontal();
            m_refresh = false;
        }


        /// <summary>
        /// 加载日志文件
        /// </summary>
        private void LoadLogFile()
        {
            GUI.FocusControl(null);
            m_errorMsg = null;

            if (!File.Exists(m_path))
            {
                m_errorMsg = "日志文件：" + m_path + " 不存在！";
                return;
            }

            m_data.Clear();
            using (StreamReader sr = new StreamReader(m_path))
            {
                string line;
                LogItem item = null;
                StringBuilder sb = new StringBuilder();
                while (true)
                {
                    line = sr.ReadLine();

                    // 一条数据结束
                    if (string.IsNullOrEmpty(line))
                    {
                        if (item != null && item.type != null)
                        {
                            if (sb.Length > 0)
                            {
                                item.hasStackTrace = true;
                                item.stackTrace = sb.ToString().TrimEnd();
                                item.stackTrace_lower = item.stackTrace.ToLower();
                            }
                            else
                            {
                                item.hasStackTrace = false;
                            }
                            m_data.Add(item);
                        }
                        if (line == null)
                            break;

                        item = new LogItem();
                        sb.Length = 0;


                    }
                    else if (line == "stack traceback:" || line.StartsWith("info: ", StringComparison.Ordinal))
                    {
                        // 开始 堆栈 或 网络日志详情
                        sb.AppendLine(line);

                    }
                    else
                    {
                        if (sb.Length > 0)
                        {
                            sb.AppendLine(line);// 继续读取堆栈信息

                        }
                        else if (item != null)
                        {
                            item.title = line;
                            item.title_lower = item.title.ToLower();
                            item.type = line.Substring(1, line.IndexOf("]", StringComparison.Ordinal) - 1);
                            item.type_lower = item.type.ToLower();
                            item.isError = item.type == "Error" || item.type == "Exception" || item.type == "Assert";
                            item.isWarn = item.type == "Warning";
                        }
                    }
                }
            }
            m_refresh = true;
            m_result.Clear();
            ScrollToLastItem();
        }


        /// <summary>
        /// 获取总页数
        /// </summary>
        private int GetPageNum()
        {
            List<LogItem> list = m_result.Count > 0 ? m_result : m_data;
            return Mathf.Max(Mathf.CeilToInt((float)list.Count / PAGE_SIZE), 1);
        }


        /// <summary>
        /// 滚动到最后一条数据
        /// </summary>
        private void ScrollToLastItem()
        {
            m_curPage = GetPageNum();
            m_scrollPos.y = float.MaxValue;
            GUI.FocusControl(null);
        }


        /// <summary>
        /// 将日志信息拷贝到系统剪切板
        /// </summary>
        /// <param name="data">Data.</param>
        private void CopyToSCB(LogItem data)
        {
            GUIUtility.systemCopyBuffer = data.title + "\n" + data.stackTrace;
        }


        //
    }


    public class LogItem
    {
        public string type;
        public string title;
        public string stackTrace;

        public string type_lower;
        public string title_lower;
        public string stackTrace_lower = "";


        public bool isError;
        public bool isWarn;
        public bool hasStackTrace;
        public bool openStackTrace;
    }


}

