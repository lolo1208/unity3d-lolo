using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using LuaInterface;


namespace ShibaInu
{
	/// <summary>
	/// 本地化相关内容
	/// </summary>
	public class Localization
	{
		private static bool s_initialized = false;
		private static Dictionary<string, string> s_languageDic = new Dictionary<string, string> ();

		/// 当前语种和地区名称
		private static string s_language = "zh-CN";





		/// <summary>
		/// 初始化
		/// </summary>
		[NoToLuaAttribute]
		public static void Initialize ()
		{
//			if (s_initialized)
//				return;
//			s_initialized = true;

			s_languageDic.Clear ();

			// 编辑器开发模式
			if (Application.isEditor && !Application.isPlaying) {
				#if UNITY_EDITOR

				string filePath = Constants.ResDirPath + "Lua/Data/Languages/" + s_language + ".lua";
				if (!File.Exists (filePath)) {
					
				}

				#endif
			} else {
				
			}

		}


		/// <summary>
		/// 刷新语言包
		/// </summary>
		public static void RefreshLanguage ()
		{
			s_initialized = false;
			Initialize ();
		}


		/// <summary>
		/// 当前语种和地区名称
		/// </summary>
		/// <value>The language.</value>
		public static string Language {
			set {
				s_language = value;
				RefreshLanguage ();
			}

			get { return s_language; }
		}



		//
	}
}

