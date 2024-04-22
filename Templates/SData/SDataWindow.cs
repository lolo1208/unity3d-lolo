using System;
using System.IO;
using System.Data;
using System.Collections.Generic;
using MySql.Data.MySqlClient;
using UnityEngine;
using UnityEditor;


namespace GodEditor
{

    /**
     * 
     * 读取静态数据库，生成静态数据 SData（Lua）
     * 2020/10/20
     * Author: LOLO
     */
    public class SDataWindow : EditorWindow
    {
        private static readonly Rect WND_RECT = new Rect(0, 0, 510, 500);
        private const string WND_DIR = "Assets/Editor/SData/";
        private const string CONFIG_FILE_PATH = WND_DIR + "Setting.cfg";
        private const string LUA_DIR = "Assets/Lua/Data/SData/";
        private const string FIELD_FILE_PATH = LUA_DIR + "allTableFields.lua";

        private string m_cfg_server;
        private string m_cfg_port;
        private string m_cfg_database;
        private string m_cfg_userid;
        private string m_cfg_password;
        private string m_new_excluded = "";

        private readonly List<string> m_excludedList = new List<string>();

        private GUILayoutOption m_initialized;
        private Vector2 m_scrollPos = Vector2.zero;
        private GUIStyle m_bg1;
        private GUIStyle m_bg2;
        private GUIStyle m_bg3;

        private GUILayoutOption m_w50;
        private GUILayoutOption m_w75;
        private GUILayoutOption m_w150;
        private GUILayoutOption m_h30;
        private GUILayoutOption m_h260;


        public static void Open()
        {
            GetWindowWithRect<SDataWindow>(WND_RECT, true, "生成 SData");
        }


        private void Initialize()
        {
            if (m_initialized != null) return;
            m_initialized = GUILayout.Width(0);

            m_w50 = GUILayout.Width(50);
            m_w75 = GUILayout.Width(75);
            m_w150 = GUILayout.Width(150);
            m_h30 = GUILayout.Height(30);
            m_h260 = GUILayout.Height(260);

            ParseConfig();
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
            m_bg3.normal.background.SetPixel(0, 0, new Color(0.16f, 0.16f, 0.16f));
            m_bg3.normal.background.Apply();
        }



        void OnGUI()
        {
            Initialize();

            TextAnchor alignment;
            GUILayout.BeginArea(new Rect(20, 20, WND_RECT.width - 40, WND_RECT.height - 40));


            // 连接配置项
            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("Server：", m_w75);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_cfg_server = GUILayout.TextField(m_cfg_server, m_w150);
            GUI.skin.textField.alignment = alignment;

            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("Port：", m_w75);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_cfg_port = GUILayout.TextField(m_cfg_port, m_w150);
            GUI.skin.textField.alignment = alignment;
            GUILayout.EndHorizontal();

            GUILayout.Space(10);

            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("UserID：", m_w75);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_cfg_userid = GUILayout.TextField(m_cfg_userid, m_w150);
            GUI.skin.textField.alignment = alignment;

            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("Password：", m_w75);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_cfg_password = GUILayout.TextField(m_cfg_password, m_w150);
            GUI.skin.textField.alignment = alignment;
            GUILayout.EndHorizontal();

            GUILayout.Space(10);

            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("Database：", m_w75);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_cfg_database = GUILayout.TextField(m_cfg_database, m_w150);
            GUI.skin.textField.alignment = alignment;
            GUILayout.EndHorizontal();


            // title
            GUILayout.Space(10);
            GUILayout.BeginHorizontal(m_bg3);
            GUILayout.BeginVertical();
            GUILayout.Space(7);
            GUILayout.Label("需要排除的表和字段名称");
            GUILayout.Space(5);
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();

            // 排除列表
            m_scrollPos = GUILayout.BeginScrollView(m_scrollPos, m_h260);
            for (int i = 0; i < Math.Max(m_excludedList.Count, 10); i++)
            {
                bool hasValue = i < m_excludedList.Count;
                GUIStyle bg = (i % 2 == 0) ? m_bg1 : m_bg2;
                GUILayout.BeginHorizontal(bg);// item
                GUILayout.Space(15);

                if (hasValue)
                {
                    if (GUILayout.Button("移除", m_w50))
                    {
                        m_excludedList.RemoveAt(i);
                        return;
                    }
                }

                GUILayout.Space(5);
                GUILayout.BeginVertical();
                GUILayout.Space(5);
                GUILayout.Label(hasValue ? m_excludedList[i] : "");
                GUILayout.Space(3);
                GUILayout.EndVertical();

                GUILayout.EndHorizontal();// end item
            }
            GUILayout.EndScrollView();

            // 添加
            GUILayout.BeginHorizontal(m_bg3);
            GUILayout.Space(15);

            GUILayout.BeginVertical();
            GUILayout.Space(8);
            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_new_excluded = GUILayout.TextField(m_new_excluded);
            GUI.skin.textField.alignment = alignment;
            GUILayout.Space(9);
            GUILayout.EndVertical();

            GUILayout.BeginVertical(m_w50);
            GUILayout.Space(7);
            if (GUILayout.Button("添加"))
            {
                string newVal = m_new_excluded.Trim();
                if (newVal.Length > 0 && !m_excludedList.Contains(newVal))
                {
                    m_excludedList.Add(newVal);
                    m_excludedList.Sort();
                }
            }
            GUILayout.EndVertical();

            GUILayout.Space(15);
            GUILayout.EndHorizontal();


            // 生成
            GUILayout.Space(7);
            GUILayout.BeginHorizontal();
            GUILayout.Space(150);
            if (GUILayout.Button("生成 SData，保存配置项", m_h30))
            {
                SaveConfig();
                GenerateSData();
                AssetDatabase.Refresh();
            }
            GUILayout.Space(150);
            GUILayout.EndHorizontal();


            GUILayout.EndArea();
        }


        #region 生成 SData

        private void GenerateSData()
        {
            // 连接数据库
            var builder = new MySqlConnectionStringBuilder
            {
                Server = m_cfg_server,
                Port = uint.Parse(m_cfg_port),
                Database = m_cfg_database,
                UserID = m_cfg_userid,
                Password = m_cfg_password,
            };
            using (var conn = new MySqlConnection(builder.ConnectionString))
            {
                conn.Open();

                // 获取所有表名
                List<string> tables = new List<string>();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "show tables";
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string tableName = reader.GetString(0);
                            // 只添加未排除的表
                            if (!m_excludedList.Contains(tableName))
                                tables.Add(tableName);
                        }
                    }
                }

                // 清理输出目录
                if (Directory.Exists(LUA_DIR))
                    Directory.Delete(LUA_DIR, true);
                Directory.CreateDirectory(LUA_DIR);

                // 导出所有表
                using (StreamWriter wFields = new StreamWriter(File.Open(FIELD_FILE_PATH, FileMode.Create)))
                {
                    wFields.Write("return{");// start all fields
                    for (int t = 0; t < tables.Count; t++)
                    {
                        string tableName = tables[t];
                        if (t != 0) wFields.Write(",");// start table fields
                        wFields.Write(tableName + "={__tablename=\"" + tableName + "\"");

                        DataSet ds = new DataSet();
                        MySqlDataAdapter adapter = new MySqlDataAdapter("select * from " + tableName, conn);
                        try
                        {
                        	adapter.Fill(ds);
                        }
			            catch (Exception e)
			            {
			            	Debug.LogError("导出表：'" + tableName + "' 时出现异常！！！");
			            	throw e;
			            }
                        var table = ds.Tables[0];
                        var items = table.Rows;
                        var fields = table.Columns;

                        // 导出 lua 表
                        using (StreamWriter wTable = new StreamWriter(File.Open(LUA_DIR + tableName + ".lua", FileMode.Create)))
                        {
                            int fieldIndex = 0;
                            wTable.Write("return{");// start table
                            for (int i = 0; i < items.Count; i++)
                            {
                                if (i != 0) wTable.Write(",");// start item

                                wTable.Write("{");
                                DataRow item = items[i];
                                for (int f = 0; f < fields.Count; f++)
                                {
                                    DataColumn field = fields[f];
                                    string fieldName = field.ToString();
                                    // 在被排除的（字段）列表中
                                    if (m_excludedList.Contains(tableName + "." + fieldName))
                                        continue;

                                    // 字段类型
                                    string fieldType = field.DataType.Name.ToLower();
                                    if (fieldType != "string") fieldType = "number";

                                    // 在 fields lua 文件中写入字段索引
                                    if (i == 0)
                                        wFields.Write("," + fieldName + "=" + (++fieldIndex));

                                    if (f != 0) wTable.Write(",");// start value
                                    string val = item[field].ToString();
                                    if (val.Length == 0)
                                    {
                                        // 空数据写入空字符串 ""
                                        wTable.Write("\"\"");
                                    }
                                    else
                                    {
                                        if (fieldType == "string")
                                        {
                                            val = val.Replace("\n", "").Replace("\r", "");// 去除换行符
                                            wTable.Write("\"" + val + "\"");
                                        }
                                        else
                                        {
                                            wTable.Write(val);
                                        }
                                    }
                                }
                                wTable.Write("}");// end item
                            }
                            wTable.Write("}");// end table
                        }
                        wFields.Write("}");// end table fields
                    }
                    wFields.Write("}");// end all fields
                }
                ShowNotification(new GUIContent("生成静态数据（Lua）完毕！"));
            }
        }

        #endregion



        #region 解析与保存配置文件
        private void ParseConfig()
        {
            m_excludedList.Clear();
            using (StreamReader file = new StreamReader(CONFIG_FILE_PATH))
            {
                string line;
                int state = 0;
                while ((line = file.ReadLine()) != null)
                {
                    line = line.Trim();
                    if (line == "") continue;
                    if (line.StartsWith("//", StringComparison.Ordinal)) continue;

                    if (line.StartsWith("-", StringComparison.Ordinal))
                    {
                        if (line.StartsWith("-conn", StringComparison.Ordinal)) state = 1;
                        if (line.StartsWith("-excluded", StringComparison.Ordinal)) state = 2;
                        continue;
                    }

                    switch (state)
                    {
                        // 解析连接配置
                        case 1:
                            string[] arr = line.Split('=');
                            string val = arr[1].Trim();
                            switch (arr[0].Trim().ToLower())
                            {
                                case "server":
                                    m_cfg_server = val;
                                    break;
                                case "port":
                                    m_cfg_port = val;
                                    break;
                                case "database":
                                    m_cfg_database = val;
                                    break;
                                case "userid":
                                    m_cfg_userid = val;
                                    break;
                                case "password":
                                    m_cfg_password = val;
                                    break;
                            }
                            break;

                        // 解析排除列表
                        case 2:
                            if (!m_excludedList.Contains(line))
                                m_excludedList.Add(line);
                            break;
                    }
                }
            }
            m_excludedList.Sort();
        }


        private void SaveConfig()
        {
            using (StreamWriter writer = new StreamWriter(File.Open(CONFIG_FILE_PATH, FileMode.Create)))
            {
                // 写入连接配置项
                writer.WriteLine("-conn");
                writer.WriteLine("server = " + m_cfg_server);
                writer.WriteLine("port = " + m_cfg_port);
                writer.WriteLine("database = " + m_cfg_database);
                writer.WriteLine("userid = " + m_cfg_userid);
                writer.WriteLine("password = " + m_cfg_password);

                // 写入排除列表
                writer.WriteLine("-excluded");
                foreach (string val in m_excludedList)
                    writer.WriteLine(val);
            }
        }

        #endregion


        //
    }
}