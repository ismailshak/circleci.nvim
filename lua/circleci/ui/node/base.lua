---@class circleci.Node
---@field children circleci.Node[]
---@field depth integer
---@field id string
---@field is_expanded boolean
---@field parent circleci.Node|nil
local Node = {}

---@return circleci.Node
function Node:new()
  local instance = {}
  setmetatable(instance, { __index = self })

  instance.parent = nil
  instance.children = {}

  instance.depth = 0
  instance.is_expanded = false

  return instance
end

---@param node circleci.Node
function Node:append_child(node)
  node.parent = self
  node.depth = self.depth + 1
  table.insert(self.children, node)
end

---@param config circleci.Config.UI
---@return string
function Node:get_chevron(config)
  return (self.is_expanded and config.icons.expanded) or config.icons.collapsed or ""
end

---Returns the indentation for the node given its depth in the tree
---@return string
function Node:indent()
  if self.depth == 0 then
    return ""
  end

  return (" "):rep(self.depth)
end

---@param config circleci.Config.UI
---@return string|string[]
---@diagnostic disable-next-line: unused-local
function Node:render(config)
  assert(false, "'render' must be implemented in child 'BaseNode'")
  return ""
end

return Node
