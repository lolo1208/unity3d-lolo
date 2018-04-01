---@class UnityEngine.Font : UnityEngine.Object
---@field material UnityEngine.Material
---@field fontNames table
---@field characterInfo table
---@field dynamic bool
---@field ascent int
---@field lineHeight int
---@field fontSize int
local m = {}
---@return table
function m.GetOSInstalledFontNames() end
---@overload fun(fontnames:table, size:int):UnityEngine.Font
---@param fontname string
---@param size int
---@return UnityEngine.Font
function m.CreateDynamicFontFromOSFont(fontname, size) end
---@param c char
---@return bool
function m:HasCharacter(c) end
---@overload fun(characters:string, size:int):void
---@overload fun(characters:string):void
---@param characters string
---@param size int
---@param style UnityEngine.FontStyle
function m:RequestCharactersInTexture(characters, size, style) end
---@param str string
---@return int
function m.GetMaxVertsForString(str) end
---@overload fun(ch:char, info:UnityEngine.CharacterInfo, size:int):bool
---@overload fun(ch:char, info:UnityEngine.CharacterInfo):bool
---@param ch char
---@param info UnityEngine.CharacterInfo
---@param size int
---@param style UnityEngine.FontStyle
---@return bool
function m:GetCharacterInfo(ch, info, size, style) end
UnityEngine = {}
UnityEngine.Font = m
return m