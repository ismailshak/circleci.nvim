local M = {}

local uv = vim.uv or vim.loop

---Decodes JSON data
---@param data string stringified JSON data
---@return any
function M.decode_json(data)
  return vim.schedule(vim.fn.json_decode(data))
end

---Fetches data from the given URL
---@param url string
---@param headers? table<string, string> Optional headers to send with the request
---@param callback fun(err: string|nil, data: string|nil)
function M.request(url, headers, callback)
  local handle, spawn_err
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local stdout_data = ""
  local stderr_data = ""

  local function onread_stdout(err, chunk)
    if err then
      callback(err, nil)
      return
    end

    if chunk then
      stdout_data = stdout_data .. chunk
    end
  end

  local function onread_stderr(err, chunk)
    if err then
      callback(err, nil)
      return
    end
    if chunk then
      stderr_data = stderr_data .. chunk
    end
  end

  local function on_exit(code, signal)
    uv.close(handle)
    uv.close(stdout)
    uv.close(stderr)

    if code == 0 then
      callback(nil, stdout_data)
    else
      -- Handle error and send it to the callback
    end
  end

  local args = { url, "-s", "-S", "-L" }
  if headers then
    for k, v in pairs(headers) do
      table.insert(args, "-H")
      table.insert(args, k .. ": " .. v)
    end
  end
  handle, _, spawn_err = uv.spawn("curl", { args = args, stdio = { nil, stdout, stderr } }, on_exit)

  if not handle then
    callback("Spawn failed: " .. spawn_err, nil)
    return
  end

  uv.read_start(stdout, onread_stdout)
  uv.read_start(stderr, onread_stderr)
end

return M
