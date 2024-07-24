local BaseNode = require("circleci.ui.node.base")
local colors = require("circleci.ui.highlights").colors

---@class circleci.Node.Title: circleci.Node
local TitleNode = setmetatable({}, { __index = BaseNode })

---@return circleci.Node.Title
function TitleNode:new()
  local instance = BaseNode:new()

  setmetatable(instance, { __index = self })
  ---@cast instance circleci.Node.Title

  instance.id = "title"

  return instance
end

function TitleNode:get_display()
  if not self.line or self.line == "" then
    self:set_display()
  end

  return {
    line = self.line,
    highlights = self.highlights,
  }
end

function TitleNode:set_display()
  self.line = "Pipelines"
  self.highlights = {
    { group = colors.title, start_col = 0, end_col = self.line:len() },
  }
end

return TitleNode
