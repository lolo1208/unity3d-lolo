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
local _container ---@type UnityEngine.Transform



--
--- 获取一个 prefab 的实例
---@param prefabPath string @ prefab 路径
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
---@return UnityEngine.GameObject
function PrefabPool.Get(prefabPath, parent)
    local pool = _pool[prefabPath]
    if pool == nil then
        pool = {}
        _pool[prefabPath] = pool
    end

    if #pool > 0 then
        local go = remove(pool)
        if isnull(go) then
            return PrefabPool.Get(prefabPath, parent)
        end
        SetParent(go.transform, parent)
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
    local poolCount
    if pool == nil then
        pool = {}
        _pool[prefabPath] = pool
        poolCount = 0
    else
        poolCount = #pool
        if poolCount > 150 then
            if isEditor then
                logWarningCount(Constants.W1003, 20)
            end
            Destroy(go)
            return
        end
    end

    if isnull(go) or _container == nil then
        return
    end
    go.transform:SetParent(_container, false)
    pool[poolCount + 1] = go
end


--
--- 清空缓存池。切换到新场景时，会自动调用
---@field createGO boolean @ -可选- 是否创建 [PrefabPool] 节点，默认：false
function PrefabPool.Clean(createGO)
    if createGO then
        local go = GameObject.New("[PrefabPool]")
        go:SetActive(false)
        _container = go.transform
    else
        _container = nil
    end
    _pool = {}
end




--
return PrefabPool