---@class UnityEngine.Texture2D : UnityEngine.Texture
---@field mipmapCount int
---@field format UnityEngine.TextureFormat
---@field whiteTexture UnityEngine.Texture2D
---@field blackTexture UnityEngine.Texture2D
local m = {}
---@param width int
---@param height int
---@param format UnityEngine.TextureFormat
---@param mipmap bool
---@param linear bool
---@param nativeTex System.IntPtr
---@return UnityEngine.Texture2D
function m.CreateExternalTexture(width, height, format, mipmap, linear, nativeTex) end
---@param nativeTex System.IntPtr
function m:UpdateExternalTexture(nativeTex) end
---@param x int
---@param y int
---@param color UnityEngine.Color
function m:SetPixel(x, y, color) end
---@param x int
---@param y int
---@return UnityEngine.Color
function m:GetPixel(x, y) end
---@param u float
---@param v float
---@return UnityEngine.Color
function m:GetPixelBilinear(u, v) end
---@overload fun(colors:table, miplevel:int):void
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int, colors:table, miplevel:int):void
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int, colors:table):void
---@param colors table
function m:SetPixels(colors) end
---@overload fun(colors:table, miplevel:int):void
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int, colors:table):void
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int, colors:table, miplevel:int):void
---@param colors table
function m:SetPixels32(colors) end
---@overload fun(data:System.IntPtr, size:int):void
---@param data table
function m:LoadRawTextureData(data) end
---@return table
function m:GetRawTextureData() end
---@overload fun(miplevel:int):table
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int, miplevel:int):table
---@overload fun(x:int, y:int, blockWidth:int, blockHeight:int):table
---@return table
function m:GetPixels() end
---@overload fun():table
---@param miplevel int
---@return table
function m:GetPixels32(miplevel) end
---@overload fun(updateMipmaps:bool):void
---@overload fun():void
---@param updateMipmaps bool
---@param makeNoLongerReadable bool
function m:Apply(updateMipmaps, makeNoLongerReadable) end
---@overload fun(width:int, height:int):bool
---@param width int
---@param height int
---@param format UnityEngine.TextureFormat
---@param hasMipMap bool
---@return bool
function m:Resize(width, height, format, hasMipMap) end
---@param highQuality bool
function m:Compress(highQuality) end
---@overload fun(textures:table, padding:int, maximumAtlasSize:int):table
---@overload fun(textures:table, padding:int):table
---@param textures table
---@param padding int
---@param maximumAtlasSize int
---@param makeNoLongerReadable bool
---@return table
function m:PackTextures(textures, padding, maximumAtlasSize, makeNoLongerReadable) end
---@param sizes table
---@param padding int
---@param atlasSize int
---@param results table
---@return bool
function m.GenerateAtlas(sizes, padding, atlasSize, results) end
---@overload fun(source:UnityEngine.Rect, destX:int, destY:int):void
---@param source UnityEngine.Rect
---@param destX int
---@param destY int
---@param recalculateMipMaps bool
function m:ReadPixels(source, destX, destY, recalculateMipMaps) end
UnityEngine = {}
UnityEngine.Texture2D = m
return m