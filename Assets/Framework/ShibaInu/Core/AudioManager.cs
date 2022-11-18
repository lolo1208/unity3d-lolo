using System.Collections.Generic;
using DG.Tweening;
using LuaInterface;
using UnityEngine;


namespace ShibaInu
{

    /// <summary>
    /// 音频信息
    /// </summary>
    public class AudioInfo
    {
        /// 音频路径
        public string path;
        /// 对应的 AudioSource
        public AudioSource src;
        /// 对应的 AudioClip 数据
        public AudioClip clip;
        /// 上次播放时间。用于判断继续缓存还是卸载
        public float lastTime;
        /// 音频类型 [ 1:BGM, 2:音效, 3:3D音效 ]
        public int type;
        /// 剩余播放次数
        public uint count;
        /// 正在播放的结束回调列表
        public HashSet<Timer> playingList = new HashSet<Timer>();
        /// 淡出的 tweener
        public Tweener tweener;
        /// 播放完成时，是否需要抛出事件
        public bool dispatchCompleteEvent;


        public void LoadClipComplete(LoadResEvent e)
        {
            if (e.path != path) return;
            ResManager.LoadCompleteHandler.Remove(LoadClipComplete);
            src.clip = clip = (AudioClip)e.data;
            lastTime = TimeUtil.timeSec;
            Play();
        }


        public void Play()
        {
            if (tweener != null)
            {
                tweener.Kill();
                tweener = null;
                StotAll();
            }

            src.PlayOneShot(clip);
            playingList.Add(Timer.Once((int)(clip.length * 1000), (timer) =>
            {
                // 播放列表中还有当前回调
                if (playingList.Remove(timer))
                {
                    lastTime = TimeUtil.timeSec;

                    if (dispatchCompleteEvent)
                        AudioManager.DispatchEvent(path);

                    // 只用考虑最后一次播放时传入的次数
                    if (playingList.Count == 0)
                    {
                        if (--count > 0)
                            Play();// 还有次数，继续播放
                        else
                            AudioManager.MarkStop(path);
                    }
                }
            }));
        }


        public void Stop(bool fadeOut)
        {
            if (playingList.Count == 0) return;
            playingList.Clear();

            if (fadeOut)
            {
                Tweener t = src.DOFade(0, AudioManager.FadeOutDuration);
                tweener = t;
                Timer.Once((int)(AudioManager.FadeOutDuration * 1000), (obj) =>
                {
                    if (tweener == t) tweener = null;
                    if (!AudioManager.IsPlaying(path))
                        StotAll();
                });
            }
            else
                StotAll();
        }


        private void StotAll()
        {
            src.enabled = false;
            src.enabled = true;
        }


        //
    }



    /// <summary>
    /// 音频管理
    /// </summary>
    public static class AudioManager
    {
        /// bgm 和 音效(2D) 对应的 gameObject
        private static GameObject s_go;

        /// info 列表
        private static readonly Dictionary<string, AudioInfo> s_infoMap = new Dictionary<string, AudioInfo>();
        /// bgm 列表
        private static readonly HashSet<string> s_bgmList = new HashSet<string>();
        /// 音效列表，包括3D音效
        private static readonly HashSet<string> s_effList = new HashSet<string>();

        /// 淡出效果的持续时间（秒）
        public static float FadeOutDuration = 1.5f;
        /// 音频的最大缓存时间（秒）
        public static float CacheTime = 5 * 60;



        /// bgm 音量
        public static float BgmVolume
        {
            set
            {
                s_bgmVolume = value;
                foreach (string path in s_bgmList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.volume = value;
                }
            }

            get { return s_bgmVolume; }
        }
        private static float s_bgmVolume = 1;


        /// 音效音量，包括3D音效
        public static float EffectVolume
        {
            set
            {
                s_effectVolume = value;
                foreach (string path in s_effList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.volume = value;
                }
            }

            get { return s_effectVolume; }
        }
        private static float s_effectVolume = 1;


        /// 设置 bgm 和音效的音量，包括3D音效
        public static void SetVolume(float volume)
        {
            BgmVolume = EffectVolume = volume;
        }


        /// bgm 是否静音
        public static bool BgmMute
        {
            set
            {
                s_bgmMute = value;
                foreach (string path in s_bgmList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.mute = value;
                }
            }

            get { return s_bgmMute; }
        }
        private static bool s_bgmMute;


        /// 音效是否静音
        public static bool EffectMute
        {
            set
            {
                s_effectMute = value;
                foreach (string path in s_effList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.mute = value;
                }
            }

            get { return s_effectMute; }
        }
        private static bool s_effectMute;


        /// 设置是否静音
        public static void SetMute(bool mute) => BgmMute = EffectMute = mute;




        /// <summary>
        /// 播放 bgm
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="stopOtherBgm">是否停止其他 bgm</param>
        /// <param name="stopAllEffect">是否停止所有音效</param>
        public static void PlayBgm(string path, uint count = 0, bool stopOtherBgm = true, bool stopAllEffect = true)
        {
            if (stopOtherBgm) StopAllBgm();
            if (stopAllEffect) StopAllEffect();
            s_bgmList.Add(path);
            Play(path, 1, count);
        }


        /// <summary>
        /// 播放音效
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="replay">如果正在播放该音频，true: 重新播放，false: 叠加播放</param>
        public static void PlayEffect(string path, uint count = 1, bool replay = false)
        {
            if (replay) Stop(path);
            s_effList.Add(path);
            Play(path, 2, count);
        }


        /// <summary>
        /// 播放3D音效
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="go">对应的 gameObject</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="replay">如果正在播放该音频，true: 重新播放，false: 叠加播放</param>
        public static void Play3D(string path, GameObject go, uint count = 1, bool replay = true)
        {
            if (replay) Stop(path);
            s_effList.Add(path);
            Play(path, 3, count, go);
        }


        /// <summary>
        /// 播放音频
        /// </summary>
        /// <param name="path">Path.</param>
        /// <param name="type">Type.</param>
        /// <param name="count">Count.</param>
        /// <param name="go">Go.</param>
        private static void Play(string path, int type, uint count, GameObject go = null)
        {
            if (!s_infoMap.TryGetValue(path, out AudioInfo info))
            {
                info = new AudioInfo { path = path };
                info.src = GetAudioSource(go ?? s_go);
                s_infoMap.Add(path, info);
            }

            // 音频数据还在加载中
            if (info.clip == null && info.count > 0) return;

            // 3D音效 与 2D音频，切换 gameObject
            if (type == 3)
            {
                if (info.src.gameObject != go) info.src = GetAudioSource(go, info.clip);
            }
            else
            {
                if (info.src.gameObject != s_go) info.src = GetAudioSource(s_go, info.clip);
            }

            // 设置属性
            info.type = type;
            info.lastTime = TimeUtil.timeSec;
            info.src.volume = type == 1 ? s_bgmVolume : s_effectVolume;
            info.src.mute = type == 1 ? s_bgmMute : s_effectMute;
            info.src.spatialBlend = type == 3 ? 1 : 0;
            info.count = count > 0 ? count : uint.MaxValue;

            // 加载或播放
            if (info.clip == null)
            {
                ResManager.LoadCompleteHandler.Add(info.LoadClipComplete);
                ResManager.LoadAudioClipAsync(path, path);
            }
            else
                info.Play();
        }


        /// <summary>
        /// 在 go 上获取或创建 AudioSource
        /// </summary>
        /// <returns>The audio source.</returns>
        /// <param name="go">Go.</param>
        /// <param name="clip">Clip.</param>
        private static AudioSource GetAudioSource(GameObject go, AudioClip clip = null)
        {
            if (clip != null)
            {
                AudioSource[] list = go.GetComponents<AudioSource>();
                foreach (AudioSource s in list)
                    if (s.clip == clip) return s;
            }

            AudioSource src = go.AddComponent<AudioSource>();
            src.playOnAwake = false;
            src.clip = clip;
            return src;
        }



        /// <summary>
        /// 停止 path 对应的所有正在播放的音频
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="fadeOut">是否淡出</param>
        public static void Stop(string path, bool fadeOut = false)
        {
            if (s_infoMap.TryGetValue(path, out AudioInfo info))
            {
                MarkStop(path);
                info.Stop(fadeOut);
            }
        }


        /// <summary>
        /// 停止所有 bgm
        /// </summary>
        /// <param name="fadeOut">是否淡出</param>
        public static void StopAllBgm(bool fadeOut = true)
        {
            foreach (string path in s_bgmList)
            {
                if (s_infoMap.TryGetValue(path, out AudioInfo info))
                    info.Stop(fadeOut);
            }
            s_bgmList.Clear();
        }


        /// <summary>
        /// 停止所有音效，包括3D音效
        /// </summary>
        /// <param name="fadeOut">是否淡出</param>
        public static void StopAllEffect(bool fadeOut = false)
        {
            foreach (string path in s_effList)
            {
                if (s_infoMap.TryGetValue(path, out AudioInfo info))
                    info.Stop(fadeOut);
            }
            s_effList.Clear();
        }


        /// <summary>
        /// 将 path 对应的音频标记为已停止
        /// </summary>
        /// <param name="path">Path.</param>
        [NoToLua]
        public static void MarkStop(string path)
        {
            s_bgmList.Remove(path);
            s_effList.Remove(path);
        }


        /// <summary>
        /// path 对应的音频是否正在播放
        /// </summary>
        /// <returns><c>true</c>, if playing was ised, <c>false</c> otherwise.</returns>
        /// <param name="path">Path.</param>
        public static bool IsPlaying(string path)
        {
            if (s_effList.Contains(path)) return true;
            if (s_bgmList.Contains(path)) return true;
            return false;
        }


        /// <summary>
        /// 设置 path 对应的音频在播放完毕时是否抛出事件。
        /// 请在调用 Play() 之后再调用该方法。
        /// </summary>
        /// <param name="path">Path.</param>
        /// <param name="isDispatch">If set to <c>true</c> is dispatch.</param>
        public static void SetDispatchCompleteEvent(string path, bool isDispatch)
        {
            if (s_infoMap.TryGetValue(path, out AudioInfo info))
                info.dispatchCompleteEvent = isDispatch;
        }




        /// <summary>
        /// 初始化
        /// </summary>
        [NoToLua]
        public static void Initialize()
        {
            CreateAudioGameObject();
            Timer.Once(1000 * 60, ClearCache);
        }


        /// <summary>
        /// 创建 bgm 和 音效(2D) 对应的 gameObject
        /// </summary>
        private static void CreateAudioGameObject()
        {
            s_go = new GameObject("Audio");
            s_go.transform.SetParent(Common.go.transform);
        }


        /// <summary>
        /// 检查缓存是否已过期，并清除它
        /// </summary>
        /// <param name="timer">Timer.</param>
        private static void ClearCache(Timer timer)
        {
            float time = TimeUtil.GetTimeSec();
            List<string> unloadList = new List<string>();
            foreach (var item in s_infoMap)
            {
                AudioInfo info = item.Value;
                if (!IsPlaying(info.path) && time - info.lastTime > CacheTime)
                {
                    unloadList.Add(info.path);
                    ResManager.Unload(info.path);
                    Object.Destroy(info.src);
                    // Debug.LogFormat("[ShibaInu.AudioManager] Unload Audio: {0}", info.path);
                }
            }

            foreach (string path in unloadList)
                s_infoMap.Remove(path);

            Timer.Once(1000 * 60, ClearCache);
        }




        #region 在 lua 层抛出音频播放完成事件

        private static LuaFunction s_dispatchEvent;

        [NoToLua]
        public static void DispatchEvent(string path = null)
        {
            // Events/Event.lua
            if (s_dispatchEvent == null)
                s_dispatchEvent = Common.luaMgr.state.GetFunction("Event.DispatchAudioCompleteEvent");

            s_dispatchEvent.BeginPCall();
            s_dispatchEvent.Push(path);
            s_dispatchEvent.PCall();
            s_dispatchEvent.EndPCall();
        }

        #endregion




        #region 清空所有引用（在动更结束后重启 app 时）

        [NoToLua]
        public static void ClearReference()
        {
            s_dispatchEvent = null;
            s_infoMap.Clear();
            s_bgmList.Clear();
            s_effList.Clear();

            Object.Destroy(s_go);
            CreateAudioGameObject();
        }

        #endregion


        //
    }
}

