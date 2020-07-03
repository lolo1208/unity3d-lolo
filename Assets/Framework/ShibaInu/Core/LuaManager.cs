using System;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// lua 管理器
    /// </summary>
    public class LuaManager : MonoBehaviour
    {
        private LuaLooper m_looper;

        public LuaState state { get; private set; }


        void Awake()
        {
            state = new LuaState();
            OpenLibs();
            state.LuaSetTop(0);

            LuaBinder.Bind(state);
            DelegateFactory.Init();
            LuaCoroutine.Register(state, this);
        }


        /// <summary>
        /// 初始化
        /// </summary>
        public void Initialize()
        {
#if UNITY_EDITOR
            // 这里只用添加 ShibaInu/Lua。ToLua/Lua 和 Assets/Lua 在 LuaState 里添加了
            state.AddSearchPath(Constants.ShibaInuRootPath + "Lua");
#endif

            // 启动 LuaVM
            state.Start();
            state.DoFile("Main.lua");
            StartLooper();
        }


        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        void OpenLibs()
        {
            state.OpenLibs(LuaDLL.luaopen_pb);
            //m_lua.OpenLibs(LuaDLL.luaopen_sproto_core);
            //m_lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
            state.OpenLibs(LuaDLL.luaopen_lpeg);
            state.OpenLibs(LuaDLL.luaopen_bit);
            state.OpenLibs(LuaDLL.luaopen_socket_core);

            // cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
            state.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            state.OpenLibs(LuaDLL.luaopen_cjson);
            state.LuaSetField(-2, "cjson");
            state.OpenLibs(LuaDLL.luaopen_cjson_safe);
            state.LuaSetField(-2, "cjson.safe");
        }


        void StartLooper()
        {
            m_looper = Common.go.AddComponent<LuaLooper>();
            m_looper.luaState = state;
        }


        public void DoFile(string filename)
        {
            state.DoFile(filename);
        }


        public void LuaGC()
        {
            state.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }


        /// <summary>
        /// 销毁
        /// </summary>
        public void Destroy()
        {
            m_looper.Destroy();
            Destroy(m_looper);
            m_looper = null;

            state.Dispose();
            state = null;

            Destroy(this);
        }


        //
    }
}

