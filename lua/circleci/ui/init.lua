local M = {}

---@param config circleci.Config
function M.setup(config)
  require("circleci.ui.panel"):new({
    api = require("circleci.api"):new(),
    config = config.ui,
  })
end

return M
