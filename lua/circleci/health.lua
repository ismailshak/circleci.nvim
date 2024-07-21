local utils = require("circleci.utils")

local M = {}

function M.check()
  vim.health.start("circleci.nvim")

  local binary = require("circleci.lsp").get_circleci_binary_name()

  if require("circleci.lsp").is_installed() then
    local version = require("circleci.lsp").get_version()

    vim.health.ok(string.format("%s: installed", binary))
    vim.health.info("version: " .. version .. "\n")
  else
    local advice = {
      "you can install it via `mason.nvim`",
      "or manually from https://github.com/CircleCI-Public/circleci-yaml-language-server/releases",
      "if installed manually, make sure the binary is in your PATH and that you download the accompanying schema.json file",
    }

    vim.health.error(string.format("%s: not installed", binary), advice)
  end

  local has_curl = utils.is_installed("curl")
  if has_curl then
    local version = utils.get_version({ "curl", "--version" })

    vim.health.ok("curl: installed")
    vim.health.info("version: " .. version .. "\n")
  else
    vim.health.error("curl: not installed", "install it and make sure it is in your PATH")
  end

  if has_curl then
    local api = require("circleci.api").new()

    local response = api:me()
    if response.name ~= "" or response.name ~= nil then
      vim.health.ok("api_token: authenticated as " .. response.login)
    else
      vim.health.warn("api_token: invalid", "make sure your API token is correct and correctly set in `setup()`")
    end
  end
end

return M
