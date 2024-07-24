local M = {}

M.namespace = vim.api.nvim_create_namespace("circleci")

M.colors = {
  title = "CircleCIPanelTitle",
  pipeline_icon = "CircleCIPipelineIcon",
  expanded_icon = "CircleCIExpandedIcon",
  collapsed_icon = "CircleCICollapsedIcon",
  job_cancelled = "CircleCIJobCancelled",
  job_failed = "CircleCIJobFailed",
  job_hold = "CircleCIJobHold",
  job_running = "CircleCIJobRunning",
  job_success = "CircleCIJobSuccess",
  job_meta = "CircleCIJobMeta",
  workflow_cancelled = "CircleCIWorkflowCancelled",
  workflow_errored = "CircleCIWorkflowErrored",
  workflow_failed = "CircleCIWorkflowFailed",
  workflow_hold = "CircleCIWorkflowHold",
  workflow_running = "CircleCIWorkflowRunning",
  workflow_success = "CircleCIWorkflowSuccess",
  sign_column = "CircleCISignColumn",
}

M.defs = {
  [M.colors.title] = { link = "Title", default = true },
  [M.colors.pipeline_icon] = { link = "Normal", default = true },
  [M.colors.expanded_icon] = { link = "Comment", default = true },
  [M.colors.collapsed_icon] = { link = "Comment", default = true },
  [M.colors.job_cancelled] = { link = "ErrorMsg", default = true },
  [M.colors.job_failed] = { link = "ErrorMsg", default = true },
  [M.colors.job_hold] = { fg = "#8864B4", default = true },
  [M.colors.job_running] = { link = "Normal", default = true },
  [M.colors.job_success] = { fg = "#80BA83", default = true },
  [M.colors.job_meta] = { link = "Comment", default = true },
  [M.colors.workflow_cancelled] = { link = "CircleCIJobCancelled", default = true },
  [M.colors.workflow_errored] = { link = "CircleCIJobFailed", default = true },
  [M.colors.workflow_failed] = { link = "CircleCIJobFailed", default = true },
  [M.colors.workflow_hold] = { link = "CircleCIJobHold", default = true },
  [M.colors.workflow_running] = { link = "CircleCIJobRunning", default = true },
  [M.colors.workflow_success] = { link = "CircleCIJobSuccess", default = true },
  [M.colors.sign_column] = { link = "Normal", default = true },
}

---Register all highlights
function M.setup()
  for k, v in pairs(M.defs) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

return M
