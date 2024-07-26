local M = {}

---@class circleci.Actions
---@field private ctx any
---@field private actions table<string, function>
---@field private keys table<string, string>
---@field private prefix string
local Actions = {}

---@class circleci.ActionOpts
---@field ctx table
---@field actions table<string, function>
---@field keys table<string, string>
---@field prefix string

---@param opts circleci.ActionOpts
function M.new(opts)
  return Actions:new(opts)
end

---@param opts circleci.ActionOpts
function Actions:new(opts)
  local instance = setmetatable({}, { __index = self })

  instance.actions = opts.actions
  instance.ctx = opts.ctx
  instance.keys = opts.keys
  instance.prefix = opts.prefix

  return instance
end

function Actions:register_keys(buf_id)
  for key, action in pairs(self.keys) do
    vim.keymap.set(
      "n",
      key,
      function()
        self:call(action)
      end,
      { buffer = buf_id, desc = string.format("%s: '%s' action", self.prefix, action), noremap = true, silent = true }
    )
  end
end

function Actions:call(action)
  if not self.ctx[action] then
    vim.notify(string.format("%s: action '%s' not found", self.prefix, action), vim.log.levels.ERROR)
    return
  end

  self.ctx[action](self.ctx)
end

return M
