local utils = require("circleci.utils")

local M = {}

---Start (or attach to) the CircleCI language server
---@param bufid number
function M.start(bufid)
  local config = require("circleci.config").get_config()

  if not config.lsp.enabled then
    return
  end

  if not M.is_circleci_config(bufid) then
    return
  end

  local root_dir = vim.fs.root(bufid, { ".git", ".circleci" })
  local schema_path = M.get_schema_path()

  if vim.fn.filereadable(schema_path) == 0 then
    vim.notify("CircleCI: schema.json not found", vim.log.levels.ERROR)
    return
  end

  vim.lsp.start({
    cmd = { M.get_circleci_binary_name(), "-schema=" .. schema_path, "--stdio" },
    name = "circleci",
    root_dir = root_dir,
    on_init = function(client)
      local api_token = require("circleci.auth").get_api_token()

      if api_token ~= nil then
        client.request("workspace/executeCommand", {
          command = "setToken",
          arguments = { api_token },
        })
      end

      if not config.self_hosted_url ~= "" then
        client.request("workspace/executeCommand", {
          command = "setSelfHostedUrl",
          arguments = { config.self_hosted_url },
        })
      end
    end,
  })
end

---Check if the yaml file is specifically a CircleCI config file
---@param bufid number
function M.is_circleci_config(bufid)
  local filepath = vim.api.nvim_buf_get_name(bufid)
  local dir = vim.fs.dirname(filepath)

  return vim.fs.basename(dir) == ".circleci"
end

---Get the path to the schema.json file that's installed alongside the language server
---@return string
function M.get_schema_path()
  local config = require("circleci.config").get_config()
  if config.lsp.schema_path ~= "" then
    return config.lsp.schema_path
  end

  local ok, mason = pcall(require, "mason-registry")
  if not ok then
    return ""
  end

  local exists, pkg = pcall(mason.get_package, "circleci-yaml-language-server")
  if not exists then
    return ""
  end

  local pkg_path = pkg:get_install_path()
  local schema_path = vim.fn.resolve(pkg_path .. "/schema.json")

  return schema_path
end

---Get the path to the CircleCI language server binary installed on the system
---NOTE: Could be just the name of the binary if it's in the PATH
---@return string
function M.get_circleci_binary_path()
  local config = require("circleci.config").get_config()
  return config.lsp.cmd
end

---Get the name of the CircleCI language server binary installed on the system
---@return string
function M.get_circleci_binary_name()
  return vim.fs.basename(M.get_circleci_binary_path())
end

---Check if the CircleCI language server is installed on the system
---@return boolean
function M.is_installed()
  return utils.is_installed(M.get_circleci_binary_path())
end

---Get the version of the CircleCI language server installed on the system
---@return string
function M.get_version()
  if not M.is_installed() then
    return ""
  end

  return utils.get_version({ M.get_circleci_binary_path(), "--version" })
end

return M
