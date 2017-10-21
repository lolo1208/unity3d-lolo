using System;
using System.Collections;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	public class LuaManager : MonoBehaviour
	{
		private LuaState lua;
		private LuaLooper loop = null;

		public LuaState state{
			get { return lua; }
		}

		
		void Awake()
		{
			lua = new LuaState();
			this.OpenLibs();
			lua.LuaSetTop(0);

			LuaBinder.Bind(lua);
			DelegateFactory.Init();
			LuaCoroutine.Register(lua, this);

//			StartCoroutine(DelayToInvokeDo(() =>
//				{
//					Application.LoadLevel("Scene1");
//				}, 3));
		}


		/// <summary>
		/// 初始化
		/// </summary>
		public void Initialize() {
			InitLuaPath ();
			lua.Start ();// 启动LuaVM
			StartMain ();
			StartLooper ();
		}


		/// <summary>
		/// 初始化Lua代码加载路径
		/// </summary>
		void InitLuaPath() {
			if (Constants.isDebug) {
				lua.AddSearchPath(Constants.ToLuaRootPath + "Lua");
				lua.AddSearchPath(Constants.ShibaInuRootPath + "Lua");
				lua.AddSearchPath(Application.dataPath + "Lua");
			} else {
//				lua.AddSearchPath(Util.DataPath + "lua");
			}
		}

		/// <summary>
		/// 初始化加载第三方库
		/// </summary>
		void OpenLibs() {
			lua.OpenLibs(LuaDLL.luaopen_pb);      
			lua.OpenLibs(LuaDLL.luaopen_sproto_core);
			lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
			lua.OpenLibs(LuaDLL.luaopen_lpeg);
			lua.OpenLibs(LuaDLL.luaopen_bit);
			lua.OpenLibs(LuaDLL.luaopen_socket_core);

			// cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
			lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
			lua.OpenLibs(LuaDLL.luaopen_cjson);
			lua.LuaSetField(-2, "cjson");
			lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
			lua.LuaSetField(-2, "cjson.safe");
		}

		void StartLooper() {
			loop = Common.go.AddComponent<LuaLooper>();
			loop.luaState = lua;
		}


		/// <summary>
		/// lua入口
		/// </summary>
		void StartMain() {
			lua.DoFile("Main.lua");
		}


		public void DoFile(string filename) {
			lua.DoFile(filename);
		}


		// Update is called once per frame
		public object[] CallFunction(string funcName, params object[] args) {
			LuaFunction func = lua.GetFunction(funcName);
			if (func != null) {
				return func.LazyCall(args);
			}
			return null;
		}

		public void LuaGC() {
			lua.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
		}


		public void Destroy() {
			loop.Destroy();
			loop = null;

			lua.Dispose();
			lua = null;
		}



		public IEnumerator DelayToInvokeDo(Action action, float delaySeconds)
		{
			yield return new WaitForSeconds(delaySeconds);
			action();
		}

	}
}

