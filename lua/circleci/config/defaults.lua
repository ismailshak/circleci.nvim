local M = {}

---@type CircleCIConfig
M.defaults = {
  api_token = "",
  self_hosted_url = "",
  lsp = {
    enabled = true,
    cmd = "circleci-yaml-language-server",
    schema_path = "",
  },
}

return M
