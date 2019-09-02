using System;
using System.Collections;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
    /// <summary>
    /// lua 管理器
    /// </summary>
    public class LuaManager : MonoBehaviour
    {
        private LuaState m_lua;
        private LuaLooper m_looper = null;

        public LuaState state
        {
            get { return m_lua; }
        }


        void Awake()
        {
            m_lua = new LuaState();
            this.OpenLibs();
            m_lua.LuaSetTop(0);

            LuaBinder.Bind(m_lua);
            DelegateFactory.Init();
            LuaCoroutine.Register(m_lua, this);
        }


        /// <summary>
        /// 初始化
        /// </summary>
        public void Initialize()
        {
#if UNITY_EDITOR
            // 这里只用添加 ShibaInu/Lua。ToLua/Lua 和 Assets/Lua 在 LuaState 里添加了
            m_lua.AddSearchPath(Constants.ShibaInuRootPath + "Lua");
#endif
            m_lua.Start();// 启动LuaVM
            StartMain();
            StartLooper();
        }

        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        void OpenLibs()
        {
            m_lua.OpenLibs(LuaDLL.luaopen_pb);
            //m_lua.OpenLibs(LuaDLL.luaopen_sproto_core);
            //m_lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
            m_lua.OpenLibs(LuaDLL.luaopen_lpeg);
            m_lua.OpenLibs(LuaDLL.luaopen_bit);
            m_lua.OpenLibs(LuaDLL.luaopen_socket_core);

            // cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
            m_lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            m_lua.OpenLibs(LuaDLL.luaopen_cjson);
            m_lua.LuaSetField(-2, "cjson");
            m_lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
            m_lua.LuaSetField(-2, "cjson.safe");
        }

        void StartLooper()
        {
            m_looper = Common.go.AddComponent<LuaLooper>();
            m_looper.luaState = m_lua;
        }


        /// <summary>
        /// lua入口
        /// </summary>
        void StartMain()
        {
            m_lua.DoFile("Main.lua");
        }


        public void DoFile(string filename)
        {
            m_lua.DoFile(filename);
        }


        // Update is called once per frame
        [Obsolete]
        public object[] CallFunction(string funcName, params object[] args)
        {
            LuaFunction func = m_lua.GetFunction(funcName);
            if (func != null)
            {
                return func.LazyCall(args);
            }
            return null;
        }

        public void LuaGC()
        {
            m_lua.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }


        public IEnumerator DelayToInvokeDo(Action action, float delaySeconds)
        {
            yield return new WaitForSeconds(delaySeconds);
            action();
        }


        /// <summary>
        /// 销毁
        /// </summary>
        public void Destroy()
        {
            m_looper.Destroy();
            Destroy(m_looper);
            m_looper = null;

            m_lua.Dispose();
            m_lua = null;

            Destroy(this);
        }


        //
    }
}

