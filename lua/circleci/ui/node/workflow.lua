local BaseNode = require("circleci.ui.node.base")
local config = require("circleci.config").get().ui ---@cast config circleci.Config.UI
local colors = require("circleci.ui.highlights").colors

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
  instance.type = "workflow"

  instance.data = data

  return instance
end

---@param force? boolean
---@return circleci.NodeDisplay
function WorkflowNode:get_display(force)
  if not self.line or self.line == "" then
    self:set_display()
  end

  if force then
    self:set_display()
  end

  return {
    line = self.line,
    highlights = self.highlights,
  }
end

function WorkflowNode:set_display()
  local icon = self:get_icon()
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

  if icon.icon ~= "" then
    local start_col = self.line:len()
    local end_col = start_col + icon.icon:len()

    self.line = self.line .. icon.icon .. " "

    if icon.hl then
      table.insert(self.highlights, { group = icon.hl, start_col = start_col, end_col = end_col })
    end
  end

  self.line = self.line .. self.data.name
end

---@return {icon: string, hl: string|nil}
function WorkflowNode:get_icon()
  local icon, hl
  if self.data.status == "success" then
    icon = config.icons.workflow_success
    hl = colors.workflow_success
  elseif self.data.status == "running" then
    icon = config.icons.workflow_running
    hl = colors.workflow_running
  elseif self.data.status == "failed" then
    icon = config.icons.workflow_failed
    hl = colors.workflow_failed
  elseif self.data.status == "error" then
    icon = config.icons.workflow_failed
    hl = colors.workflow_failed
  elseif self.data.status == "failing" then
    icon = config.icons.workflow_failed
    hl = colors.workflow_failed
  elseif self.data.status == "on_hold" then
    icon = config.icons.workflow_hold
    hl = colors.workflow_hold
  elseif self.data.status == "canceled" then
    icon = config.icons.workflow_canceled
    hl = colors.workflow_canceled
  elseif self.data.status == "unauthorized" then
    icon = config.icons.workflow_failed
    hl = colors.workflow_failed
  end

  return {
    icon = icon or "",
    hl = hl or nil,
  }
end

return WorkflowNode
