local BaseNode = require("circleci.ui.node.base")

---@class circleci.Node.Workflow: circleci.Node
---@field data circleci.API.Workflow
local WorkflowNode = setmetatable({}, { __index = BaseNode })

---@param data circleci.API.Workflow
---@return circleci.Node.Workflow
function WorkflowNode:new(data)
  local instance = BaseNode:new()

  ---@cast instance circleci.Node.Workflow
  setmetatable(instance, { __index = self })

  instance.id = data.id
  instance.data = data

  return instance
end

---@param config circleci.Config.UI
---@return string
function WorkflowNode:render(config)
  local icon = self:get_icon(config)
  local chevron = self:get_chevron(config)

  -- TODO: Handle parent indent + icon padding better
  local output = " " .. self:indent()

  if chevron ~= "" then
    output = output .. chevron .. " "
  end

  if icon ~= "" then
    output = output .. icon .. " "
  end

  output = output .. self.data.name

  return output
end

---@param config circleci.Config.UI
---@return string
function WorkflowNode:get_icon(config)
  local icon
  if self.data.status == "success" then
    icon = config.icons.workflow_success
  elseif self.data.status == "running" then
    icon = config.icons.workflow_running
  elseif self.data.status == "failed" then
    icon = config.icons.workflow_failed
  elseif self.data.status == "error" then
    icon = config.icons.workflow_failed
  elseif self.data.status == "failing" then
    icon = config.icons.workflow_failed
  elseif self.data.status == "on_hold" then
    icon = config.icons.workflow_hold
  elseif self.data.status == "canceled" then
    icon = config.icons.workflow_canceled
  elseif self.data.status == "unauthorized" then
    icon = config.icons.workflow_failed
  end

  return icon or ""
end

return WorkflowNode
