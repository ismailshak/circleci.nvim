--#################### ############ ####################
--#################### Async Region ####################
--#################### ############ ####################

local co = coroutine

-- use with wrap
local pong = function(func, callback)
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
local wrap = function(func)
  assert(type(func) == "function", "type error :: expected func")
  local factory = function(...)
    local params = { ... }
    local thunk = function(step)
      table.insert(params, step)
      return func(unpack(params))
    end
    return thunk
  end
  return factory
end

-- many thunks -> single thunk
local join = function(thunks)
  local len = table.getn(thunks)
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
local await = function(defer)
  assert(type(defer) == "function", "type error :: expected func")
  return co.yield(defer)
end

local await_all = function(defer)
  assert(type(defer) == "table", "type error :: expected table")
  return co.yield(join(defer))
end

local A = {
  sync = wrap(pong),
  wait = await,
  wait_all = await_all,
  wrap = wrap,
}

local uv = vim.loop

--#################### ########### ####################
--#################### Sync Region ####################
--#################### ########### ####################

-- sync version of pong
local pong = function(thread)
  local nxt = nil
  nxt = function(cont, ...)
    if not cont then
      return ...
    else
      return nxt(co.resume(thread, ...))
    end
  end
  return nxt(co.resume(thread))
end

local sync_example = function()
  local thread = co.create(function()
    local x = co.yield(1)
    print(x)
    local y, z = co.yield(2, 3)
    print(y, z)
    local f = co.yield(4)
    print(f)
  end)

  pong(thread)
end

--#################### ############ ####################
--#################### Async Region ####################
--#################### ############ ####################

local timeout = function(ms, callback)
  local timer = uv.new_timer()
  uv.timer_start(timer, ms, 0, function()
    uv.timer_stop(timer)
    uv.close(timer)
    callback()
  end)
end

-- typical nodejs / luv function
local echo_2 = function(msg1, msg2, callback)
  -- wait 200ms
  timeout(200, function()
    callback(msg1, msg2)
  end)
end

-- thunkify echo_2
local e2 = A.wrap(echo_2)

local async_tasks_1 = function()
  return A.sync(function()
    local x, y = A.wait(e2(1, 2))
    print(x, y)
    return x + y
  end)
end

local async_tasks_2 = function(val)
  return A.sync(function()
    -- await all
    local w, z = A.wait_all({ e2(val, val + 1), e2(val + 2, val + 3) })
    print(unpack(w))
    print(unpack(z))
    return function()
      return 4
    end
  end)
end

local async_example = function()
  return A.sync(function()
    -- composable, await other async thunks
    local u = A.wait(async_tasks_1())
    local v = A.wait(async_tasks_2(3))
    print(u + v())
  end)
end

--#################### ############ ####################
--#################### Loops Region ####################
--#################### ############ ####################

-- avoid textlock
local main_loop = function(f)
  vim.schedule(f)
end

local vim_command = function()
  vim.api.nvim_command([[echom 'calling vim command']])
end

local textlock_fail = function()
  return A.sync(function()
    A.wait(e2(1, 2))
    vim_command()
  end)
end

local textlock_succ = function()
  return A.sync(function()
    A.wait(e2(1, 2))
    A.wait(main_loop)
    vim_command()
  end)
end
