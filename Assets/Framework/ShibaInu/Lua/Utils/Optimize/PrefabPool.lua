--
-- Prefab 缓存池
-- 2018/8/6
-- Author LOLO
--

local pairs = pairs
local remove = table.remove
local ceil = math.ceil
local TimeUtil = TimeUtil


--
---@class PrefabPool
local PrefabPool = {}

local _pool = {}
---@type UnityEngine.Transform
local _container
---@type Timer
local _clearTimer

---@type number 缓存的有效时间（秒）
PrefabPool.cacheExpireTime = 60 * 10


--
--- 获取一个 prefab 的实例
---@param prefabPath string @ prefab 路径
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
---@return UnityEngine.GameObject
function PrefabPool.Get(prefabPath, parent)
    local pool = _pool[prefabPath]
    -- 更新缓存命中时间
    if pool then
        pool[1] = TimeUtil.totalDeltaTime
    end

    -- 没有池，或池里没对象，创建新实例并返回
    if pool == nil or #pool < 2 then
        return Instantiate(prefabPath, parent)
    end

    -- 返回池里的实例
    local go = remove(pool)
    if isnull(go) then
        return PrefabPool.Get(prefabPath, parent)
    end
    SetParent(go.transform, parent)
    return go
end


--
--- 将 prefab 的实例（GameObject 对象）回收到缓存池中
---@param go UnityEngine.GameObject
---@param prefabPath string @ prefab 路径
function PrefabPool.Recycle(go, prefabPath)
    if isnull(go) then
        return
    end
    if _container == nil then
        Destroy(go)
        return
    end

    local pool = _pool[prefabPath]
    if pool == nil then
        pool = { TimeUtil.totalDeltaTime }
        _pool[prefabPath] = pool
    end

    go.transform:SetParent(_container, false)
    pool[#pool + 1] = go
end


--
--- 清空缓存池。切换到新场景时，会自动调用
function PrefabPool.Clean()
    if not isnull(_container) then
        Destroy(_container.gameObject)
    end

    local go = GameObject.New("[PrefabPool]")
    go:SetActive(false)
    _container = go.transform
    _pool = {}

    if _clearTimer == nil then
        _clearTimer = Timer.New(60 * 2, NewHandler(PrefabPool.ClearUnused))
        _clearTimer:Start()
    end
end


--
--- （定时）清空长时间未使用的实例
function PrefabPool.ClearUnused()
    local time = TimeUtil.totalDeltaTime
    local removeList
    for path, pool in pairs(_pool) do
        if time - pool[1] > PrefabPool.cacheExpireTime then
            local count = ceil((#pool - 1) / 3) -- 每次清理 1/3
            if count == 0 then
                if removeList == nil then
                    removeList = {}
                end
                removeList[#removeList + 1] = path
            else
                for i = 1, count do
                    Destroy(remove(pool))
                end
            end
        end
    end

    if removeList then
        for i = 1, #removeList do
            _pool[removeList[i]] = nil
        end
    end
end



--
return PrefabPool