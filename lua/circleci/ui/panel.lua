local JobNode = require("circleci.ui.node.job")
local PipelineNode = require("circleci.ui.node.pipeline")
local WorkflowNode = require("circleci.ui.node.workflow")

---@class circlci.Panel
---@field lines string[]
---@field line_to_node table<number, circleci.Node>
---@field win_id number
---@field buf_id number
---@field api circleci.API
---@field config circleci.Config.UI
---@field tree circleci.Tree
---@field win_opts table<string, boolean|string|number>
---@field buf_opts table<string, boolean|string|number>
---@field title string
local Panel = {}

local singleton = nil

---@param opts {api: circleci.API, config: circleci.Config.UI}
function Panel:new(opts)
  if singleton ~= nil then
    return singleton
  end

  setmetatable({ __index = self }, self)

  self.lines = {}
  self.line_to_node = {}

  self.api = opts.api
  self.config = opts.config
  self.tree = require("circleci.ui.tree"):new()

  self.win_id = nil
  self.buf_id = nil
  self.win_opts = self:_get_win_opts()
  self.buf_opts = self:_get_buf_opts()

  self.title = "Pipelines"

  singleton = self
  return self
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
    self:_init()
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
    self:build_tree()
  end

  if #self.lines == 0 then
    return
  end

  self:render_title()
  self:render_tree()

  -- TODO: apply highlights
  --
  -- local highlight = require("circleci.ui.highlights")
  -- vim.api.nvim_buf_set_extmark(self.buf_id, highlight.namespace, 0, 0, {
  --   hl_group = highlight.default.title.group,
  --   end_col = self.title:len(),
  -- })
end

function Panel:build_tree()
  local pipelines = self.api:pipelines()

  for _, pipeline in ipairs(pipelines.items) do
    local pipeline_node = PipelineNode:new(pipeline)

    local workflows = self.api:pipeline_workflows(pipeline.id)

    -- Filter out pipelines that didn't generate workflows
    if #workflows.items ~= 0 then
      self.tree:append_node(pipeline_node)
    end

    for _, workflow in ipairs(workflows.items) do
      local workflow_node = WorkflowNode:new(workflow)
      self.tree:append_child(pipeline_node, workflow_node)

      -- TODO: Don't fetch jobs until workflow is expanded
      local jobs = self.api:workflow_jobs(workflow.id)
      for _, job in ipairs(jobs.items) do
        self.tree:append_child(workflow_node, JobNode:new(job))
      end
    end
  end
end

function Panel:render_tree()
  self.tree:walk(function(node)
    local idx = #self.lines + 1
    table.insert(self.lines, idx, node:render(self.config))
    table.insert(self.line_to_node, idx, node)
  end)

  self:render()
end

-- TODO: Remove this and have one "draw" call after self.lines is ready
function Panel:render_title()
  table.insert(self.lines, 1, self.title)
  table.insert(self.lines, 2, "")

  self:render()
end

--TODO: Make this a general purpose draw method with optional line args
function Panel:render()
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
  vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, self.lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf_id })
end

---Creates a new buffer for the panel but does not open it
function Panel:_init()
  if self.buf_id then
    return
  end

  self.buf_id = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(self.buf_id, "circleci_panel")

  for k, v in pairs(self.buf_opts) do
    vim.api.nvim_set_option_value(k, v, { buf = self.buf_id })
  end
end

---TODO: Move this into a static table so we don't have to create many of these
function Panel:_get_win_opts()
  return {
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
end

---TODO: Move this into a static table so we don't have to create many of these
function Panel:_get_buf_opts()
  return {
    swapfile = false,
    buftype = "nofile",
    modifiable = false,
    bufhidden = "hide",
    modeline = false,
    undolevels = -1,
    filetype = "circleci",
  }
end

return Panel
