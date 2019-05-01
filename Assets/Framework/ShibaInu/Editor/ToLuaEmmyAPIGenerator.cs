using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using LuaInterface;
using UnityEditor;
using UnityEngine;

namespace Emmy
{
    using BindType = ToLuaMenu.BindType;

    public static class ToLuaEmmyAPIGenerator
    {
        //[MenuItem("Lua/Gen API for EmmyLua")]
        public static void DoIt()
        {
            Filter<Type> baseFilter = new GeneralFilter<Type>(ToLuaMenu.baseType);
            Filter<Type> dropFilter = new GeneralFilter<Type>(ToLuaMenu.dropType);
            string dirPath = "LuaAPI";
            if (Directory.Exists(dirPath))
                Directory.Delete(dirPath, true);
            var directory = Directory.CreateDirectory(dirPath);
            var collection = new BindTypeCollection(CustomSettings.customTypeList);
            var bindTypes = collection.CollectBindType(baseFilter, dropFilter);
            foreach (var bindType in bindTypes)
            {
                var generator = new LuaAPIGenerator();
                generator.Gen(bindType);
            }
            Debug.LogFormat("API 生成完毕. {0}", directory.FullName);
        }
    }

    abstract class Filter<T>
    {
        public delegate void EachProcessor(T value);

        public abstract bool Contains(T type);

        public Filter<T> Exclude(params Filter<T>[] others)
        {
            Filter<T> v = this;
            for (var i = 0; i < others.Length; i++)
            {
                v = new ExcludeFilter<T>(v, others[i]);
            }
            return v;
        }

        public Filter<T> And(params Filter<T>[] others)
        {
            Filter<T> v = this;
            for (var i = 0; i < others.Length; i++)
            {
                v = new AndFilter<T>(v, others[i]);
            }
            return v;
        }

        public Filter<T> Or(params Filter<T>[] others)
        {
            Filter<T> v = this;
            for (var i = 0; i < others.Length; i++)
            {
                v = new OrFilter<T>(v, others[i]);
            }
            return v;
        }

        public virtual void Each(EachProcessor processor)
        {

        }
    }

    class ExcludeFilter<T> : Filter<T>
    {
        private readonly Filter<T> _baseFilter;
        private readonly Filter<T> _excludeFilter;

        public ExcludeFilter(Filter<T> baseFilter, Filter<T> excludeFilter)
        {
            _baseFilter = baseFilter;
            _excludeFilter = excludeFilter;
        }

        public override bool Contains(T type)
        {
            return _baseFilter.Contains(type) && !_excludeFilter.Contains(type);
        }

        public override void Each(EachProcessor processor)
        {
            _baseFilter.Each(v =>
            {
                if (!_excludeFilter.Contains(v))
                {
                    processor(v);
                }
            });
        }
    }

    class OrFilter<T> : Filter<T>
    {
        private readonly Filter<T> _baseFilter;
        private readonly Filter<T> _orFilter;

        public OrFilter(Filter<T> baseFilter, Filter<T> orFilter)
        {
            _baseFilter = baseFilter;
            _orFilter = orFilter;
        }

        public override bool Contains(T type)
        {
            return _baseFilter.Contains(type) || _orFilter.Contains(type);
        }

        public override void Each(EachProcessor processor)
        {
            _baseFilter.Each(processor);
            _orFilter.Each(processor);
        }
    }

    class AndFilter<T> : Filter<T>
    {
        private readonly Filter<T> _baseFilter;
        private readonly Filter<T> _andFilter;

        public AndFilter(Filter<T> baseFilter, Filter<T> andFilter)
        {
            _baseFilter = baseFilter;
            _andFilter = andFilter;
        }

        public override bool Contains(T type)
        {
            return _baseFilter.Contains(type) && _andFilter.Contains(type);
        }

        public override void Each(EachProcessor processor)
        {
            _baseFilter.Each(v =>
            {
                if (_andFilter.Contains(v))
                {
                    processor(v);
                }
            });
        }
    }

    class GeneralFilter<T> : Filter<T>
    {
        private readonly ICollection<T> _arr;

        public GeneralFilter(ICollection<T> arr)
        {
            _arr = arr;
        }

        public override bool Contains(T type)
        {
            return _arr.Contains(type);
        }

        public override void Each(EachProcessor processor)
        {
            foreach (T x1 in _arr)
            {
                processor(x1);
            }
        }
    }

    class BindTypeCollection : Filter<BindType>
    {
        private readonly Queue<BindType> _typeQueue;
        private List<BindType> _typeList;

        public BindTypeCollection(BindType[] typeArr)
        {
            _typeQueue = new Queue<BindType>(typeArr);
        }

        public BindType[] CollectBindType(Filter<Type> baseFilter, Filter<Type> excludeFilter)
        {
            List<Type> processed = new List<Type>();
            excludeFilter = excludeFilter.Or(new GeneralFilter<Type>(processed));
            _typeList = new List<BindType>();

            baseFilter.Each(t => _typeQueue.Enqueue(new BindType(t)));
            while (_typeQueue.Count > 0)
            {
                var bind = _typeQueue.Dequeue();
                if (!excludeFilter.Contains(bind.type))
                {
                    _typeList.Add(bind);
                    processed.Add(bind.type);
                    CreateBaseBindType(bind.baseType, excludeFilter);
                }
            }
            return _typeList.ToArray();
        }

        void CreateBaseBindType(Type baseType, Filter<Type> excludeFilter)
        {
            if (baseType != null && !excludeFilter.Contains(baseType))
            {
                var bind = new BindType(baseType);
                _typeQueue.Enqueue(bind);
                CreateBaseBindType(bind.baseType, excludeFilter);
            }
        }

        public override bool Contains(BindType type)
        {
            return false;
        }

        public override void Each(EachProcessor processor)
        {
            foreach (var bindType in _typeList)
            {
                processor(bindType);
            }
        }
    }

    class OpMethodFilter : Filter<MethodInfo>
    {
        public override bool Contains(MethodInfo mi)
        {
            return mi.Name.StartsWith("Op_") || mi.Name.StartsWith("add_") || mi.Name.StartsWith("remove_");
        }
    }

    /// <summary>
    /// Get/Set 方法过滤
    /// </summary>
    class GetSetMethodFilter : Filter<MethodInfo>
    {
        public override bool Contains(MethodInfo type)
        {
            return type.Name.StartsWith("get_") || type.Name.StartsWith("set_");
        }
    }

    /// <summary>
    /// 废弃过滤
    /// </summary>
    /// <typeparam name="T"></typeparam>
    class ObsoleteFilter<T> : Filter<T> where T : MemberInfo
    {
        public override bool Contains(T mb)
        {
            object[] attrs = mb.GetCustomAttributes(true);

            for (int j = 0; j < attrs.Length; j++)
            {
                Type t = attrs[j].GetType();

                if (t == typeof(ObsoleteAttribute) ||
                    t == typeof(NoToLuaAttribute) ||
                    t == typeof(MonoPInvokeCallbackAttribute) ||
                    t.Name == "MonoNotSupportedAttribute" ||
                    t.Name == "MonoTODOAttribute")
                {
                    return true;
                }
            }
            return false;
        }
    }

    /// <summary>
    /// 黑名单过滤
    /// </summary>
    /// <typeparam name="T"></typeparam>
    class BlackListMemberNameFilter<T> : Filter<T> where T : MemberInfo
    {
        public override bool Contains(T mi)
        {
            if (ToLuaExport.memberFilter.Contains(mi.Name))
                return true;
            var type = mi.ReflectedType;
            if (type != null)
                return ToLuaExport.memberFilter.Contains(type.Name + "." + mi.Name);
            return false;
        }
    }

    /// <summary>
    /// 泛型方法过滤
    /// </summary>
    class GenericMethodFilter : Filter<MethodInfo>
    {
        public override bool Contains(MethodInfo mi)
        {
            return mi.IsGenericMethod;
        }
    }

    /// <summary>
    /// 扩展方法过滤
    /// </summary>
    class ExtendMethodFilter : Filter<MethodInfo>
    {
        private readonly Type _type;

        public ExtendMethodFilter(Type type)
        {
            _type = type;
        }

        public override bool Contains(MethodInfo mi)
        {
            ParameterInfo[] infos = mi.GetParameters();
            if (infos.Length == 0)
                return false;

            var pi = infos[0];
            return pi.ParameterType == _type;
        }
    }

    class MethodData
    {
        public bool IsExtend;
        public MethodInfo Method;
    }

    class MethodDataSet
    {
        public List<MethodData> MethodList = new List<MethodData>();

        public void Add(MethodInfo mi, bool isExtend)
        {
            MethodData md = new MethodData { IsExtend = isExtend, Method = mi };
            MethodList.Add(md);
        }
    }

    abstract class CodeGenerator
    {
        readonly Filter<MethodInfo> methodExcludeFilter = new ObsoleteFilter<MethodInfo>()
            .Or(new OpMethodFilter())
            .Or(new BlackListMemberNameFilter<MethodInfo>())
            .Or(new GenericMethodFilter())
            .Or(new GetSetMethodFilter());

        protected BindType _bindType;

        public virtual void Gen(BindType bt)
        {
            _bindType = bt;

            GenMethods();
            GenProperties();
        }

        protected void GenMethods()
        {
            var flags = BindingFlags.Public | BindingFlags.Static | BindingFlags.IgnoreCase | BindingFlags.Instance |
                        BindingFlags.DeclaredOnly;
            Dictionary<string, MethodDataSet> allMethods = new Dictionary<string, MethodDataSet>();
            Action<MethodInfo, bool> methodCollector = (mi, isExtend) =>
            {
                MethodDataSet set;
                if (allMethods.TryGetValue(mi.Name, out set))
                {
                    set.Add(mi, isExtend);
                }
                else
                {
                    set = new MethodDataSet();
                    set.Add(mi, isExtend);
                    allMethods.Add(mi.Name, set);
                }
            };

            //extend
            if (_bindType.extendList != null)
            {
                foreach (var type in _bindType.extendList)
                {
                    MethodInfo[] methodInfos = type.GetMethods(flags);
                    var extFilter = new GeneralFilter<MethodInfo>(methodInfos)
                        .Exclude(methodExcludeFilter)
                        .And(new ExtendMethodFilter(_bindType.type));
                    extFilter.Each(mi =>
                    {
                        methodCollector(mi, true);
                    });
                }
            }

            //base
            var methods = _bindType.type.GetMethods(flags);
            var filter = new GeneralFilter<MethodInfo>(methods);
            var methodFilter = filter.Exclude(methodExcludeFilter);
            methodFilter.Each(mi =>
            {
                methodCollector(mi, false);
            });

            foreach (var pair in allMethods)
            {
                GenMethod(pair.Key, pair.Value);
            }
        }

        protected void GenProperties()
        {
            Type type = _bindType.type;
            //props
            var propList = type.GetProperties(BindingFlags.GetProperty | BindingFlags.SetProperty |
                           BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase |
                           BindingFlags.DeclaredOnly | BindingFlags.Static);
            var propFilter = new GeneralFilter<PropertyInfo>(propList)
                .Exclude(new BlackListMemberNameFilter<PropertyInfo>())
                .Exclude(new ObsoleteFilter<PropertyInfo>());
            propFilter.Each(GenProperty);

            //fields
            var fields = type.GetFields(BindingFlags.GetField | BindingFlags.SetField | BindingFlags.Instance |
                         BindingFlags.Public | BindingFlags.Static);
            var fieldFilter = new GeneralFilter<FieldInfo>(fields)
                .Exclude(new BlackListMemberNameFilter<FieldInfo>())
                .Exclude(new ObsoleteFilter<FieldInfo>());
            fieldFilter.Each(GenField);

            //events
            var events = type.GetEvents(BindingFlags.DeclaredOnly | BindingFlags.Instance | BindingFlags.Public |
                         BindingFlags.Static);
            var evtFilter = new GeneralFilter<EventInfo>(events)
                .Exclude(new BlackListMemberNameFilter<EventInfo>())
                .Exclude(new ObsoleteFilter<EventInfo>());
            evtFilter.Each(GenEvent);
        }

        protected abstract void GenProperty(PropertyInfo pi);

        protected abstract void GenEvent(EventInfo ei);

        protected abstract void GenField(FieldInfo fi);

        protected abstract void GenMethod(string name, MethodDataSet methodDataSet);
    }

    static class TypeExtension
    {
        public static string GetTypeStr(this Type type)
        {
            if (typeof(ICollection).IsAssignableFrom(type))
            {
                return "table";
            }
            if (type.IsGenericType)
            {
                var typeName = LuaMisc.GetTypeName(type);
                int pos = typeName.IndexOf("<", StringComparison.Ordinal);
                if (pos > 0)
                    return typeName.Substring(0, pos);
            }
            return LuaMisc.GetTypeName(type);
        }
    }

    class LuaAPIGenerator : CodeGenerator
    {
        private StringBuilder _baseSB;
        private StringBuilder _propBuilder;
        private StringBuilder _methodBuilder;

        public override void Gen(BindType bt)
        {
            _baseSB = new StringBuilder();
            if (bt.baseType != null)
                _baseSB.AppendFormat("---@class {0} : {1}\n", bt.name, bt.baseType.GetTypeStr());
            else
                _baseSB.AppendFormat("---@class {0}\n", bt.name);

            _propBuilder = new StringBuilder();
            _methodBuilder = new StringBuilder();
            base.Gen(bt);

            _baseSB.Append(_propBuilder);
            _baseSB.Append("local m = {}\n");
            _baseSB.Append(_methodBuilder);

            string[] ns = bt.name.Split('.');
            for (int i = 0; i < ns.Length - 1; i++)
            {
                _baseSB.AppendFormat("{0} = {{}}\n", string.Join(".", ns, 0, i + 1));
            }
            _baseSB.AppendFormat("{0} = m\n", bt.name);
            _baseSB.Append("return m");

            string filePath = "LuaAPI/" + bt.wrapName.Replace("_", "/") + ".lua";
            string dirPath = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(dirPath))
                Directory.CreateDirectory(dirPath);
            File.WriteAllBytes(filePath, Encoding.GetEncoding("UTF-8").GetBytes(_baseSB.ToString()));
        }

        protected override void GenProperty(PropertyInfo pi)
        {
            _propBuilder.AppendFormat("---@field {0} {1}\n", pi.Name, pi.PropertyType.GetTypeStr());
        }

        protected override void GenEvent(EventInfo ei)
        {
            //Debug.Log(ei);
        }

        protected override void GenField(FieldInfo fi)
        {
            _propBuilder.AppendFormat("---@field {0} {1}\n", fi.Name, fi.FieldType.GetTypeStr());
        }

        protected override void GenMethod(string name, MethodDataSet methodDataSet)
        {
            //overload
            if (methodDataSet.MethodList.Count > 1)
            {
                for (var j = 1; j < methodDataSet.MethodList.Count; j++)
                {
                    var data = methodDataSet.MethodList[j];
                    var mi = data.Method;
                    var parameters = mi.GetParameters();
                    int startIdx = data.IsExtend ? 1 : 0;
                    string[] paramNames = new string[parameters.Length - startIdx];
                    for (var i = startIdx; i < parameters.Length; i++)
                    {
                        var pi = parameters[i];
                        string piName = GetParamName(pi.Name);
                        paramNames[i - startIdx] = string.Format("{0}:{1}", piName, pi.ParameterType.GetTypeStr());
                    }
                    _methodBuilder.AppendFormat("---@overload fun({0}):{1}\n", string.Join(", ", paramNames), mi.ReturnType.GetTypeStr());
                }
            }
            //main
            {
                var data = methodDataSet.MethodList[0];
                var mi = data.Method;
                var parameters = mi.GetParameters();
                int startIdx = data.IsExtend ? 1 : 0;
                string[] paramNames = new string[parameters.Length - startIdx];
                for (var i = startIdx; i < parameters.Length; i++)
                {
                    var pi = parameters[i];
                    string piName = GetParamName(pi.Name);
                    _methodBuilder.AppendFormat("---@param {0} {1}\n", piName, pi.ParameterType.GetTypeStr());
                    paramNames[i - startIdx] = piName;
                }
                var returnType = mi.ReturnType;
                if (typeof(void) != returnType)
                {
                    _methodBuilder.AppendFormat("---@return {0}\n", returnType.GetTypeStr());
                }
                string c = mi.IsStatic && !data.IsExtend ? "." : ":";
                _methodBuilder.AppendFormat("function m{0}{1}({2}) end\n", c, mi.Name, string.Join(", ", paramNames));
            }
        }


        /// <summary>
        /// 获取 lua 中可用的参数名称，避免使用 lua 关键字
        /// </summary>
        /// <returns>The parameter name.</returns>
        /// <param name="name">Name.</param>
        private static string GetParamName(string name)
        {
            if (name == "end")
            {
                return "$" + name;
            }
            return name;
        }


        //
    }
}