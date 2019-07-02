local C = {}
local util = require "sora.util"
local FileManager =  require "sora.filemanager"

function C.new(o, req)
  o = o or {}
  o.req = req or {}
  o.fileManager = FileManager:new(o.req.format)
  local parent = require("sora.controller"):new()
  setmetatable(
    o,
    {
      __index = parent
    }
  )
  return o
end

function C:summaryAll(params)
  local requestPath = table.concat(params, "/")
  local list = self.fileManager:listAllYamls(requestPath)
  ngx.header["X-Parent-Path"] = self.fileManager:getParentUri(requestPath)
  ngx.header["Content-Type"] = "application/json"
  ngx.say(util.toJSON(list))
end

function C:list(params)
  local requestPath = table.concat(params, "/")
  local list = self.fileManager:list(requestPath)
  ngx.header["X-Parent-Path"] = self.fileManager:getParentUri(requestPath)
  ngx.header["Content-Type"] = "application/json"
  ngx.say(util.toJSON(list))
end

return C

