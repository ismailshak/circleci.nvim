local M = {}

---Initializes the plugin
---@param opts? CircleCIConfig
function M.setup(opts)
  require("circleci.config").load_config(opts)

  -- Registers user commands and autocommands
  require("circleci.commands")
end

return M
