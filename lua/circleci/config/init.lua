local M = {}

---@class CircleCILspConfig
---@field enabled? boolean Whether to enable the circleci language server
---@field cmd? string Name of binary or path to installation of the language server
---@field schema_path? string Path to the schema.json file installed with the language server

---@class CircleCIConfig
---@field api_token? string | string[] | fun():string If a string, it is treated as an environment variable name. If an array of strings, it is treated as a shell command. If a function, it is called the key's value is expected as the return value
---@field self_hosted_url? string The URL of the self-hosted CircleCI instance
---@field lsp? CircleCILspConfig

local defaults = require("circleci.config.defaults").defaults

---@type CircleCIConfig
M.config = defaults

---@return CircleCIConfig
function M.get_config()
  return M.config
end

---@param opts? CircleCIConfig
function M.load_config(opts)
  if opts == nil then
    return
  end

  M.config = vim.tbl_deep_extend("force", defaults, opts)
end

return M
