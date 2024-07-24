local BaseNode = require("circleci.ui.node.base")

---@class circleci.Node.Padding: circleci.Node
local PaddingNode = setmetatable({}, { __index = BaseNode })

---@return circleci.Node.Padding
function PaddingNode:new()
  local instance = BaseNode:new()

  setmetatable(instance, { __index = self })
  ---@cast instance circleci.Node.Padding

  instance.id = "padding"

  return instance
end

---@return circleci.NodeDisplay
function PaddingNode:get_display()
  return {
    line = "",
    highlights = nil,
  }
end

return PaddingNode
