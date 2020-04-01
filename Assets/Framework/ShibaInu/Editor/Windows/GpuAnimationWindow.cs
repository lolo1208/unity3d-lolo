using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace ShibaInu
{
    /// <summary>
    /// GPU 动画资源生成窗口
    /// </summary>
    public class GpuAnimationWindow : EditorWindow
    {
        private static readonly Rect WND_RECT = new Rect(0, 0, 530, 430);
        private static readonly string[] s_aniTypes = { "Gpu Animation", "Frame Animation" };
        private static readonly string[] s_shaderNames = { "ShibaInu/Component/GpuAnimation", "ShibaInu/Component/FrameAnimation" };

        private string m_fbxDir = "";
        private string m_texPath = "";
        private string m_exportDir = "";
        private string m_finalExportDir;
        private int m_aniType;
        private bool m_genSubDir = true;
        private bool m_tex2;
        private int m_fps;
        private int m_index;
        private string m_log = "";
        private readonly List<string> m_fbxList = new List<string>();

        private GUILayoutOption m_initialized;
        private GUILayoutOption m_w50;
        private GUILayoutOption m_w60;
        private GUILayoutOption m_w73;
        private GUILayoutOption m_w80;
        private GUILayoutOption m_w115;
        private GUILayoutOption m_w155;
        private GUILayoutOption m_w288;
        private GUILayoutOption m_w368;
        private GUILayoutOption m_w420;
        private GUILayoutOption m_h28;
        private GUILayoutOption m_h215;


        public static void Open()
        {
            GetWindowWithRect<GpuAnimationWindow>(WND_RECT, true, "GPU 动画资源生成器");
        }


        private void Initialize()
        {
            if (m_initialized != null) return;
            m_initialized = GUILayout.Width(0);

            m_w50 = GUILayout.Width(50);
            m_w60 = GUILayout.Width(60);
            m_w73 = GUILayout.Width(73);
            m_w80 = GUILayout.Width(80);
            m_w115 = GUILayout.Width(115);
            m_w155 = GUILayout.Width(155);
            m_w288 = GUILayout.Width(288);
            m_w368 = GUILayout.Width(368);
            m_w420 = GUILayout.Width(420);
            m_h28 = GUILayout.Height(28);
            m_h215 = GUILayout.Height(215);

            m_fbxDir = PlayerPrefs.GetString("GAW.fbxDir");
            m_exportDir = PlayerPrefs.GetString("GAW.exportDir");
            m_texPath = PlayerPrefs.GetString("GAW.texPath");
            m_aniType = PlayerPrefs.GetInt("GAW.aniType");
            m_fps = PlayerPrefs.GetInt("GAW.fps");
            m_tex2 = PlayerPrefs.GetInt("GAW.tex2") == 1;
        }


        void OnGUI()
        {
            Initialize();

            TextAnchor alignment;
            GUILayout.BeginArea(new Rect(20, 20, WND_RECT.width - 40, WND_RECT.height - 40));


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("fbx目录：", m_w60);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_fbxDir = GUILayout.TextField(m_fbxDir, m_w368);
            GUI.skin.textField.alignment = alignment;

            GUILayout.BeginVertical(m_w50);
            if (GUILayout.Button("浏览"))
            {
                string fbxDir = EditorUtility.OpenFolderPanel("选择动画资源所在目录（fbx 文件列表目录）", m_fbxDir, "");
                if (fbxDir != "") m_fbxDir = fbxDir;
            }
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();


            GUILayout.Space(10);


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("默认纹理：", m_w60);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_texPath = GUILayout.TextField(m_texPath, m_w368);
            GUI.skin.textField.alignment = alignment;

            GUILayout.BeginVertical(m_w50);
            if (GUILayout.Button("浏览"))
            {
                string texPath = EditorUtility.OpenFilePanel("动画模型使用的贴图", m_texPath, "png,jpg,gif,bmp,tga,psd,tiff,iff,tif,tca,pict");
                if (texPath != "") m_texPath = texPath;
            }
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();


            GUILayout.Space(10);


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("导出目录：", m_w60);
            GUI.skin.label.alignment = alignment;

            alignment = GUI.skin.textField.alignment;
            GUI.skin.textField.alignment = TextAnchor.MiddleLeft;
            m_exportDir = GUILayout.TextField(m_exportDir, m_w288);
            GUI.skin.textField.alignment = alignment;

            GUILayout.Space(3);
            EditorGUI.BeginDisabledGroup(true);
            m_genSubDir = GUILayout.Toggle(m_genSubDir, "创建子目录", m_w73);
            EditorGUI.EndDisabledGroup();

            GUILayout.BeginVertical(m_w50);
            if (GUILayout.Button("浏览"))
            {
                string exportDir = EditorUtility.OpenFolderPanel("最终生成资源的保存目录", m_exportDir, "");
                if (exportDir != "") m_exportDir = exportDir;
            }
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();


            GUILayout.Space(10);


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("动画类型：", m_w60);
            GUI.skin.label.alignment = alignment;

            m_aniType = EditorGUILayout.Popup(m_aniType, s_aniTypes, m_w115);
            GUILayout.Label(m_aniType == 0
                ? "给定播放速度等参数，自动切换帧实现动画播放"
                : "只显示给定帧号对应的画面，不会自动切换帧");


            GUILayout.EndHorizontal();


            GUILayout.Space(10);


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label(new GUIContent("采样帧频：", "值为 0 时表示采样时使用动画原有帧频"), m_w60);
            GUI.skin.label.alignment = alignment;

            m_fps = EditorGUILayout.IntField(m_fps, m_w50);
            m_fps = Mathf.Max(0, Mathf.Min(m_fps, 60));

            GUILayout.Space(10);
            m_tex2 = GUILayout.Toggle(m_tex2, "power of 2 texture sizes", m_w155);
            EditorGUI.BeginDisabledGroup(true);
            GUILayout.Toggle(true, "generate material", m_w115);
            EditorGUI.EndDisabledGroup();

            GUILayout.BeginVertical(m_w80);
            GUILayout.Space(-4);
            if (GUILayout.Button("开始生成", m_h28))
            {
                Export();
                return;
            }
            GUILayout.EndVertical();
            GUILayout.EndHorizontal();


            GUILayout.Space(10);


            GUILayout.BeginHorizontal();
            alignment = GUI.skin.label.alignment;
            GUI.skin.label.alignment = TextAnchor.MiddleRight;
            GUILayout.Label("生成日志：", m_w60);
            GUI.skin.label.alignment = alignment;

            GUILayout.TextArea(m_log, m_w420, m_h215);
            GUILayout.EndHorizontal();


            GUILayout.EndArea();
        }


        private void Export()
        {
            SaveSetting();
            m_log = "";
            AppendLog("开始导出");

            if (m_fbxDir == "")
            {
                ShowMessage("请选择 [fbx 目录]");
                return;
            }
            if (m_exportDir == "")
            {
                ShowMessage("请选择 [导出目录]");
                return;
            }
            if (m_texPath == "")
            {
                ShowMessage("请选择 [默认纹理]");
                return;
            }

            if (!Directory.Exists(m_fbxDir))
            {
                ShowMessage("所选的 [动画资源目录] 不存在！");
                return;
            }
            if (!File.Exists(m_texPath))
            {
                ShowMessage("所选的 [默认纹理] 文件不存在！");
                return;
            }

            string curDir = Directory.GetCurrentDirectory().Replace("\\", "/");

            m_fbxList.Clear();
            string[] files = Directory.GetFiles(m_fbxDir);
            foreach (string file in files)
                if (Path.GetExtension(file).ToLower() == ".fbx")
                    m_fbxList.Add(file.Replace(curDir, "").Substring(1));
            if (m_fbxList.Count == 0)
            {
                ShowMessage("[fbx 目录] 中不存在 *.fbx 文件！");
                return;
            }

            m_finalExportDir = m_exportDir;
            if (m_genSubDir) m_finalExportDir += "/" + Path.GetFileName(m_fbxDir);
            if (!m_finalExportDir.EndsWith("/", StringComparison.Ordinal)
                && !m_finalExportDir.EndsWith("\\", StringComparison.Ordinal))
                m_finalExportDir += "/";
            try
            {
                if (Directory.Exists(m_finalExportDir))
                    Directory.Delete(m_finalExportDir, true);
                Directory.CreateDirectory(m_finalExportDir);
                if (m_finalExportDir.StartsWith(curDir, StringComparison.Ordinal))
                    m_finalExportDir = m_finalExportDir.Replace(curDir, "").Substring(1);
            }
            catch
            {
                ShowMessage("无法清空或创建 [导出目录]");
                return;
            }

            m_index = -1;
            ExportNext();
        }


        private void ExportNext()
        {
            string dirName = Path.GetFileName(m_fbxDir);
            string meshPath = m_finalExportDir + "Mesh.asset";
            string mainTexPath = m_finalExportDir + "MainTex" + Path.GetExtension(m_texPath);

            m_index++;
            if (m_index == m_fbxList.Count)
            {
                ShowMessage("导出完毕！");
                ShowMessage("请手动选中所有生成的材质球\n然后在 [Inspector] 窗口中\n启用 [Enable GPU Instancing]");
                return;
            }

            string fbxPath = m_fbxList[m_index];
            string aniDataPath, aniMatPath;
            EditorUtility.DisplayProgressBar("Export Animation", fbxPath, (float)(m_index + 1) / m_fbxList.Count);

            try
            {
                GameObject fbx = AssetDatabase.LoadAssetAtPath<GameObject>(fbxPath);
                Shader shader = Shader.Find(s_shaderNames[m_aniType]);


                // 合并 mesh
                SkinnedMeshRenderer[] skinnedMeshes = fbx.GetComponentsInChildren<SkinnedMeshRenderer>();
                CombineInstance[] combines = new CombineInstance[skinnedMeshes.Length];
                Mesh[] meshes = new Mesh[skinnedMeshes.Length];
                for (int i = 0; i < skinnedMeshes.Length; i++)
                {
                    combines[i].mesh = skinnedMeshes[i].sharedMesh;
                    combines[i].transform = skinnedMeshes[i].transform.localToWorldMatrix;
                    meshes[i] = new Mesh();
                }
                Mesh mesh = new Mesh();
                mesh.CombineMeshes(combines);


                if (m_index == 0)
                {
                    AppendLog(string.Format(
                        "\n资源名称:{0}, 顶点数:{1}, 面数:{2}",
                        dirName, mesh.vertexCount, mesh.triangles.Length / 3
                    ));

                    // 保存合并的 mesh
                    AssetDatabase.CreateAsset(mesh, meshPath);
                    AppendLog("生成合并网格：" + meshPath);

                    // 拷贝默认纹理
                    File.Copy(m_texPath, mainTexPath, true);
                    AssetDatabase.Refresh();
                    AppendLog("已拷贝纹理至：" + mainTexPath);
                }


                // 提取动画数据
                Animation animation = fbx.GetComponent<Animation>();
                List<AnimationState> states = new List<AnimationState>(animation.Cast<AnimationState>());
                Texture2D aniData;
                float aniLen;
                int width, height, fps, frameNum, vertexCount;

                foreach (AnimationState state in states)
                {
                    AnimationClip clip = state.clip;
                    string aniName = state.name;
                    animation.Play(aniName);

                    aniLen = clip.length;
                    vertexCount = mesh.vertexCount;
                    fps = m_fps == 0 ? (int)clip.frameRate : m_fps;
                    frameNum = (int)Mathf.Round(fps * aniLen);

                    width = m_tex2 ? Mathf.NextPowerOfTwo(vertexCount) : vertexCount;
                    height = m_tex2 ? Mathf.ClosestPowerOfTwo(frameNum) : frameNum;
                    aniData = new Texture2D(width, height, TextureFormat.RGBAHalf, false);

                    float perFrameTime = aniLen / (height - 1);
                    for (int y = 0; y < height; y++)
                    {
                        state.time = Mathf.Min(perFrameTime * y, aniLen);
                        animation.Sample();

                        mesh = new Mesh();
                        for (int n = 0; n < skinnedMeshes.Length; n++)
                        {
                            var smr = skinnedMeshes[n];
                            var m = meshes[n];
                            smr.BakeMesh(m);
                            combines[n].mesh = m;
                            combines[n].transform = smr.localToWorldMatrix;
                        }
                        mesh.CombineMeshes(combines);

                        for (int x = 0; x < vertexCount; x++)
                        {
                            Vector3 vertex = mesh.vertices[x];
                            aniData.SetPixel(x, y, new Color(vertex.x, vertex.y, vertex.z));
                        }
                    }

                    // 将动画数据纹理保存成文件
                    aniData.Apply();
                    aniDataPath = m_finalExportDir + aniName + ".asset";
                    AssetDatabase.CreateAsset(aniData, aniDataPath);
                    AppendLog("\n生成动画纹理：" + aniDataPath);

                    // 生成材质球
                    Material material = new Material(shader);
                    Texture mainTex = AssetDatabase.LoadAssetAtPath<Texture>(mainTexPath);
                    material.SetTexture("_MainTex", mainTex);
                    material.SetTexture("_AniTex", aniData);
                    if (m_aniType == 0)
                        material.SetFloat("_AniLen", aniLen);
                    else
                        material.SetInt("_FrameCount", frameNum);
                    aniMatPath = m_finalExportDir + aniName + ".mat";
                    AssetDatabase.CreateAsset(material, aniMatPath);
                    AppendLog("已生成材质球：" + aniMatPath);

                    // 打印动画信息
                    AppendLog(string.Format(
                        "动画名称:{0}, 时长:{1:N3}s, 采样帧频:{2}, 总帧数:{3}, 纹理尺寸:{4}x{5}",
                        aniName, aniLen, fps, frameNum, width, height
                    ));
                }

                // 继续导出
                ExportNext();
            }
            catch (Exception e)
            {
                ShowMessage("导出文件：" + fbxPath + " 出错！");
                Debug.Log(e);
            }
        }


        private void ShowMessage(string msg)
        {
            EditorUtility.ClearProgressBar();
            AppendLog("\n" + msg);
            ShowNotification(new GUIContent(msg));
        }


        private void SaveSetting()
        {
            PlayerPrefs.SetString("GAW.fbxDir", m_fbxDir);
            PlayerPrefs.SetString("GAW.exportDir", m_exportDir);
            PlayerPrefs.SetString("GAW.texPath", m_texPath);
            PlayerPrefs.SetInt("GAW.aniType", m_aniType);
            PlayerPrefs.SetInt("GAW.fps", m_fps);
            PlayerPrefs.SetInt("GAW.tex2", m_tex2 ? 1 : 0);
        }


        private void AppendLog(string log)
        {
            if (m_log != "") m_log += "\n";
            m_log += log;
        }


        void OnDestroy()
        {
            SaveSetting();
        }


        //
    }
}
