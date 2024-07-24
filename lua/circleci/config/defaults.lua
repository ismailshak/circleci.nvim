local M = {}

---@type circleci.Config
M.defaults = {
  api_token = "",
  self_hosted_url = "",
  lsp = {
    enable = true,
    cmd = "circleci-yaml-language-server",
    schema_path = "", -- defaults to mason.nvim's schema.json installation path
  },
  ui = {
    enable = true,
    icons = {
      collapsed = "",
      expanded = "",
      job_canceled = "󱄊",
      job_failed = "󰲼",
      job_hold = "󱖒", -- 󱖐
      job_running = "󰦖",
      job_success = "󰦕",
      pipeline = "", --  /  /  /  /  / 
      -- workflow = "", -- Might not be needed if we're showing status icons instead
      workflow_canceled = "",
      workflow_errored = "",
      workflow_failed = "",
      workflow_hold = "",
      workflow_running = "", -- 
      workflow_success = "",
    },
  },
}

return M
