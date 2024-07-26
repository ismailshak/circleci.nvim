local M = {}

local augroup = vim.api.nvim_create_augroup("circleci", {})

local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

local completion = {
  [""] = { "panel" },
  panel = { "open", "close", "toggle" },
}

local modules = {
  panel = "circleci.ui.panel",
}

autocmd("FileType", {
  group = augroup,
  pattern = "yaml",
  callback = function(args)
    require("circleci.lsp").start(args.buf)
  end,
})

function M.autocmds()
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = augroup,
    pattern = "Pipelines",
    callback = function()
      require("circleci.ui.panel").close()
    end,
  })
end

function M.usercmds()
  usercmd("CircleCI", function(args)
    local parts = vim.split(args.args, "%s+", { trimempty = true })

    local ok, module = pcall(require, modules[parts[1]])
    if not ok then
      vim.notify(string.format("CircleCI: unknown command '%s'", parts[1]), vim.log.levels.ERROR)
      return
    end

    if parts[2] == nil then
      vim.notify(string.format("CircleCI %s: argument required", parts[1]), vim.log.levels.ERROR)
      return
    end

    if module[parts[2]] then
      module[parts[2]]()
    else
      vim.notify(string.format("CircleCI %s: unknown command '%s'", parts[1], parts[2]), vim.log.levels.ERROR)
    end
  end, {
    nargs = "+",
    desc = "CircleCI commands",
    complete = function(_, cmd)
      local parts = vim.split(cmd, "%s+", { trimempty = true })

      if #parts == 1 then
        return completion[""]
      elseif #parts == 2 then
        return completion[parts[2]]
      end
    end,
  })
end

function M.setup()
  M.autocmds()
  M.usercmds()
end

return M
