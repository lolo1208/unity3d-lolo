using System.Collections.Generic;
using DG.Tweening;
using LuaInterface;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// 音频类型
    /// </summary>
    public enum AudioType
    {
        BGM,   // 背景音乐
        SFX,   // 音效
        SFX3D, // 3D 音效
    }



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
        /// 音频类型
        public AudioType type;
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
            Play();
        }


        /// <summary>
        /// 播放音频
        /// </summary>
        public void Play()
        {
            if (tweener != null)
            {
                tweener.Kill();
                tweener = null;
                StotAll();
            }

            lastTime = TimeUtil.timeSec;
            int length = (int)(clip.length * 1000);

            if (type == AudioType.BGM)
            {
                // 背景音乐使用 Play() 播放，为了精确获得播放状态与剩余时间
                src.Play();
                playingList.Add(Timer.Once(length, BgmTimerHandler));
            }
            else
            {
                // 音效使用 PlayOneShot() 播放，为了多个叠加
                src.PlayOneShot(clip);
                playingList.Add(Timer.Once(length, (timer) =>
                {
                    // 播放列表中已没有当前回调（已经被停止了）
                    if (!playingList.Remove(timer)) return;
                    DispatchCompleteEvent();

                    // 还有当前音效在播放
                    if (playingList.Count > 0) return;
                    ReplayOrStop();
                }));
            }
        }

        /// <summary>
        /// 背景音乐计时器回调处理函数
        /// </summary>
        /// <param name="timer"></param>
        private void BgmTimerHandler(Timer timer)
        {
            // 播放列表中已没有当前回调（已经被停止了）
            if (!playingList.Remove(timer)) return;

            // 音频还在播放中。可能切入后台等原因，导致计时器不同步
            if (src.isPlaying)
            {
                int remaining = (int)((clip.length - src.time) * 1000);
                playingList.Add(Timer.Once(remaining, BgmTimerHandler));
                return;
            }

            DispatchCompleteEvent();
            ReplayOrStop();
        }

        /// <summary>
        /// 继续重复播放，或标记为已停止
        /// </summary>
        private void ReplayOrStop()
        {
            if (--count > 0)
            {
                Debug.Log("重复播放");
                Play();// 还需要重复播放
            }
            else
                AudioManager.MarkStop(path);
        }

        /// <summary>
        /// 抛出音频播放完成事件
        /// </summary>
        private void DispatchCompleteEvent()
        {
            if (dispatchCompleteEvent)
                AudioManager.DispatchCompleteEvent(path);
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
        private static readonly HashSet<string> s_sfxList = new HashSet<string>();

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
        public static float SfxVolume
        {
            set
            {
                s_sfxVolume = value;
                foreach (string path in s_sfxList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.volume = value;
                }
            }

            get { return s_sfxVolume; }
        }
        private static float s_sfxVolume = 1;


        /// 设置 bgm 和音效的音量，包括3D音效
        public static void SetVolume(float volume)
        {
            BgmVolume = SfxVolume = volume;
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
        public static bool SfxMute
        {
            set
            {
                s_sfxMute = value;
                foreach (string path in s_sfxList)
                {
                    if (s_infoMap.TryGetValue(path, out AudioInfo info))
                        info.src.mute = value;
                }
            }

            get { return s_sfxMute; }
        }
        private static bool s_sfxMute;


        /// 设置是否静音
        public static void SetMute(bool mute) => BgmMute = SfxMute = mute;




        /// <summary>
        /// 播放 bgm
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="stopOtherBgm">是否停止其他 bgm</param>
        /// <param name="stopAllSfx">是否停止所有音效</param>
        public static void PlayBgm(string path, uint count = 0, bool stopOtherBgm = true, bool stopAllSfx = false)
        {
            if (stopOtherBgm) StopAllBgm();
            if (stopAllSfx) StopAllSfx();
            s_bgmList.Add(path);
            Play(path, AudioType.BGM, count);
        }


        /// <summary>
        /// 播放音效
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="replay">如果正在播放该音频，true: 重新播放，false: 叠加播放</param>
        public static void PlaySfx(string path, uint count = 1, bool replay = false)
        {
            if (replay) Stop(path);
            s_sfxList.Add(path);
            Play(path, AudioType.SFX, count);
        }


        /// <summary>
        /// 播放3D音效
        /// </summary>
        /// <param name="path">音频路径</param>
        /// <param name="go">对应的 gameObject</param>
        /// <param name="count">播放次数，0 表示无限循环</param>
        /// <param name="replay">如果正在播放该音频，true: 重新播放，false: 叠加播放</param>
        public static void Play3DSfx(string path, GameObject go, uint count = 1, bool replay = true)
        {
            if (replay) Stop(path);
            s_sfxList.Add(path);
            Play(path, AudioType.SFX3D, count, go);
        }


        /// <summary>
        /// 播放音频
        /// </summary>
        /// <param name="path">Path.</param>
        /// <param name="type">Type.</param>
        /// <param name="count">Count.</param>
        /// <param name="go">Go.</param>
        private static void Play(string path, AudioType type, uint count, GameObject go = null)
        {
            if (!s_infoMap.TryGetValue(path, out AudioInfo info))
            {
                info = new AudioInfo { path = path };
                info.src = GetAudioSource(go ?? s_go);
                s_infoMap.Add(path, info);
            }

            // 音频数据还在加载中
            if (info.clip == null && info.count > 0) return;

            bool isBgm = type == AudioType.BGM;
            bool isSfx3d = type == AudioType.SFX3D;

            // 3D音效 与 2D音频，切换 gameObject
            if (isSfx3d)
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
            info.src.volume = isBgm ? s_bgmVolume : s_sfxVolume;
            info.src.mute = isBgm ? s_bgmMute : s_sfxMute;
            info.src.spatialBlend = isSfx3d ? 1 : 0;
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
        public static void StopAllSfx(bool fadeOut = false)
        {
            foreach (string path in s_sfxList)
            {
                if (s_infoMap.TryGetValue(path, out AudioInfo info))
                    info.Stop(fadeOut);
            }
            s_sfxList.Clear();
        }


        /// <summary>
        /// 将 path 对应的音频标记为已停止
        /// </summary>
        /// <param name="path">Path.</param>
        [NoToLua]
        public static void MarkStop(string path)
        {
            s_bgmList.Remove(path);
            s_sfxList.Remove(path);
        }


        /// <summary>
        /// path 对应的音频是否正在播放
        /// </summary>
        /// <returns><c>true</c>, if playing was ised, <c>false</c> otherwise.</returns>
        /// <param name="path">Path.</param>
        public static bool IsPlaying(string path)
        {
            if (s_sfxList.Contains(path)) return true;
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
        public static void DispatchCompleteEvent(string path = null)
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
            s_sfxList.Clear();

            Object.Destroy(s_go);
            CreateAudioGameObject();
        }

        #endregion


        //
    }
}

