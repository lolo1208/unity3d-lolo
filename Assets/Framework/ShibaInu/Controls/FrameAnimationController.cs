using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 帧动画控制器
    /// 将动画都放到一个列表中，在 Update() 的时候一起更新
    /// </summary>
    public class FrameAnimationController
    {
        /// 包含的所有动画列表，调用 AddAnimation() 返回的 id 为 key
        private readonly Dictionary<int, FrameAnimation> m_aniMap = new Dictionary<int, FrameAnimation>();
        /// 正在播放的动画列表
        private readonly HashSet<FrameAnimation> m_playingList = new HashSet<FrameAnimation>();
        /// 需要被停止的动画列表
        private readonly List<FrameAnimation> m_stoppingList = new List<FrameAnimation>();
        /// 缓存的材质数据列表
        private readonly Dictionary<string, MaterialData> m_matCaheMap = new Dictionary<string, MaterialData>();
        /// 缓存的 mesh 列表
        private readonly Dictionary<string, Mesh> m_meshCaheMap = new Dictionary<string, Mesh>();
        /// 用于更新材质 shader
        private readonly MaterialPropertyBlock m_props = new MaterialPropertyBlock();
        /// 唯一 ID
        private int m_id;



        /// <summary>
        /// 添加一个动画
        /// </summary>
        /// <returns>动画 ID，稍后可使用该 ID 来调用相关方法设置动画</returns>
        /// <param name="go">对应的 gameObject</param>
        /// <param name="assetDir">动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）</param>
        public int AddAnimation(GameObject go, string assetDir)
        {
            MeshFilter filter = go.GetComponent<MeshFilter>();
            if (filter == null) filter = go.AddComponent<MeshFilter>();

            MeshRenderer renderer = go.GetComponent<MeshRenderer>();
            if (renderer == null) renderer = go.AddComponent<MeshRenderer>();

            FrameAnimation ani = new FrameAnimation
            {
                id = ++m_id,
                filter = filter,
                renderer = renderer,
                useMainTex = true
            };
            m_aniMap.Add(ani.id, ani);
            SetAssetDir(ani, assetDir);

            return ani.id;
        }


        /// <summary>
        /// 设置动画所在资源目录
        /// </summary>
        /// <param name="ani">Ani.</param>
        /// <param name="assetDir">Asset dir.</param>
        private void SetAssetDir(FrameAnimation ani, string assetDir)
        {
            if (!assetDir.EndsWith("/", System.StringComparison.Ordinal))
                assetDir += "/";
            if (ani.assetDir == assetDir)
                return;

            string meshPath = assetDir + "Mesh.asset";
            Mesh mesh;
            if (!m_meshCaheMap.TryGetValue(meshPath, out mesh))
            {
                mesh = (Mesh)ResManager.LoadAsset(meshPath);
                m_meshCaheMap.Add(meshPath, mesh);
            }

            ani.assetDir = assetDir;
            ani.filter.sharedMesh = mesh;
            m_playingList.Remove(ani);
        }


        /// <summary>
        /// 设置动画所在资源目录
        /// </summary>
        /// <param name="id">Identifier.</param>
        /// <param name="assetDir">Asset dir.</param>
        public void SetAssetDir(int id, string assetDir)
        {
            FrameAnimation ani;
            if (!m_aniMap.TryGetValue(id, out ani))
            {
                Logger.LogException(string.Format(Constants.E1003, id));
                return;
            }
            if (ani.assetDir != assetDir)
                SetAssetDir(ani, assetDir);
        }


        /// <summary>
        /// 设置是否使用 MainTex
        /// </summary>
        /// <param name="id">Identifier.</param>
        /// <param name="value">true: 使用 MainTex, false: 使用 SecondTex</param>
        public void SetUseMainTex(int id, bool value)
        {
            FrameAnimation ani;
            if (!m_aniMap.TryGetValue(id, out ani))
            {
                Logger.LogException(string.Format(Constants.E1003, id));
                return;
            }
            if (ani.useMainTex == value) return;

            // 更新 shader _UseMainTex
            ani.renderer.GetPropertyBlock(m_props);
            m_props.SetInt("_UseMainTex", value ? 1 : 0);
            ani.renderer.SetPropertyBlock(m_props);
        }


        /// <summary>
        /// 播放动画
        /// </summary>
        /// <returns>该动画总帧数</returns>
        /// <param name="id">动画 ID</param>
        /// <param name="aniName">动画名称</param>
        /// <param name="loop">是否循环</param>
        /// <param name="restart">是否重新开始播放</param>
        /// <param name="randomFrame">是否随机当前帧号</param>
        public int PlayAnimation(int id, string aniName, bool loop = false, bool restart = true, bool randomFrame = false)
        {
            FrameAnimation ani;
            if (!m_aniMap.TryGetValue(id, out ani))
            {
                Logger.LogException(string.Format(Constants.E1003, id));
                return 0;
            }

            if (!loop && restart) ani.currentFrame = 0;
            ani.loop = loop;
            m_playingList.Add(ani);

            // 动画没变化
            if (ani.aniName == aniName)
                return ani.frameCount;

            string matPath = ani.assetDir + aniName + ".mat";
            MaterialData data;
            if (!m_matCaheMap.TryGetValue(matPath, out data))
            {
                Material mat = (Material)ResManager.LoadAsset(matPath);
                data = new MaterialData
                {
                    material = mat,
                    frameCount = mat.GetInt("_FrameCount")
                };
                m_matCaheMap.Add(matPath, data);
            }

            ani.material = data.material;
            ani.frameCount = data.frameCount;
            ani.aniName = aniName;
            ani.currentFrame = loop && randomFrame ? Random.Range(0, data.frameCount) : 0;
            m_playingList.Add(ani);

            return ani.frameCount;
        }


        /// <summary>
        /// 停止动画
        /// </summary>
        /// <param name="id">动画 ID</param>
        public void StopAnimation(int id)
        {
            FrameAnimation ani;
            if (m_aniMap.TryGetValue(id, out ani))
                m_playingList.Remove(ani);
        }


        /// <summary>
        /// 移除动画
        /// </summary>
        /// <param name="id">动画 ID</param>
        public void RemoveAnimation(int id)
        {
            FrameAnimation ani;
            if (m_aniMap.TryGetValue(id, out ani))
                m_playingList.Remove(ani);
            m_aniMap.Remove(id);
        }


        /// <summary>
        /// 更新全部动画
        /// </summary>
        /// <param name="frameNum">递增的帧数</param>
        public void Update(int frameNum = 1)
        {
            foreach (FrameAnimation ani in m_playingList)
            {
                // 更新材质球
                if (ani.material != null)
                {
                    ani.renderer.sharedMaterial = ani.material;
                    ani.material = null;
                }

                // 更新帧
                ani.currentFrame += frameNum;
                if (ani.currentFrame > ani.frameCount)
                {
                    if (ani.loop)
                        ani.currentFrame -= ani.frameCount;
                    else
                        ani.currentFrame = ani.frameCount;
                }

                // 无需循环的动画已达末尾帧
                if (!ani.loop && ani.currentFrame == ani.frameCount)
                    m_stoppingList.Add(ani);

                // 更新 shader _CurrentFrame
                ani.renderer.GetPropertyBlock(m_props);
                m_props.SetInt("_CurrentFrame", ani.currentFrame);
                ani.renderer.SetPropertyBlock(m_props);
            }

            if (m_stoppingList.Count > 0)
            {
                foreach (FrameAnimation ani in m_stoppingList)
                    m_playingList.Remove(ani);
                m_stoppingList.Clear();
            }
        }


        /// <summary>
        /// 清空
        /// </summary>
        public void Clear()
        {
            m_aniMap.Clear();
            m_playingList.Clear();
            m_stoppingList.Clear();
            m_matCaheMap.Clear();
            m_meshCaheMap.Clear();
        }



        /// <summary>
        /// 帧动画数据结构
        /// </summary>
        public class FrameAnimation
        {
            public MeshFilter filter;
            public MeshRenderer renderer;
            /// 动画 ID
            public int id;
            /// 动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）
            public string assetDir;
            /// 当前是否使用 MainTex，或使用 SecondTex(false)
            public bool useMainTex;
            /// 当前动画名称
            public string aniName;
            /// 需要在 Update() 时切换到该材质球
            public Material material;
            /// 总帧数
            public int frameCount;
            /// 当前帧
            public int currentFrame;
            /// 是否循环播放
            public bool loop;
        }


        /// <summary>
        /// 动画材质球数据结构
        /// </summary>
        public class MaterialData
        {
            public Material material;
            /// 总帧数
            public int frameCount;
        }


        //
    }
}
