local BaseNode = require("circleci.ui.node.base")

---@class circleci.Node.Pipeline: circleci.Node
---@field data circleci.API.Pipeline
local PipelineNode = setmetatable({}, { __index = BaseNode })

---@param data circleci.API.Pipeline
---@return circleci.Node.Pipeline
function PipelineNode:new(data)
  local instance = BaseNode:new()

  ---@cast instance circleci.Node.Pipeline
  setmetatable(instance, { __index = self })

  instance.id = data.id
  instance.data = data

  return instance
end

---@param config circleci.Config.UI
---@return string
function PipelineNode:render(config)
  local icon = config.icons.pipeline
  local chevron = self:get_chevron(config)

  local output = self:indent()

  if chevron ~= "" then
    output = output .. chevron .. " "
  end

  if icon ~= "" then
    output = output .. icon .. " "
  end

  output = output .. (self.data.vcs.tag or self.data.vcs.branch or self.data.vcs.revision or "unknown")

  return output
end

return PipelineNode
