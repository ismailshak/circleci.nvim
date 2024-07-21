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

return M
