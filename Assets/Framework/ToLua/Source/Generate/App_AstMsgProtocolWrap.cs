﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class App_AstMsgProtocolWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(App.AstMsgProtocol), typeof(System.Object));
		L.RegFunction("Send", Send);
		L.RegFunction("New", _CreateApp_AstMsgProtocol);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("isCluster", get_isCluster, set_isCluster);
		L.RegVar("isCompress", get_isCompress, set_isCompress);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateApp_AstMsgProtocol(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				ShibaInu.ISocket arg0 = (ShibaInu.ISocket)ToLua.CheckObject<ShibaInu.ISocket>(L, 1);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 2);
				App.AstMsgProtocol obj = new App.AstMsgProtocol(arg0, arg1);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 3)
			{
				ShibaInu.ISocket arg0 = (ShibaInu.ISocket)ToLua.CheckObject<ShibaInu.ISocket>(L, 1);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 2);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 3);
				App.AstMsgProtocol obj = new App.AstMsgProtocol(arg0, arg1, arg2);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 4)
			{
				ShibaInu.ISocket arg0 = (ShibaInu.ISocket)ToLua.CheckObject<ShibaInu.ISocket>(L, 1);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 2);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 3);
				bool arg3 = LuaDLL.luaL_checkboolean(L, 4);
				App.AstMsgProtocol obj = new App.AstMsgProtocol(arg0, arg1, arg2, arg3);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: App.AstMsgProtocol.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Send(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 6)
			{
				App.AstMsgProtocol obj = (App.AstMsgProtocol)ToLua.CheckObject<App.AstMsgProtocol>(L, 1);
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				string arg2 = ToLua.CheckString(L, 4);
				string arg3 = ToLua.CheckString(L, 5);
				int arg4 = (int)LuaDLL.luaL_checknumber(L, 6);
				obj.Send(arg0, arg1, arg2, arg3, arg4);
				return 0;
			}
			else if (count == 7)
			{
				App.AstMsgProtocol obj = (App.AstMsgProtocol)ToLua.CheckObject<App.AstMsgProtocol>(L, 1);
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				string arg2 = ToLua.CheckString(L, 4);
				string arg3 = ToLua.CheckString(L, 5);
				int arg4 = (int)LuaDLL.luaL_checknumber(L, 6);
				byte arg5 = (byte)LuaDLL.luaL_checknumber(L, 7);
				obj.Send(arg0, arg1, arg2, arg3, arg4, arg5);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: App.AstMsgProtocol.Send");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isCluster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			App.AstMsgProtocol obj = (App.AstMsgProtocol)o;
			bool ret = obj.isCluster;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isCluster on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isCompress(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			App.AstMsgProtocol obj = (App.AstMsgProtocol)o;
			bool ret = obj.isCompress;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isCompress on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isCluster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			App.AstMsgProtocol obj = (App.AstMsgProtocol)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isCluster = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isCluster on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isCompress(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			App.AstMsgProtocol obj = (App.AstMsgProtocol)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isCompress = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isCompress on a nil value");
		}
	}
}
