local config = require("circleci.config").get().ui ---@cast config circleci.Config.UI
local colors = require("circleci.ui.highlights").colors

---@alias circleci.NodeDisplayHighlights {group: string, start_col: number, end_col: number}
---@alias circleci.NodeDisplay { line: string, highlights: circleci.NodeDisplayHighlights[] }

---@class circleci.Node
---@field children circleci.Node[]
---@field depth integer
---@field id string
---@field is_expanded boolean
---@field parent circleci.Node|nil
---@field highlights? circleci.NodeDisplayHighlights[]
---@field line string
local Node = {}

---@return circleci.Node
function Node:new()
  local instance = {}
  setmetatable(instance, { __index = self })

  instance.parent = nil
  instance.children = {}

  instance.depth = 0
  instance.is_expanded = false

  instance.line = ""
  instance.highlights = nil

  return instance
end

---@param node circleci.Node
function Node:append_child(node)
  node.parent = self
  node.depth = self.depth + 1
  table.insert(self.children, node)
end

---@return {icon: string, hl: string}
function Node:get_chevron()
  return {
    icon = (self.is_expanded and config.icons.expanded) or config.icons.collapsed or "",
    hl = self.is_expanded and colors.expanded_icon or colors.collapsed_icon,
  }
end

---Returns the indentation for the node given its depth in the tree
---@return string
function Node:indent()
  if self.depth == 0 then
    return ""
  end

  return (" "):rep(self.depth)
end

---@return circleci.NodeDisplay
function Node:get_display()
  assert(false, "'get_display' must be implemented in child 'BaseNode' instances")
  ---@diagnostic disable-next-line: return-type-mismatch
  return nil
end

return Node
