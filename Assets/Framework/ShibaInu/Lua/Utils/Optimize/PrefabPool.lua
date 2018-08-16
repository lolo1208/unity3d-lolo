--
-- Prefab 缓存池
-- 2018/8/6
-- Author LOLO
--

local remove = table.remove


--
---@class PrefabPool
local PrefabPool = {}

local _pool = {}
local _transform ---@type UnityEngine.Transform



--
--- 获取一个 prefab 的实例
---@param prefabPath string @ prefab 路径
---@param optional parent string | UnityEngine.Transform @ 图层名称 或 父节点(Transform)
---@return UnityEngine.GameObject
function PrefabPool.Get(prefabPath, parent)
    local pool = _pool[prefabPath]
    if pool == nil then
        pool = {}
        _pool[prefabPath] = pool
    end

    if #pool > 0 then
        local go = remove(pool)
        if parent ~= nil then
            SetParent(go.transform, parent)
        end
        return go
    else
        return Instantiate(prefabPath, parent)
    end
end


--
--- 将 prefab 的实例（GameObject 对象）回收到缓存池中
---@param go UnityEngine.GameObject
---@param prefabPath string @ prefab 路径
function PrefabPool.Recycle(go, prefabPath)
    local pool = _pool[prefabPath]
    if pool == nil then
        pool = {}
        _pool[prefabPath] = pool
    end
    pool[#pool + 1] = go

    if _transform == nil then
        local poolGO = GameObject.New("PrefabPool")
        poolGO:SetActive(false)
        _transform = poolGO.transform
    end
    go.transform:SetParent(_transform)
end


--
--- 清空缓存池。切换到新场景时，会自动调用
function PrefabPool.Clean()
    _pool = {}
    _transform = nil
end




--
return PrefabPool