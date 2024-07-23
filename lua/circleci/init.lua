local M = {}

---Initializes the plugin
---@param opts? circleci.Config
function M.setup(opts)
  local config = require("circleci.config").merge(opts)

  -- TODO: Convert to ftplugin instead of FileType autocommand
  -- and add a setup() function to this module that registers user commands
  require("circleci.commands")

  if config.ui.enable then
    require("circleci.ui").setup(config)
  end
end

return M
