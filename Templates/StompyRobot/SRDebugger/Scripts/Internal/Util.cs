﻿namespace SRDebugger.Internal
{
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Reflection;
    using SRF.Helpers;
    using UnityEngine;
    using UnityEngine.EventSystems;

    public static class SRDebuggerUtil
    {
        public static bool IsMobilePlatform
        {
            get
            {
                if (Application.isMobilePlatform)
                {
                    return true;
                }

                switch (Application.platform)
                {
#if UNITY_5 || UNITY_5_3_OR_NEWER
                    case RuntimePlatform.WSAPlayerARM:
                    case RuntimePlatform.WSAPlayerX64:
                    case RuntimePlatform.WSAPlayerX86:
#else
					case RuntimePlatform.MetroPlayerARM:
					case RuntimePlatform.MetroPlayerX64:
					case RuntimePlatform.MetroPlayerX86:
#endif
                        return true;

                    default:
                        return false;
                }
            }
        }

        /// <summary>
        /// If no event system exists, create one
        /// </summary>
        /// <returns>True if the event system was created as a result of this call</returns>
        public static bool EnsureEventSystemExists()
        {
            if (!Settings.Instance.EnableEventSystemGeneration)
            {
                return false;
            }

            if (EventSystem.current != null)
            {
                return false;
            }

            var e = Object.FindObjectOfType<EventSystem>();

            // Check if EventSystem is in the scene but not registered yet
            if (e != null && e.gameObject.activeSelf && e.enabled)
            {
                return false;
            }

            Debug.LogWarning("[SRDebugger] No EventSystem found in scene - creating a default one.");

            CreateDefaultEventSystem();
            return true;
        }

        public static void CreateDefaultEventSystem()
        {
            var go = new GameObject("EventSystem");
            go.AddComponent<EventSystem>();
            go.AddComponent<StandaloneInputModule>();

            // TouchInputModule is deprecated in Unity 5.3 and above
#if UNITY_4_6 || UNITY_4_7 || UNITY_4_7 || UNITY_5_0 || UNITY_5_1 || UNITY_5_2
            go.AddComponent<TouchInputModule>();
#endif
        }

        /// <summary>
        /// Scan <paramref name="obj" /> for valid options and return a collection of them.
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static ICollection<OptionDefinition> ScanForOptions(object obj)
        {
            var options = new List<OptionDefinition>();

#if NETFX_CORE
			var members = obj.GetType().GetTypeInfo().DeclaredMembers;
#else

            var members =
                obj.GetType().GetMembers(BindingFlags.Instance | BindingFlags.Public | BindingFlags.GetProperty |
                                         BindingFlags.SetProperty | BindingFlags.InvokeMethod);

#endif

            foreach (var memberInfo in members)
            {
                // Find user-specified category name from attribute
                var categoryAttribute = SRReflection.GetAttribute<CategoryAttribute>(memberInfo);
                var category = categoryAttribute == null ? "Default" : categoryAttribute.Category;

                // Find user-specified sorting priority from attribute
                var sortAttribute = SRReflection.GetAttribute<SROptions.SortAttribute>(memberInfo);
                var sortPriority = sortAttribute == null ? 0 : sortAttribute.SortPriority;

                // Find user-specified display name from attribute
                var nameAttribute = SRReflection.GetAttribute<SROptions.DisplayNameAttribute>(memberInfo);
                var name = nameAttribute == null ? memberInfo.Name : nameAttribute.Name;

                if (memberInfo is PropertyInfo)
                {
                    var propertyInfo = memberInfo as PropertyInfo;

                    // Only allow properties with public read/write
#if NETFX_CORE
					if(propertyInfo.GetMethod == null)
						continue;
					
					// Ignore static members
					if (propertyInfo.GetMethod.IsStatic)
						continue;
#else
                    if (propertyInfo.GetGetMethod() == null)
                    {
                        continue;
                    }

                    // Ignore static members
                    if ((propertyInfo.GetGetMethod().Attributes & MethodAttributes.Static) != 0)
                    {
                        continue;
                    }
#endif

                    options.Add(new OptionDefinition(name, category, sortPriority,
                        new SRF.Helpers.PropertyReference(obj, propertyInfo)));
                }
                else if (memberInfo is MethodInfo)
                {
                    var methodInfo = memberInfo as MethodInfo;

                    if (methodInfo.IsStatic)
                    {
                        continue;
                    }

                    // Skip methods with parameters or non-void return type
                    if (methodInfo.ReturnType != typeof (void) || methodInfo.GetParameters().Length > 0)
                    {
                        continue;
                    }

                    options.Add(new OptionDefinition(name, category, sortPriority,
                        new SRF.Helpers.MethodReference(obj, methodInfo)));
                }
            }

            return options;
        }

        public static string GetNumberString(int value, int max, string exceedsMaxString)
        {
            if (value >= max)
            {
                return exceedsMaxString;
            }

            return value.ToString();
        }

        public static void ConfigureCanvas(Canvas canvas)
        {
            if (Settings.Instance.UseDebugCamera)
            {
                canvas.worldCamera = Service.DebugCamera.Camera;
                canvas.renderMode = RenderMode.ScreenSpaceCamera;
            }
        }
    }
}
