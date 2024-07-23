local M = {}

---Returns the version of a tool installed on the system
---@param cmd string[]
---@return string
function M.get_version(cmd)
  local out = vim.system(cmd, { text = true }):wait()
  return vim.fn.trim(out.stdout)
end

---Checks if a binary is installed on the system
---@param binary string
---@return boolean
function M.is_installed(binary)
  return vim.fn.executable(binary) == 1
end

---Parses a git URL and returns the domain, owner and repo
---@param url string
---@return {domain?: string, owner?: string, project?: string}
function M.parse_git_url(url)
  -- Pattern for SSH based URL
  local ssh_pattern = "git@([%w%.%-]+):([%w%-]+)/([%w%.%-]+)%.git"
  -- Pattern for HTTP(S) based URL
  local http_pattern = "https?://([%w%.%-]+)/([%w%-]+)/([%w%.%-]+)%.git"

  -- Try SSH pattern
  local domain, owner, project = url:match(ssh_pattern)
  if domain and owner and project then
    return {
      domain = domain,
      owner = owner,
      project = project,
    }
  end

  -- Try HTTP pattern
  domain, owner, project = url:match(http_pattern)
  if domain and owner and project then
    return {
      domain = domain,
      owner = owner,
      project = project,
    }
  end

  return {}
end

return M
