local M = {}

---@param config circleci.Config
function M.setup(config)
  require("circleci.ui.highlights").setup()

  require("circleci.ui.panel").init({
    api = require("circleci.api"):new(),
    config = config.ui,
  })
end

return M
