local BaseNode = require("circleci.ui.node.base")
local config = require("circleci.config").get().ui ---@cast config circleci.Config.UI
local colors = require("circleci.ui.highlights").colors

---@class circleci.Node.Pipeline: circleci.Node
---@field data circleci.API.Pipeline
local PipelineNode = setmetatable({}, { __index = BaseNode })

---@param data circleci.API.Pipeline
---@return circleci.Node.Pipeline
function PipelineNode:new(data)
  local instance = BaseNode:new()

  setmetatable(instance, { __index = self })
  ---@cast instance circleci.Node.Pipeline

  instance.id = data.id
  instance.data = data

  return instance
end

---@return circleci.NodeDisplay
function PipelineNode:get_display()
  if not self.line or self.line == "" then
    self:set_display()
  end

  return {
    line = self.line,
    highlights = self.highlights,
  }
end

function PipelineNode:set_display()
  local icon = config.icons.pipeline
  local chevron = self:get_chevron()
  local indent = self:indent()

  self.line = indent
  self.highlights = {}

  if chevron.icon ~= "" then
    local start_col = self.line:len()
    local end_col = start_col + chevron.icon:len()

    self.line = self.line .. chevron.icon .. " "

    table.insert(self.highlights, { group = chevron.hl, start_col = start_col, end_col = end_col })
  end

  if icon ~= "" then
    local start_col = self.line:len()
    local end_col = start_col + icon:len()

    self.line = self.line .. icon .. " "

    table.insert(self.highlights, { group = colors.pipeline_icon, start_col = start_col, end_col = end_col })
  end

  self.line = self.line .. (self.data.vcs.tag or self.data.vcs.branch or self.data.vcs.revision or "unknown")
end

return PipelineNode
