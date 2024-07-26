local M = {}

M.namespace = vim.api.nvim_create_namespace("circleci")

M.colors = {
  pipeline_icon = "CircleCIPipelineIcon",
  expanded_icon = "CircleCIExpandedIcon",
  collapsed_icon = "CircleCICollapsedIcon",
  job_canceled = "CircleCIJobCanceled",
  job_failed = "CircleCIJobFailed",
  job_hold = "CircleCIJobHold",
  job_running = "CircleCIJobRunning",
  job_success = "CircleCIJobSuccess",
  job_meta = "CircleCIJobMeta",
  workflow_canceled = "CircleCIWorkflowCanceled",
  workflow_errored = "CircleCIWorkflowErrored",
  workflow_failed = "CircleCIWorkflowFailed",
  workflow_hold = "CircleCIWorkflowHold",
  workflow_running = "CircleCIWorkflowRunning",
  workflow_success = "CircleCIWorkflowSuccess",
  panel_sign_column = "CircleCIPanelSignColumn",
  panel_winbar = "CircleCIPanelWinBar",
  panel_winbar_nc = "CircleCIPanelWinBarNC",
}

---@type table<string, vim.api.keyset.highlight>
local defs = {
  [M.colors.pipeline_icon] = { link = "Normal", default = true },
  [M.colors.expanded_icon] = { link = "Comment", default = true },
  [M.colors.collapsed_icon] = { link = "Comment", default = true },
  [M.colors.job_canceled] = { link = "Error", default = true },
  [M.colors.job_failed] = { link = "ErrorMsg", default = true },
  [M.colors.job_hold] = { fg = "#8864B4", default = true },
  [M.colors.job_running] = { link = "Normal", default = true },
  [M.colors.job_success] = { fg = "#80BA83", default = true },
  [M.colors.job_meta] = { link = "Comment", default = true },
  [M.colors.workflow_canceled] = { link = "CircleCIJobCanceled", default = true },
  [M.colors.workflow_errored] = { link = "CircleCIJobFailed", default = true },
  [M.colors.workflow_failed] = { link = "CircleCIJobFailed", default = true },
  [M.colors.workflow_hold] = { link = "CircleCIJobHold", default = true },
  [M.colors.workflow_running] = { link = "CircleCIJobRunning", default = true },
  [M.colors.workflow_success] = { link = "CircleCIJobSuccess", default = true },
  [M.colors.panel_sign_column] = { link = "Normal", default = true },
  [M.colors.panel_winbar] = { bold = true, default = true },
  [M.colors.panel_winbar_nc] = { link = "Normal", default = true },
}

---Register all highlights
function M.setup()
  for k, v in pairs(defs) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

return M
