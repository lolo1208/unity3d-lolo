---@class System.Type : System.Reflection.MemberInfo
---@field Assembly System.Reflection.Assembly
---@field AssemblyQualifiedName string
---@field Attributes System.Reflection.TypeAttributes
---@field BaseType System.Type
---@field DeclaringType System.Type
---@field DefaultBinder System.Reflection.Binder
---@field FullName string
---@field GUID System.Guid
---@field HasElementType bool
---@field IsAbstract bool
---@field IsAnsiClass bool
---@field IsArray bool
---@field IsAutoClass bool
---@field IsAutoLayout bool
---@field IsByRef bool
---@field IsClass bool
---@field IsCOMObject bool
---@field IsContextful bool
---@field IsEnum bool
---@field IsExplicitLayout bool
---@field IsImport bool
---@field IsInterface bool
---@field IsLayoutSequential bool
---@field IsMarshalByRef bool
---@field IsNestedAssembly bool
---@field IsNestedFamANDAssem bool
---@field IsNestedFamily bool
---@field IsNestedFamORAssem bool
---@field IsNestedPrivate bool
---@field IsNestedPublic bool
---@field IsNotPublic bool
---@field IsPointer bool
---@field IsPrimitive bool
---@field IsPublic bool
---@field IsSealed bool
---@field IsSerializable bool
---@field IsSpecialName bool
---@field IsUnicodeClass bool
---@field IsValueType bool
---@field MemberType System.Reflection.MemberTypes
---@field Module System.Reflection.Module
---@field Namespace string
---@field ReflectedType System.Type
---@field TypeHandle System.RuntimeTypeHandle
---@field TypeInitializer System.Reflection.ConstructorInfo
---@field UnderlyingSystemType System.Type
---@field ContainsGenericParameters bool
---@field IsGenericTypeDefinition bool
---@field IsGenericType bool
---@field IsGenericParameter bool
---@field IsNested bool
---@field IsVisible bool
---@field GenericParameterPosition int
---@field GenericParameterAttributes System.Reflection.GenericParameterAttributes
---@field DeclaringMethod System.Reflection.MethodBase
---@field StructLayoutAttribute System.Runtime.InteropServices.StructLayoutAttribute
---@field Delimiter char
---@field EmptyTypes table
---@field FilterAttribute System.Reflection.MemberFilter
---@field FilterName System.Reflection.MemberFilter
---@field FilterNameIgnoreCase System.Reflection.MemberFilter
---@field Missing object
local m = {}
---@overload fun(o:System.Type):bool
---@param o object
---@return bool
function m:Equals(o) end
---@overload fun(typeName:string, throwOnError:bool):System.Type
---@overload fun(typeName:string, throwOnError:bool, ignoreCase:bool):System.Type
---@overload fun():System.Type
---@param typeName string
---@return System.Type
function m.GetType(typeName) end
---@param args table
---@return table
function m.GetTypeArray(args) end
---@param type System.Type
---@return System.TypeCode
function m.GetTypeCode(type) end
---@param handle System.RuntimeTypeHandle
---@return System.Type
function m.GetTypeFromHandle(handle) end
---@param o object
---@return System.RuntimeTypeHandle
function m.GetTypeHandle(o) end
---@param c System.Type
---@return bool
function m:IsSubclassOf(c) end
---@param filter System.Reflection.TypeFilter
---@param filterCriteria object
---@return table
function m:FindInterfaces(filter, filterCriteria) end
---@overload fun(name:string, ignoreCase:bool):System.Type
---@param name string
---@return System.Type
function m:GetInterface(name) end
---@param interfaceType System.Type
---@return System.Reflection.InterfaceMapping
function m:GetInterfaceMap(interfaceType) end
---@return table
function m:GetInterfaces() end
---@param c System.Type
---@return bool
function m:IsAssignableFrom(c) end
---@param o object
---@return bool
function m:IsInstanceOfType(o) end
---@return int
function m:GetArrayRank() end
---@return System.Type
function m:GetElementType() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):System.Reflection.EventInfo
---@param name string
---@return System.Reflection.EventInfo
function m:GetEvent(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetEvents() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):System.Reflection.FieldInfo
---@param name string
---@return System.Reflection.FieldInfo
function m:GetField(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetFields() end
---@return int
function m:GetHashCode() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):table
---@overload fun(name:string, type:System.Reflection.MemberTypes, bindingAttr:System.Reflection.BindingFlags):table
---@param name string
---@return table
function m:GetMember(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetMembers() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):System.Reflection.MethodInfo
---@overload fun(name:string, types:table):System.Reflection.MethodInfo
---@overload fun(name:string, types:table, modifiers:table):System.Reflection.MethodInfo
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, types:table, modifiers:table):System.Reflection.MethodInfo
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, callConvention:System.Reflection.CallingConventions, types:table, modifiers:table):System.Reflection.MethodInfo
---@param name string
---@return System.Reflection.MethodInfo
function m:GetMethod(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetMethods() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):System.Type
---@param name string
---@return System.Type
function m:GetNestedType(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetNestedTypes() end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetProperties() end
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags):System.Reflection.PropertyInfo
---@overload fun(name:string, returnType:System.Type):System.Reflection.PropertyInfo
---@overload fun(name:string, types:table):System.Reflection.PropertyInfo
---@overload fun(name:string, returnType:System.Type, types:table):System.Reflection.PropertyInfo
---@overload fun(name:string, returnType:System.Type, types:table, modifiers:table):System.Reflection.PropertyInfo
---@overload fun(name:string, bindingAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, returnType:System.Type, types:table, modifiers:table):System.Reflection.PropertyInfo
---@param name string
---@return System.Reflection.PropertyInfo
function m:GetProperty(name) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, types:table, modifiers:table):System.Reflection.ConstructorInfo
---@overload fun(bindingAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, callConvention:System.Reflection.CallingConventions, types:table, modifiers:table):System.Reflection.ConstructorInfo
---@param types table
---@return System.Reflection.ConstructorInfo
function m:GetConstructor(types) end
---@overload fun(bindingAttr:System.Reflection.BindingFlags):table
---@return table
function m:GetConstructors() end
---@return table
function m:GetDefaultMembers() end
---@param memberType System.Reflection.MemberTypes
---@param bindingAttr System.Reflection.BindingFlags
---@param filter System.Reflection.MemberFilter
---@param filterCriteria object
---@return table
function m:FindMembers(memberType, bindingAttr, filter, filterCriteria) end
---@overload fun(name:string, invokeAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, target:object, args:table, culture:System.Globalization.CultureInfo):object
---@overload fun(name:string, invokeAttr:System.Reflection.BindingFlags, binder:System.Reflection.Binder, target:object, args:table, modifiers:table, culture:System.Globalization.CultureInfo, namedParameters:table):object
---@param name string
---@param invokeAttr System.Reflection.BindingFlags
---@param binder System.Reflection.Binder
---@param target object
---@param args table
---@return object
function m:InvokeMember(name, invokeAttr, binder, target, args) end
---@return string
function m:ToString() end
---@return table
function m:GetGenericArguments() end
---@return System.Type
function m:GetGenericTypeDefinition() end
---@param typeArguments table
---@return System.Type
function m:MakeGenericType(typeArguments) end
---@return table
function m:GetGenericParameterConstraints() end
---@overload fun(rank:int):System.Type
---@return System.Type
function m:MakeArrayType() end
---@return System.Type
function m:MakeByRefType() end
---@return System.Type
function m:MakePointerType() end
---@param typeName string
---@param throwIfNotFound bool
---@param ignoreCase bool
---@return System.Type
function m.ReflectionOnlyGetType(typeName, throwIfNotFound, ignoreCase) end
System = {}
System.Type = m
return m