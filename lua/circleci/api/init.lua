local async = require("circleci.async")
local http = require("circleci.api.http")

local uv = vim.uv or vim.loop

---@class circleci.API
---@field token string
---@field base_url string
---@field base_url_v1 string
---@field provider string
---@field owner string
---@field project string
local API = {}

--TODO: Make everything async
function API:new()
  setmetatable({}, self)
  self.__index = self

  -- TODO: Improve this later
  self.token = require("circleci.api.auth").parse_api_token()
  self.base_url = "https://circleci.com/api/v2"
  self.base_url_v1 = "https://circleci.com/api/v1.1"

  --TODO: Figure out repo's vcs slug here
  self.provider = "gh"
  self.owner = "ismailshak"
  self.project = "circleci.nvim"
  --
  -- Improve this later:
  -- vim
  --   .system({ "git", "retmote", "get-url", "origin" }, { text = true }, function(result)
  --     local url = result.stdout
  --     if not url then
  --       return
  --     end
  --
  --     local parsed = require("circleci.utils").parse_git_url(url)
  --
  --     self.provider = parsed.domain:gsub(".com", "")
  --     self.owner = parsed.owner
  --     self.project = parsed.project
  --   end)

  return self
end

function API.decode_response(response)
  return vim.json.decode(response, { luanil = { object = true, array = true } })
end

function API.init(self)
  return self
end

---@return circleci.API.Me
function API:me()
  local url = self.base_url .. "/me"

  local cmd = {
    "curl",
    url,
    "--header",
    string.format("Circle-Token: %s", self.token),
    "--silent",
  }

  local result = vim.system(cmd, { text = true }):wait()

  return self.decode_response(result.stdout)
end

function API:collaborations()
  local url = self.base_url .. "/me/collaborations"

  local cmd = {
    "curl",
    url,
    "--header",
    string.format("Circle-Token: %s", self.token),
    "--silent",
  }

  local result = vim.system(cmd, { text = true }):wait()

  return self.decode_response(result.stdout)
end

---@return circleci.API.Pipelines
-- function API:pipelines()
--   local url = string.format("%s/project/%s/%s/%s/pipeline", self.base_url, self.provider, self.owner, self.project)
--
--   local cmd = {
--     "curl",
--     url,
--     "--header",
--     string.format("Circle-Token: %s", self.token),
--     "--silent",
--   }
--
--   local result = vim.system(cmd, { text = true }):wait()
--
--   return self.decode_response(result.stdout)
-- end

---@return circleci.API.Workflows
function API:pipeline_workflows(pipeline_id)
  local url = string.format("%s/pipeline/%s/workflow", self.base_url, pipeline_id)

  local cmd = {
    "curl",
    url,
    "--header",
    string.format("Circle-Token: %s", self.token),
    "--silent",
  }

  local result = vim.system(cmd, { text = true }):wait()

  return self.decode_response(result.stdout)
end

---@param workflow_id string
---@return circleci.API.Jobs
function API:workflow_jobs(workflow_id)
  local url = string.format("%s/workflow/%s/job", self.base_url, workflow_id)

  local cmd = {
    "curl",
    url,
    "--header",
    string.format("Circle-Token: %s", self.token),
    "--silent",
  }

  local result = vim.system(cmd, { text = true }):wait()

  return self.decode_response(result.stdout)
end

---@param callback fun(data: circleci.API.Pipelines)
function API:pipelines_async(callback)
  local url = string.format("%s/project/%s/%s/%s/pipeline", self.base_url, self.provider, self.owner, self.project)
  local headers = { ["Circle-Token"] = self.token }

  http.request(url, headers, function(err, data)
    if err then
      vim.notify("Failed to fetch pipelines\n" .. err, vim.log.levels.ERROR)
      return
    end

    callback(data)
  end)

  -- local async_request = async.wrap(http.request)
  --
  -- async.sync(function()
  --   local err, data = async.await(async_request(url, headers))
  --
  --   if err then
  --     vim.notify("Failed to fetch pipelines\n" .. err, vim.log.levels.ERROR)
  --     return
  --   end
  --
  --   return data
  -- end)(callback)

  -- async.sync((url, headers) function(err, data)
  --   if err then
  --     vim.notify("Failed to fetch workflows\n" .. err, vim.log.levels.ERROR)
  --     return
  --   end
  --
  --   callback(data)
  -- end))
end

---@param pipeline_id string
---@param callback fun(data: circleci.API.Workflows)
function API:workflows_async(pipeline_id, callback)
  local url = string.format("%s/pipeline/%s/workflow", self.base_url, pipeline_id)
  local headers = { ["Circle-Token"] = self.token }

  http.request(url, headers, function(err, data)
    if err then
      vim.notify("Failed to fetch workflows\n" .. err, vim.log.levels.ERROR)
      return
    end

    callback(data)
  end)
end
--
-- function API:initial_fetch()
--   return async.sync(function()
--     local pipelines = async.await(self:pipelines_async()())
--
--     local results = {}
--     for i, pipeline in ipairs(pipelines) do
--       local workflows = async.await(self:workflows_async(pipeline)())
--       results[i] = { pipeline = pipeline, workflows = workflows }
--     end
--
--     return results
--   end)
-- end

return API
