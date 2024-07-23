local BaseNode = require("circleci.ui.node.base")

---@class circleci.Node.Job: circleci.Node
---@field data circleci.API.Job
local JobNode = setmetatable({}, { __index = BaseNode })

---@param data circleci.API.Job
---@return circleci.Node.Job
function JobNode:new(data)
  local instance = BaseNode:new()

  ---@cast instance circleci.Node.Job
  setmetatable(instance, { __index = self })

  instance.id = data.id
  instance.data = data

  return instance
end

---@param config circleci.Config.UI
---@return string
function JobNode:render(config)
  local icon = self:get_icon(config)

  -- TODO: Handle parent indent + icon padding better
  local output = "    " .. self:indent()

  if icon ~= "" then
    output = output .. icon .. " "
  end

  output = output .. self.data.name .. " " .. self:render_status()

  return output
end

function JobNode:render_status()
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

---@param config circleci.Config.UI
---@return string
function JobNode:get_icon(config)
  local icon
  if self.data.status == "success" then
    icon = config.icons.job_success
  elseif self.data.status == "running" then
    icon = config.icons.job_running
  elseif self.data.status == "not_run" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "failed" then
    icon = config.icons.job_failed
  elseif self.data.status == "retried" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "failing" then
    icon = config.icons.job_failed
  elseif self.data.status == "queued" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "not_running" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "infrastructure_fail" then
    icon = config.icons.job_failed
  elseif self.data.status == "timedout" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "on_hold" then
    icon = config.icons.job_hold
  elseif self.data.status == "terminated_unknown" then
    icon = config.icons.job_failed
  elseif self.data.status == "blocked" then
    icon = config.icons.job_failed -- TODO: icon?
  elseif self.data.status == "canceled" then
    icon = config.icons.job_canceled
  elseif self.data.status == "unauthorized" then
    icon = config.icons.job_failed
  end

  return icon or ""
end

return JobNode
