local JobNode = require("circleci.ui.node.job")
local PaddingNode = require("circleci.ui.node.padding")
local PipelineNode = require("circleci.ui.node.pipeline")
local TitleNode = require("circleci.ui.node.title")
local WorkflowNode = require("circleci.ui.node.workflow")
local highlights = require("circleci.ui.highlights")

---@class circleci.Panel
---@field line_to_node table<number, circleci.Node>
---@field node_to_line table<string, number>
---@field win_id number
---@field buf_id number
---@field api circleci.API
---@field config circleci.Config.UI
---@field tree circleci.Tree
---@field win_opts table<string, boolean|string|number>
---@field buf_opts table<string, boolean|string|number>
---@field buf_name string
local Panel = {}

---@type circleci.Panel|nil
local singleton = nil

---Initializes the panel or returns an existing instance
---@param opts {api: circleci.API, config: circleci.Config.UI}
function Panel.init(opts)
  if singleton ~= nil then
    return singleton
  end

  local instance = setmetatable({}, { __index = Panel })

  instance.line_to_node = {} -- <line_number, node>
  instance.node_to_line = {} -- <node_id, line_number>

  instance.api = opts.api
  instance.config = opts.config
  instance.tree = require("circleci.ui.tree"):new()

  instance.win_id = nil
  instance.buf_id = nil
  instance.win_opts = instance:get_win_opts()
  instance.buf_opts = instance:get_buf_opts()
  instance.buf_name = "circleci.panel"

  singleton = instance
  return instance
end

function Panel:close()
  if not self.win_id then
    return
  end

  vim.api.nvim_win_close(self.win_id, true)
  self.win_id = nil
end

function Panel:open()
  if not self.buf_id then
    self:init_buf()
  end

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

  if self.tree:is_empty() then
    self:build_initial_tree()
  end
end

---@param node circleci.Node
---@param lines table
---@param hls table
function Panel:insert_node(node, lines, hls)
  local display = node:get_display()

  table.insert(lines, display.line)

  if display.highlights then
    for _, hl in ipairs(display.highlights) do
      table.insert(hls, {
        group = hl.group,
        start_col = hl.start_col,
        end_col = hl.end_col,
        row = #lines - 1,
      })
    end
  end
end

function Panel:build_initial_tree()
  local lines = {}
  local hls = {}

  vim.notify("Building initial tree", vim.log.levels.INFO)

  local title_node = TitleNode:new()
  self.tree:append_node(title_node)
  self:insert_node(title_node, lines, hls)

  local padding_node = PaddingNode:new()
  self.tree:append_node(padding_node)
  self:insert_node(padding_node, lines, hls)

  local pipelines = self.api:pipelines()

  for _, pipeline in ipairs(pipelines.items) do
    local pipeline_node = PipelineNode:new(pipeline)

    local workflows = self.api:pipeline_workflows(pipeline.id)

    -- Filter out pipelines that didn't generate workflows
    if #workflows.items ~= 0 then
      self.tree:append_node(pipeline_node)
      self:insert_node(pipeline_node, lines, hls)
    end

    for _, workflow in ipairs(workflows.items) do
      local workflow_node = WorkflowNode:new(workflow)
      self.tree:append_child(pipeline_node, workflow_node)
      self:insert_node(workflow_node, lines, hls)

      -- TODO: Don't fetch jobs until workflow is expanded
      local jobs = self.api:workflow_jobs(workflow.id)
      for _, job in ipairs(jobs.items) do
        local job_node = JobNode:new(job)
        self.tree:append_child(workflow_node, job_node)
        self:insert_node(job_node, lines, hls)
      end
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
  winhl = "SignColumn:CircleCISignColumn",
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

return Panel
