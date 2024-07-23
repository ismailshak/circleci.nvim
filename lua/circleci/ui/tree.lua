---@class circleci.Tree
---@field _root circleci.Node
local Tree = {}

function Tree:new()
  setmetatable({}, { __index = self })

  self._root = self:_make_root()

  return self
end

---@return boolean
function Tree:is_empty()
  return #self._root.children == 0
end

---Appends a node to the root of the tree
---@param node circleci.Node
function Tree:append_node(node)
  self:append_child(self._root, node)
end

---Appends a node to a given parent node's children
---@param parent circleci.Node
---@param node circleci.Node
function Tree:append_child(parent, node)
  parent:append_child(node)
end

---Appends a list of nodes to the provided parent's children
---@param parent circleci.Node
---@param nodes circleci.Node[]
function Tree:append_children(parent, nodes)
  for _, node in ipairs(nodes) do
    parent:append_child(node)
  end
end

---@param on_visit fun(node: circleci.Node)
---@param start? circleci.Node
function Tree:walk(on_visit, start)
  local current = start or self._root

  if not self:_is_root(current) then
    on_visit(current)
  end

  if #current.children == 0 then
    return
  end

  for _, child in ipairs(current.children) do
    self:walk(on_visit, child)
  end
end

---@return circleci.Node
function Tree:_make_root()
  local rootNode = require("circleci.ui.node.base"):new()
  rootNode.id = "root"
  rootNode.depth = -1

  return rootNode
end

---@param node circleci.Node
---@return boolean
function Tree:_is_root(node)
  return node.id == "root"
end

return Tree
