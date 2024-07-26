local M = {}

---@class circleci.Config
---@field api_token? string | string[] | fun():string If a string, it is treated as an environment variable name. If an array of strings, it is treated as a shell command. If a function, it is called the key's value is expected as the return value
---@field self_hosted_url? string The URL of the self-hosted CircleCI instance
---@field lsp? circleci.Config.LSP Configuration for the language server
---@field ui? circleci.Config.UI Configuration for the UI

---@class circleci.Config.LSP
---@field enable? boolean Whether to enable the circleci language server
---@field cmd? string Name of binary or path to installation of the language server
---@field schema_path? string Path to the schema.json file installed with the language server

---@class circleci.Config.UI
---@field enable? boolean If false the UI modules will not be loaded at all
---@field icons? circleci.Config.UI.Icons Configuration for the icons used in the UI
---@field panel? circleci.Config.UI.Panel Configuration for the panel

---@class circleci.Config.UI.Panel
---@field keys? table<string, string> Keybindings for the panel

---@class circleci.Config.UI.Icons
---@field collapsed? string Icon to display for a collapsed section
---@field expanded? string Icon to display for an expanded section
---@field job_canceled? string Icon to display for a canceled job
---@field job_failed? string Icon to display for a failed job
---@field job_hold? string Icon to display for a job that needs approval
---@field job_running? string Icon to display for a running job
---@field job_success? string Icon to display for a successful job
---@field pipeline? string Icon to display for a pipeline
---@field workflow_canceled? string Icon to display for a canceled workflow
---@field workflow_errored? string Icon to display for an errored workflow (e.g. config invalid)
---@field workflow_failed? string Icon to display for a failed workflow
---@field workflow_hold? string Icon to display for a workflow that needs approval
---@field workflow_running? string Icon to display for a running workflow
---@field workflow_success? string Icon to display for a successful workflow

local defaults = require("circleci.config.defaults").defaults

---@type circleci.Config
M.config = defaults

---@return circleci.Config
function M.get()
  return M.config
end

---@param opts? circleci.Config
---@return circleci.Config
function M.merge(opts)
  if opts == nil then
    return M.config
  end

  M.config = vim.tbl_deep_extend("force", defaults, opts)

  return M.config
end

return M
