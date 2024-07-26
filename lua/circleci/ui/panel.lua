local JobNode = require("circleci.ui.node.job")
local PipelineNode = require("circleci.ui.node.pipeline")
local WorkflowNode = require("circleci.ui.node.workflow")
local actions = require("circleci.ui.actions")
local highlights = require("circleci.ui.highlights")

local M = {}

---@class circleci.Panel
---@field actions circleci.Actions
---@field api circleci.API
---@field buf_id number
---@field buf_name string
---@field buf_opts table<string, boolean|string|number>
---@field config circleci.Config.UI
---@field line_to_node circleci.Node[]
---@field node_to_line table<string, number>
---@field tree circleci.Tree
---@field win_id number
---@field win_opts table<string, boolean|string|number>
local Panel = {}

---@type circleci.Panel
local instance = nil

function M.init(opts)
  return Panel:new(opts)
end

function M.open()
  instance:open()
end

function M.close()
  instance:close()
end

function M.toggle()
  instance:toggle()
end

---Initializes the panel or returns an existing instance
---@param opts {api: circleci.API, config: circleci.Config.UI}
function Panel:new(opts)
  if instance ~= nil then
    return instance
  end

  instance = setmetatable({}, { __index = Panel })

  instance.line_to_node = {} -- <line_number, node>
  instance.node_to_line = {} -- <node_id, line_number>

  instance.api = opts.api
  instance.config = opts.config
  instance.tree = require("circleci.ui.tree"):new()
  instance.actions = actions.new({
    ctx = instance,
    actions = {
      expand = instance.expand,
    },
    keys = opts.config.panel.keys,
    prefix = "CircleCI Panel",
  })

  instance.win_id = nil
  instance.buf_id = nil
  instance.win_opts = instance:get_win_opts()
  instance.buf_opts = instance:get_buf_opts()
  instance.buf_name = "Pipelines"

  instance:init_buf()

  return instance
end

function Panel:toggle()
  if self.win_id then
    self:close()
  else
    self:open()
  end
end

function Panel:close()
  if not self.win_id then
    return
  end

  -- Using `pcall` so that the autocmd trying to clear self.win_id doesn't error
  pcall(vim.api.nvim_win_close, self.win_id, true)

  self.win_id = nil
end

function Panel:open()
  if self.win_id then
    return
  end

  self.win_id = vim.api.nvim_open_win(self.buf_id, true, {
    width = math.floor(vim.o.columns * 0.3), -- TODO: Make this configurable
    height = vim.o.lines,
    focusable = true,
    split = "right", -- TODO: Make this configurable
  })

  for k, v in pairs(self.win_opts) do
    vim.api.nvim_set_option_value(k, v, { win = self.win_id })
  end

  vim.wo[self.win_id].winbar = " Pipelines" -- TODO: Make this configurable

  if self.tree:is_empty() then
    self:build_initial_tree()
  end
end

---@param node circleci.Node
---@param lines table
---@param hls table
---@param row_start number
function Panel:build_line(node, lines, hls, row_start)
  local display = node:get_display()

  table.insert(lines, display.line)

  if display.highlights then
    for _, hl in ipairs(display.highlights) do
      table.insert(hls, {
        group = hl.group,
        start_col = hl.start_col,
        end_col = hl.end_col,
        row = row_start + #lines - 1,
      })
    end
  end
end

function Panel:build_initial_tree()
  local lines = {}
  local hls = {}

  local pipelines = self.api:pipelines()

  for _, pipeline in ipairs(pipelines.items) do
    local pipeline_node = PipelineNode:new(pipeline)

    local workflows = self.api:pipeline_workflows(pipeline.id)

    -- Filter out pipelines that didn't generate workflows
    if #workflows.items ~= 0 then
      self.tree:append_node(pipeline_node)
      self:build_line(pipeline_node, lines, hls, 0)

      self.node_to_line[pipeline_node.id] = #lines
      self.line_to_node[#lines] = pipeline_node
    end

    for _, workflow in ipairs(workflows.items) do
      local workflow_node = WorkflowNode:new(workflow)
      self.tree:append_child(pipeline_node, workflow_node)

      -- self.node_to_line[workflow_node.id] = #lines
      -- self.line_to_node[#lines] = workflow_node

      -- -- TODO: Don't fetch jobs until workflow is expanded
      -- local jobs = self.api:workflow_jobs(workflow.id)
      -- for _, job in ipairs(jobs.items) do
      --   local job_node = JobNode:new(job)
      --   self.tree:append_child(workflow_node, job_node)
      --   self:insert_node(job_node, lines, hls)
      -- end
    end
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
  vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf_id })

  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_add_highlight(self.buf_id, highlights.namespace, hl.group, hl.row, hl.start_col, hl.end_col)
  end
end

---Creates a new buffer for the panel but does not open it
function Panel:init_buf()
  if self.buf_id then
    return
  end

  self.buf_id = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(self.buf_id, self.buf_name)

  for k, v in pairs(self.buf_opts) do
    vim.api.nvim_set_option_value(k, v, { buf = self.buf_id })
  end

  self.actions:register_keys(self.buf_id)
end

---Expand/collapse the node under the cursor
function Panel:toggle_node()
  local line = vim.fn.line(".")
  local node = self.line_to_node[line]
  print(vim.inspect({
    type = node.type,
    id = node.id,
    expanded = node.is_expanded,
    line = line,
  }))
  if not node then
    return
  end

  if node.is_expanded then
    self:collapse_node(node)
  else
    self:expand_node(node)
  end
end

---@param node circleci.Node
function Panel:expand_node(node)
  if #node.children == 0 then
    return
  end

  local parent_line = self.node_to_line[node.id]
  local lines = {}
  local hls = {}

  self.tree:walk(function(n)
    if n.id == node.id then
      return
    end

    self:build_line(n, lines, hls, parent_line)
    self.node_to_line[n.id] = parent_line + #lines
    table.insert(self.line_to_node, parent_line + #lines, n)
  end, node)

  for i, n in ipairs(self.line_to_node) do
    print(i, n.id, n.type)
  end

  node.is_expanded = true
  local refresh = node:get_display(true)

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
  vim.api.nvim_buf_set_text(self.buf_id, parent_line - 1, 0, parent_line - 1, -1, { refresh.line })
  vim.api.nvim_buf_set_lines(self.buf_id, parent_line, parent_line, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf_id })

  for _, hl in ipairs(refresh.highlights or {}) do
    vim.api.nvim_buf_add_highlight(
      self.buf_id,
      highlights.namespace,
      hl.group,
      parent_line - 1,
      hl.start_col,
      hl.end_col
    )
  end

  for _, hl in ipairs(hls) do
    vim.api.nvim_buf_add_highlight(self.buf_id, highlights.namespace, hl.group, hl.row, hl.start_col, hl.end_col)
  end
end

---Collapse the node under the cursor
---@param node circleci.Node
function Panel:collapse_node(node)
  if #node.children == 0 then
    return
  end

  local parent_line = self.node_to_line[node.id]
  local children_start = parent_line + 1
  local children_end = children_start + #node.children - 1

  print("parent_line", parent_line, node.id)

  self.tree:walk(function(n)
    if n.id == node.id then
      return
    end

    self.node_to_line[n.id] = nil
    table.remove(self.line_to_node, parent_line + 1) -- Since removing mutates we don't need to increment
  end, node)

  for i, n in ipairs(self.line_to_node) do
    print(i, n.id, n.type)
  end

  node.is_expanded = false
  local refresh = node:get_display(true)

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
  vim.api.nvim_buf_set_text(self.buf_id, parent_line - 1, 0, parent_line - 1, -1, { refresh.line })
  vim.api.nvim_buf_set_lines(self.buf_id, children_start - 1, children_end, false, {})
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf_id })

  for _, hl in ipairs(refresh.highlights or {}) do
    vim.api.nvim_buf_add_highlight(
      self.buf_id,
      highlights.namespace,
      hl.group,
      parent_line - 1,
      hl.start_col,
      hl.end_col
    )
  end
end

local win_opts = {
  relativenumber = false,
  number = false,
  list = false,
  winfixwidth = true,
  winfixheight = true,
  foldenable = false,
  spell = false,
  wrap = false,
  signcolumn = "yes",
  colorcolumn = "",
  foldmethod = "manual",
  foldcolumn = "0",
  scrollbind = false,
  cursorbind = false,
  diff = false,
  winhl = "SignColumn:CircleCIPanelSignColumn,WinBar:CircleCIPanelWinBar,WinBarNC:CircleCIPanelWinBarNC",
}

function Panel:get_win_opts()
  return win_opts
end

local buf_opts = {
  swapfile = false,
  buftype = "nofile",
  modifiable = false,
  bufhidden = "hide",
  modeline = false,
  undolevels = -1,
  filetype = "CircleCIPanel",
}

function Panel:get_buf_opts()
  return buf_opts
end

return M
