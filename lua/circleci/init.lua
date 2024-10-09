local M = {}

local A = {}

local co = coroutine

-- use with wrap
function A.pong(func, callback)
  assert(type(func) == "function", "type error :: expected func")

  local thread = co.create(func)
  local step = nil

  step = function(...)
    local stat, ret = co.resume(thread, ...)
    assert(stat, ret)
    if co.status(thread) == "dead" then
      (callback or function() end)(ret)
    else
      assert(type(ret) == "function", "type error :: expected func")
      ret(step)
    end
  end

  step()
end

-- use with pong, creates thunk factory
function A.wrap(async_func)
  assert(type(async_func) == "function", "type error :: expected func")

  local factory = function(...)
    local params = { ... }
    local thunk = function(callback)
      table.insert(params, callback)
      return async_func(unpack(params))
    end
    return thunk
  end

  return factory
end

-- many thunks -> single thunk
function A.join(thunks)
  local len = #thunks
  local done = 0
  local acc = {}

  local thunk = function(step)
    if len == 0 then
      return step()
    end
    for i, tk in ipairs(thunks) do
      assert(type(tk) == "function", "thunk must be function")
      local callback = function(...)
        acc[i] = { ... }
        done = done + 1
        if done == len then
          step(unpack(acc))
        end
      end
      tk(callback)
    end
  end
  return thunk
end

-- sugar over coroutine
function A.await(defer)
  assert(type(defer) == "function", "type error :: expected func")
  return co.yield(defer)
end

function A.await_all(defer)
  assert(type(defer) == "table", "type error :: expected table")
  return co.yield(A.join(defer))
end

A.sync = A.wrap(A.pong)

M.fetch_pipeline = A.wrap(function(callback)
  local timer = vim.uv.new_timer()
  timer:start(1000, 0, function()
    timer:stop()
    timer:close()
    callback("Hello, World!")
  end)
end)

M.fetch_workflows = A.wrap(function(pipeline_id, callback)
  local timer = vim.uv.new_timer()
  timer:start(1500, 0, function()
    timer:stop()
    timer:close()
    callback("Hello, World!" .. pipeline_id)
  end)
end)

---Initializes the plugin
---@param opts? circleci.Config
function M.setup(opts)
  -- M.fetch(function(data)
  --   print(data)
  -- end)
  -- A.sync(function()
  --   local data = A.await(M.fetch_pipeline())
  --   print(data)
  --   local data2 = A.await(M.fetch_workflows("123"))
  --   print(data2)
  --
  --   return { data, data2 }
  -- end)(function(data)
  --   print(vim.inspect(data))
  -- end)

  -- M.fetch(function(data)
  --   print(data)
  -- end)
  local config = require("circleci.config").merge(opts)

  require("circleci.commands").setup()

  if not config.ui.enable then
    return
  end

  require("circleci.ui").setup(config)
end

return M
