local M = {}

---@type string | nil
local cached_token = nil

---Get the user's CircleCI API token given their chosen approach
---@return string | nil
function M.get_api_token()
  if cached_token ~= nil then
    return cached_token
  end

  local config = require("circleci.config").get_config()

  if type(config.api_token) == "function" then
    local key = config.api_token()
    if type(key) ~= "string" then
      vim.notify_once("CircleCI: 'api_token' function must return a string", vim.log.levels.ERROR)
      return
    end

    if key == "" then
      vim.notify_once("CircleCI: 'api_token' function returned an empty string", vim.log.levels.ERROR)
      return
    end

    return key
  end

  if type(config.api_token) == "table" then
    ---@diagnostic disable-next-line: param-type-mismatch
    local cmd = vim.system(config.api_token, { text = true }):wait()
    if cmd.code ~= 0 then
      vim.notify_once("CircleCI: 'api_token' command provided failed", vim.log.levels.ERROR)
      vim.notify_once("CircleCI: " .. cmd.stderr, vim.log.levels.ERROR)
    end

    return vim.fn.trim(cmd.stdout)
  end

  if type(config.api_token) == "string" and config.api_token ~= "" then
    ---@diagnostic disable-next-line: param-type-mismatch
    local key = vim.fn.getenv(config.api_token)
    if key == "" or key == vim.NIL then
      vim.notify_once("CircleCI: 'api_token' environment variable provided did contain a value", vim.log.levels.ERROR)
    end

    return key
  end
end

return M
