local SoraRouter = {}
local util = require "sora.util"
local routes = ngx.shared.routes

function SoraRouter.new(o, req)
  o = o or {}
  local base = require "sora.base"
  local parent = base:new(req)
  setmetatable(
    o,
    {
      __index = parent
    }
  )
  return o
end

function SoraRouter:getControllerUri()
  local replacedUri = self.req:path():gsub(self.config.uri.base, "")
  local replacedUris = util.split(replacedUri, "%?")
  local controllerUri = replacedUris[1] or "/"

  -- rescue extension(s)
  local action,extension = controllerUri:match("([^/%.]+)%.([^/]+)$")
  if extension then
    controllerUri = controllerUri:gsub("%." .. extension .. "$", "")
    self.req.format = extension
  end
  return controllerUri
end

--
-- parts = { "", "user", "list", "nobody", "over20", "true" } -- because split "/", "/user/list/nobody"...
-- if exists controller/user/list.lua then
--   return {
--     requirePath : "controller.user.list",
--     action      : "nobody",
--     params      : { "over20", "true" },
--   }
-- end
--
function SoraRouter:searchTheLongestController(parts)
  local path, requirePath, action
  local params = {}
  local partsNum = #parts

  local controllersDir = ngx.var.baseDir .. "/" .. 
    self.config.dir.ownLibs .. "/" .. 
    self.config.dir.controller .. "/"

  for i=1, partsNum do
    path = controllersDir .. table.concat(parts, "/") .. ".lua"
    if util.fileExists(path) then
      local controller = require(self.config.dir.controller .. "." .. table.concat(parts, ".")):new()
      action = params[#params]
      if controller[action] then
        if not controller._cannotAccess(controller, action) then
          table.remove(params, #params)
          requirePath = self.config.dir.controller .. "." .. table.concat(parts, ".")
          break
        end
      elseif controller["index"] then
        action = "index"
        if not controller._cannotAccess(controller, action) then
          requirePath = self.config.dir.controller .. "." .. table.concat(parts, ".")
          break
        end
      end
    end
    table.insert(params, table.remove(parts, #parts))
  end
  if requirePath then
    util.reverse(params)
    return {
      requirePath = requirePath:lower(),
      action = action,
      params = params,
    }
  end
end

function SoraRouter:getCache(path)
  local json = routes:get(path)
  return util.fromJSON(json)
end

function SoraRouter:setCache(path, object)
  local json = util.toJSON(object)
  routes:set(path, json)
end

function SoraRouter:deleteCache(path)
  routes:delete(path)
end

function SoraRouter:autoRouteCache()
  local controllerUri = self:getControllerUri()
  local controllerInfo = self:getCache(controllerUri)
  if not controllerInfo then return end
  local controller = require(controllerInfo.requirePath):new(self.req)
  return controller, controllerInfo.action, controllerInfo.params
end

-- local controller, action, params, authType, controllerRole = this:autoRoute()
--
-- 1. 最長マッチでControllerファイル file1.lua を探し
-- 2. 次の文字列param1をメソッド評価
--   2-1. function param1があればparam1(param2, param3)
--   2-2. function param1がなければindex(param1, param2, param3)
--   2-3. indexも無ければ404
--
function SoraRouter:autoRouteDyn()
  local controllerUri = self:getControllerUri()
  local parts = util.split(controllerUri, "/")
  table.remove(parts,1) -- shift

  -- set controller/index.lua if requested "/"
  if #parts < 1 then parts = { "index" } end

  local controllerInfo = self:searchTheLongestController(parts)
  if not controllerInfo then return end

  -- /file/list/example : {"params":["example"],"requirePath":"controllers.file","action":"list"}
  self:setCache(controllerUri, controllerInfo)
  local controller = require(controllerInfo.requirePath):new(self.req)
  return controller, controllerInfo.action, controllerInfo.params
end

function SoraRouter:autoRoute()
  local controller, action, params = self:autoRouteCache()
  if not controller then
    controller, action, params = self:autoRouteDyn()
  end
  if controller then
    return controller, action, params
  end
  return
end

return SoraRouter
