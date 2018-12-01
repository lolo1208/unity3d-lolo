--
-- 双向链表
-- 2017/10/18
-- Author LOLO
--


--
---@class LinkedList @ 双向链表
---@field New fun():LinkedList
---
---@field protected _list table<any, LinkedListNode> @ 数据列表
---@field protected _head LinkedListNode @ 表头节点
---@field protected _tail LinkedListNode @ 表尾节点
---@field protected _count number @ 节点总数
local LinkedList = class("LinkedList")


--
--- 构造函数
function LinkedList:Ctor()
    self._list = {}
    self._count = 0
end


--
--- 根据键值创建节点，并将该节点添加到表头
---@param value any
---@param key any
---@return LinkedListNode @ 新创建的节点
function LinkedList:Unshift(value, key)
    local node = { key = key, value = value, prev = nil, next = self._head } ---@type LinkedListNode
    if self._tail == nil then
        self._tail = node
    else
        self._head.prev = node
    end
    self._head = node
    self._list[key] = node
    self._count = self._count + 1
    return node
end


--
--- 根据键值创建节点，并将该节点添加到表尾
---@param value any
---@param key any
---@return LinkedListNode @ 新创建的节点
function LinkedList:Push(value, key)
    local node = { key = key, value = value, prev = self._tail, next = nil } ---@type LinkedListNode
    if self._head == nil then
        self._head = node
    else
        self._tail.next = node
    end
    self._tail = node
    self._list[key] = node
    self._count = self._count + 1
    return node
end


--
--- 将 key 对应的节点移动到表头
---@param key any
---@return void
function LinkedList:MoveToHead(key)
    local node = self._list[key]
    if node == nil or node == self._head then
        return
    end

    if node.prev ~= nil then
        node.prev.next = node.next
    end
    if node.next ~= nil then
        node.next.prev = node.prev
    end

    if node == self._tail then
        self._tail = node.prev
    end

    node.prev = nil
    node.next = self._head

    if self._head ~= nil then
        self._head.prev = node
    end
    self._head = node
end


--
--- 将 key 对应的节点移动到表尾
---@param key any
---@return void
function LinkedList:MoveToTail(key)
    local node = self._list[key]
    if node == nil or node == self._tail then
        return
    end

    if node.prev ~= nil then
        node.prev.next = node.next
    end
    if node.next ~= nil then
        node.next.prev = node.prev
    end

    if node == self._head then
        self._head = node.next
    end

    node.next = nil
    node.prev = self._tail

    if self._tail ~= nil then
        self._tail.next = node
    end
    self._tail = node
end


--
--- 在 prevKey 对应的节点之后插入新的节点
---@param prevKey any
---@param key any
---@param value any
---@return LinkedListNode @ 新创建的节点
function LinkedList:InsertAfter(prevKey, key, value)
    local prev = self._list[prevKey]
    if prev == nil then
        return nil
    end

    local node = { key = key, value = value, prev = prev, next = prev.next } ---@type LinkedListNode
    prev.next = node
    self._count = self._count + 1
    return node
end


--
--- 在 nextKey 对应的节点之前插入新的节点
---@param nextKey any
---@param key any
---@param value any
---@return LinkedListNode @ 新创建的节点
function LinkedList:InsertBefore(nextKey, key, value)
    local next = self._list[nextKey]
    if next == nil then
        return nil
    end

    local node = { key = key, value = value, prev = next.prev, next = next } ---@type LinkedListNode
    next.prev = node
    self._count = self._count + 1
    return node
end


--
--- 移除 key 对应的节点
---@param key any
---@return LinkedListNode @ 已被移除的节点
function LinkedList:Remove(key)
    local node = self._list[key]
    if node == nil then
        return nil
    end

    if node.prev ~= nil then
        node.prev.next = node.next
    end
    if node.next ~= nil then
        node.next.prev = node.prev
    end
    self._list[key] = nil

    if node == self._head then
        self._head = node.next
    end
    if node == self._tail then
        self._tail = node.prev
    end

    self._count = self._count - 1
    return node
end


--
--- 获取 key 对应的节点
---@param key any
---@return LinkedListNode
function LinkedList:GetNode(key)
    return self._list[key]
end


--
--- 获取 key 对应的 value
---@param key any
---@return any
function LinkedList:GetValue(key)
    local node = self._list[key]
    if node ~= nil then
        return node.value
    end
    return nil
end


--
--- 获取第一个节点（表头）
---@return LinkedListNode
function LinkedList:GetHead()
    return self._head
end


--
--- 获取最后一个节点（表尾）
---@return LinkedListNode
function LinkedList:GetTail()
    return self._tail
end


--
--- 获取节点总数（链表长度）
---@return number
function LinkedList:GetCount()
    return self._count
end


--
--- 链表中是否包含 key 对应的节点
---@param key any
---@return boolean
function LinkedList:Contains(key)
    return self._list[key] ~= nil
end


--
--- 是否为空链表，链表中是否没有数据
---@return boolean
function LinkedList:IsEmpty()
    return self._head == nil
end


--
--- 清空链表
---@return void
function LinkedList:Clean()
    self._list = {}
    self._head = nil
    self._tail = nil
    self._count = 0
end



--
return LinkedList




--
---@class LinkedListNode @ 双向链表的节点
---@field key any @ 该节点的key
---@field value any @ 该节点的值
---@field prev LinkedListNode @ 上一个节点。表头节点的上一个节点始终为 nil
---@field next LinkedListNode @ 下一个节点。表尾节点的下一个节点始终为 nil
