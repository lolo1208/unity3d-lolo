using System;
using UnityEngine;
using UnityEngine.Playables;
using LuaInterface;


namespace ShibaInu
{
    public class CallLuaPlayable : PlayableBehaviour
    {

        /// 要调用的 lua 方法
        public string method;
        /// 调用 lua 方法时，附带的参数
        public string[] args;

        /// 是否正在播放中
        private bool m_playing;



        /// This function is called when the Playable play state is changed to PlayState.Playing.
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if (Application.isPlaying && !m_playing)
            {
                m_playing = true;
                CallLuaFunction(true, method, args);
            }
        }


        /// This function is called when the Playable play state is changed to PlayState.Paused.
        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            if (Application.isPlaying && m_playing)
            {
                m_playing = false;
                CallLuaFunction(false, method, args);
            }
        }



        /// <summary>
        /// Calls the lua function.
        /// </summary>
        /// <param name="isPlay">If set to <c>true</c> is play.</param>
        /// <param name="method">Method.</param>
        /// <param name="args">Arguments.</param>
        private static void CallLuaFunction(bool isPlay, string method, string[] args)
        {
            LuaFunction luaFn = Common.luaMgr.state.GetFunction(method);
            luaFn.BeginPCall();
            luaFn.Push(isPlay);
            foreach (string param in args)
                luaFn.Push(param);
            luaFn.PCall();
            luaFn.EndPCall();
        }


        //
    }
}

