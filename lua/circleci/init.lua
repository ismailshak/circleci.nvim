local M = {}

---Initializes the plugin
---@param opts? circleci.Config
function M.setup(opts)
  local config = require("circleci.config").merge(opts)

  require("circleci.commands").setup()

  if not config.ui.enable then
    return
  end

  require("circleci.ui").setup(config)
end

return M
