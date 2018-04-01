---@class System.String : object
---@field Length int
---@field Empty string
local m = {}
---@overload fun(obj:object):bool
---@overload fun(value:string):bool
---@overload fun(a:string, b:string, comparisonType:System.StringComparison):bool
---@overload fun(value:string, comparisonType:System.StringComparison):bool
---@param a string
---@param b string
---@return bool
function m.Equals(a, b) end
---@return object
function m:Clone() end
---@return System.TypeCode
function m:GetTypeCode() end
---@param sourceIndex int
---@param destination table
---@param destinationIndex int
---@param count int
function m:CopyTo(sourceIndex, destination, destinationIndex, count) end
---@overload fun(startIndex:int, length:int):table
---@return table
function m:ToCharArray() end
---@overload fun(separator:table, count:int):table
---@overload fun(separator:table, count:int, options:System.StringSplitOptions):table
---@overload fun(separator:table, count:int, options:System.StringSplitOptions):table
---@overload fun(separator:table, options:System.StringSplitOptions):table
---@overload fun(separator:table, options:System.StringSplitOptions):table
---@param separator table
---@return table
function m:Split(separator) end
---@overload fun(startIndex:int, length:int):string
---@param startIndex int
---@return string
function m:Substring(startIndex) end
---@overload fun(trimChars:table):string
---@return string
function m:Trim() end
---@param trimChars table
---@return string
function m:TrimStart(trimChars) end
---@param trimChars table
---@return string
function m:TrimEnd(trimChars) end
---@overload fun(strA:string, strB:string, ignoreCase:bool):int
---@overload fun(strA:string, strB:string, ignoreCase:bool, culture:System.Globalization.CultureInfo):int
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int):int
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int, ignoreCase:bool):int
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int, ignoreCase:bool, culture:System.Globalization.CultureInfo):int
---@overload fun(strA:string, strB:string, comparisonType:System.StringComparison):int
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int, comparisonType:System.StringComparison):int
---@overload fun(strA:string, strB:string, culture:System.Globalization.CultureInfo, options:System.Globalization.CompareOptions):int
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int, culture:System.Globalization.CultureInfo, options:System.Globalization.CompareOptions):int
---@param strA string
---@param strB string
---@return int
function m.Compare(strA, strB) end
---@overload fun(strB:string):int
---@param value object
---@return int
function m:CompareTo(value) end
---@overload fun(strA:string, indexA:int, strB:string, indexB:int, length:int):int
---@param strA string
---@param strB string
---@return int
function m.CompareOrdinal(strA, strB) end
---@overload fun(value:string, ignoreCase:bool, culture:System.Globalization.CultureInfo):bool
---@overload fun(value:string, comparisonType:System.StringComparison):bool
---@param value string
---@return bool
function m:EndsWith(value) end
---@overload fun(anyOf:table, startIndex:int):int
---@overload fun(anyOf:table, startIndex:int, count:int):int
---@param anyOf table
---@return int
function m:IndexOfAny(anyOf) end
---@overload fun(value:string, startIndex:int, comparisonType:System.StringComparison):int
---@overload fun(value:string, startIndex:int, count:int, comparisonType:System.StringComparison):int
---@overload fun(value:char):int
---@overload fun(value:char, startIndex:int):int
---@overload fun(value:char, startIndex:int, count:int):int
---@overload fun(value:string):int
---@overload fun(value:string, startIndex:int):int
---@overload fun(value:string, startIndex:int, count:int):int
---@param value string
---@param comparisonType System.StringComparison
---@return int
function m:IndexOf(value, comparisonType) end
---@overload fun(value:string, startIndex:int, comparisonType:System.StringComparison):int
---@overload fun(value:string, startIndex:int, count:int, comparisonType:System.StringComparison):int
---@overload fun(value:char):int
---@overload fun(value:char, startIndex:int):int
---@overload fun(value:char, startIndex:int, count:int):int
---@overload fun(value:string):int
---@overload fun(value:string, startIndex:int):int
---@overload fun(value:string, startIndex:int, count:int):int
---@param value string
---@param comparisonType System.StringComparison
---@return int
function m:LastIndexOf(value, comparisonType) end
---@overload fun(anyOf:table, startIndex:int):int
---@overload fun(anyOf:table, startIndex:int, count:int):int
---@param anyOf table
---@return int
function m:LastIndexOfAny(anyOf) end
---@param value string
---@return bool
function m:Contains(value) end
---@param value string
---@return bool
function m.IsNullOrEmpty(value) end
---@overload fun(normalizationForm:System.Text.NormalizationForm):string
---@return string
function m:Normalize() end
---@overload fun(normalizationForm:System.Text.NormalizationForm):bool
---@return bool
function m:IsNormalized() end
---@overload fun(startIndex:int, count:int):string
---@param startIndex int
---@return string
function m:Remove(startIndex) end
---@overload fun(totalWidth:int, paddingChar:char):string
---@param totalWidth int
---@return string
function m:PadLeft(totalWidth) end
---@overload fun(totalWidth:int, paddingChar:char):string
---@param totalWidth int
---@return string
function m:PadRight(totalWidth) end
---@overload fun(value:string, comparisonType:System.StringComparison):bool
---@overload fun(value:string, ignoreCase:bool, culture:System.Globalization.CultureInfo):bool
---@param value string
---@return bool
function m:StartsWith(value) end
---@overload fun(oldValue:string, newValue:string):string
---@param oldChar char
---@param newChar char
---@return string
function m:Replace(oldChar, newChar) end
---@overload fun(culture:System.Globalization.CultureInfo):string
---@return string
function m:ToLower() end
---@return string
function m:ToLowerInvariant() end
---@overload fun(culture:System.Globalization.CultureInfo):string
---@return string
function m:ToUpper() end
---@return string
function m:ToUpperInvariant() end
---@overload fun(provider:System.IFormatProvider):string
---@return string
function m:ToString() end
---@overload fun(format:string, arg0:object, arg1:object):string
---@overload fun(format:string, arg0:object, arg1:object, arg2:object):string
---@overload fun(format:string, args:table):string
---@overload fun(provider:System.IFormatProvider, format:string, args:table):string
---@param format string
---@param arg0 object
---@return string
function m.Format(format, arg0) end
---@param str string
---@return string
function m.Copy(str) end
---@overload fun(arg0:object, arg1:object):string
---@overload fun(arg0:object, arg1:object, arg2:object):string
---@overload fun(arg0:object, arg1:object, arg2:object, arg3:object):string
---@overload fun(str0:string, str1:string):string
---@overload fun(str0:string, str1:string, str2:string):string
---@overload fun(str0:string, str1:string, str2:string, str3:string):string
---@overload fun(args:table):string
---@overload fun(values:table):string
---@param arg0 object
---@return string
function m.Concat(arg0) end
---@param startIndex int
---@param value string
---@return string
function m:Insert(startIndex, value) end
---@param str string
---@return string
function m.Intern(str) end
---@param str string
---@return string
function m.IsInterned(str) end
---@overload fun(separator:string, value:table, startIndex:int, count:int):string
---@param separator string
---@param value table
---@return string
function m.Join(separator, value) end
---@return System.CharEnumerator
function m:GetEnumerator() end
---@return int
function m:GetHashCode() end
---@param a string
---@param b string
---@return bool
function m.op_Equality(a, b) end
---@param a string
---@param b string
---@return bool
function m.op_Inequality(a, b) end
System = {}
System.String = m
return m