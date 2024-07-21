local api = {}
api.__index = api

function api.new()
  return api.init(setmetatable({}, api))
end

function api.decode_response(response)
  return vim.json.decode(response, { luanil = { object = true, array = true } })
end

function api.init(self)
  self.token = require("circleci.auth").get_api_token()
  self.base_url = "https://circleci.com/api/v2"
  return self
end

---@class CircleCIAPI_MeResponse
---@field name string
---@field login string
---@field id string

---@return CircleCIAPI_MeResponse
function api:me()
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

return api
