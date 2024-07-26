local BaseNode = require("circleci.ui.node.base")
local config = require("circleci.config").get().ui ---@cast config circleci.Config.UI
local colors = require("circleci.ui.highlights").colors

---@class circleci.Node.Job: circleci.Node
---@field data circleci.API.Job
local JobNode = setmetatable({}, { __index = BaseNode })

---@param data circleci.API.Job
---@return circleci.Node.Job
function JobNode:new(data)
  local instance = BaseNode:new()

  setmetatable(instance, { __index = self })
  ---@cast instance circleci.Node.Job

  instance.id = data.id
  instance.type = "job"

  instance.data = data

  return instance
end

---@param force? boolean
---@return circleci.NodeDisplay
function JobNode:get_display(force)
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

function JobNode:set_display()
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

  local meta = " " .. self:get_meta()
  local meta_start_col = self.line:len()
  local meta_end_col = meta_start_col + meta:len()

  self.line = self.line .. meta

  table.insert(self.highlights, { group = colors.job_meta, start_col = meta_start_col, end_col = meta_end_col })
end

---@return string
function JobNode:get_meta()
  if self.data.status == "success" then
    return "Success"
  elseif self.data.status == "running" then
    return "Running"
  elseif self.data.status == "not_run" then
    return "Not Run"
  elseif self.data.status == "failed" then
    return "Failed"
  elseif self.data.status == "retried" then
    return "Retried"
  elseif self.data.status == "failing" then
    return "Failing"
  elseif self.data.status == "queued" then
    return "Queued"
  elseif self.data.status == "not_running" then
    return "Not Running"
  elseif self.data.status == "infrastructure_fail" then
    return "Infrastructure Fail"
  elseif self.data.status == "timedout" then
    return "Timed Out"
  elseif self.data.status == "on_hold" then
    return "On Hold"
  elseif self.data.status == "terminated_unknown" then
    return "Terminated Unknown"
  elseif self.data.status == "blocked" then
    return "Blocked"
  elseif self.data.status == "canceled" then
    return "Canceled"
  elseif self.data.status == "unauthorized" then
    return "Unauthorized"
  end

  return "Unknown Status"
end

---@return {icon: string, hl: string|nil}
function JobNode:get_icon()
  local icon, hl
  if self.data.status == "success" then
    icon = config.icons.job_success
    hl = colors.job_success
  elseif self.data.status == "running" then
    icon = config.icons.job_running
    hl = colors.job_running
  elseif self.data.status == "not_run" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "failed" then
    icon = config.icons.job_failed
    hl = colors.job_failed
  elseif self.data.status == "retried" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "failing" then
    icon = config.icons.job_failed
    hl = colors.job_failed
  elseif self.data.status == "queued" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "not_running" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "infrastructure_fail" then
    icon = config.icons.job_failed
    hl = colors.job_failed
  elseif self.data.status == "timedout" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "on_hold" then
    icon = config.icons.job_hold
    hl = colors.job_hold
  elseif self.data.status == "terminated_unknown" then
    icon = config.icons.job_failed
    hl = colors.job_failed
  elseif self.data.status == "blocked" then
    icon = config.icons.job_failed -- TODO: icon?
    hl = colors.job_failed
  elseif self.data.status == "canceled" then
    icon = config.icons.job_canceled
    hl = colors.job_canceled
  elseif self.data.status == "unauthorized" then
    icon = config.icons.job_failed
    hl = colors.job_failed
  end

  return {
    icon = icon or "",
    hl = hl or nil,
  }
end

return JobNode
