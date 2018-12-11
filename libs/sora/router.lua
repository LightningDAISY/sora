local SoraRouter = {}

function SoraRouter.new(o, req, controllerConfig)
	o = o or {}
	o.controllerConfig = controllerConfig
	-- o.rediskey = "LuaRouter"

	local base = require "sora.base"
	local parent = base:new(req)
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	o.rediskey = o.config.router.rediskey
	return o
end

function SoraRouter:_isExcludeUri(uri)
	if self.config.auth.userExcludeURI then
		local offset = uri:find("^" .. self.config.auth.userExcludeURI)
		if offset then return true end
	end
	return false
end

--
-- @uri ex. /admin/project/
--
function SoraRouter:uriHasConfig(uri)
	local matchedString = nil
	if self:_isExcludeUri(uri) then return end
	for matchString, conf in pairs(self.controllerConfig) do
		local offset,length = uri:find("^" .. matchString)
		if offset == 1 then
			if matchedString then
				if #matchedString < #matchString then
					matchedString = matchString
				end
			else
				matchedString = matchString
			end
		end
	end
	return self.controllerConfig[matchedString]
end

function SoraRouter:redisConnect()
	local ModelRedis = require "sora.model.redis"
	local redis = ModelRedis:new()
	redis:redisConnectAnother({
		host = self.config.redis.hostname,
		port = self.config.redis.port,
	})
	return redis
end

function SoraRouter:getRouteByVariable(requestedUri)
	local util = require "sora.util"
	local parts = util.split(requestedUri, "/")
	local lastURI = ""
	local nextURI = ""

	for i=#parts, 2, -1 do
		local longestUri = table.concat(parts, "/") .. "/"
		if _G.routeCache[longeestUri] then
			lastURI = _G.routeCache[longeestUri]
			break
		end
		nextURI = longestUri
		table.remove(parts, i)
	end
	return {lastURI, nextURI}
end

function SoraRouter:getRouteByRedis(requestedUri)
	local scriptBody = [=[
local function split(str,pattern,limiter)
	limiter = limiter or nil
	pattern = "(.-)" .. "(" .. pattern .. ")"
	local result = {}
	local offset = 0;
	local counter = 1
	if limiter == 1 then
		table.insert(result, str)
		return result
	end
	for part,sep in string.gmatch(str, pattern) do
		counter = counter + 1
		offset = offset + string.len(part) + string.len(sep)
		table.insert(result, part)
		if limiter and limiter <= counter then
			break
		end
	end
	if(string.len(str) > offset) then
		table.insert(result, string.sub(str,offset + 1))
	end
	return result
end

local parts = split(ARGV[1], "/")
local redisfield = ""
local lastURI = ""
local nextURI = ""

for i=#parts, 2, -1 do
	local redisfield = table.concat(parts, "/") .. "/"
	local rtn   = redis.call("hscan", "LuaRouter", 0, "MATCH", redisfield)
	if rtn[2][1] then
		lastURI = rtn[2][1]
		break
	end
	nextURI = redisfield
	table.remove(parts, i)
end

return {lastURI, nextURI}
	]=]
	scriptBody = scriptBody:gsub("\r?\n", " "):gsub("\t", " ")
	local redis = self:redisConnect()
	if not redis then throw("cannot connect redis!!") end
	local redishash = redis:loadScript(scriptBody, "router")
	return redis:evalsha("router", { requestedUri })
end

function SoraRouter:autoRouteCache()
	local controllerDir = _G.BaseDir .. "/" .. self.config.dir.controller
	local util = require "libs.sora.util"
	local replacedURI = self.req:path():gsub(self.config.uri.base, "")
	local replacedURIs = util.split(replacedURI, "%?", 2)
	if not replacedURIs[1] then replacedURIs[1] = "/" end
	replacedURI = replacedURIs[1]:gsub("/$", "") .. "/"


	-- remove & set extension(s)
	self.req.format = nil
	local method,extension = replacedURI:match("([^/%.]+)(%.[^/]+)/$")
	if extension then
		replacedURI = replacedURI:gsub(extension .. "/$", "/")
		self.req.format = extension
	end

	local parts = util.split(replacedURI, "/")
	table.remove(parts,1) -- shift

	if #parts < 1 then
		parts = { "index" }
	end

	if parts[#parts]:match("%.") then
		local names = util.split(parts[#parts], "%.", 2)
		parts[#parts]   = names[1]
		self.req.format = parts[2]
	end

	local result = nil
	if self.rediskey then
		result = self:getRouteByRedis(replacedURI)
	else
		result = self:getRouteByVariable(replacedURI)
	end
	if not result then return nil end
	local lastURI = result[1]
	local nextURI = result[2]

	local lastFilePath = controllerDir .. lastURI:gsub("/$", "") .. ".lua"

	-- GC BEGIN
	if lastURI:len() == replacedURI:len() then
		--実体なし
		if not util.fileExists(lastFilePath) then
			if self.rediskey then
				redis:hdel(self.rediskey, lastURI)
			else
				_G.routeCache[lastURI] = nil
			end
			return nil
		end
	elseif lastURI:len() > replacedURI:len() then
		return nil
	else
		--実体あり
		if util.fileExists(lastFilePath) then
			--次の実体あり
			if nextURI:len() > 0 then
				local nextFilePath = controllerDir .. nextURI:gsub("/$", "") .. ".lua"
				if util.fileExists(nextFilePath) then
					return nil
				end
			end
		--実体なし
		else
			return nil
		end
	end
	-- GC END

	local paramString = replacedURI:gsub(lastURI, "/")
	local params = util.split(paramString, "/")
	table.remove(params,1)

	local requirePath = self.config.dir.controller .. lastURI:gsub("/$", ""):gsub("/", ".")
	local controllerClass = require(requirePath)
	local controller = controllerClass:new(self.req)

	--move format
	local sepMethod,sepExtension = params[1]:match("([^/]+)(%.[^/]+)$")
	if not sepMethod then
		sepMethod = params[1]
	end
	if sepExtension then
		self.req.format = extension
	end

	--find method
	if controller[sepMethod] then
		if sepExtension then self.req.format = sepExtension end
		method = sepMethod
		table.remove(params, 1)
	elseif controller["index"] then
		method = "index"
	else
		return
	end

	if controller._cannotAccess(controller, method) then return nil end

	--set authtype & role
	local uriconf,role = self:uriHasConfig(replacedURI)
	local authType = nil
	local role     = nil
	if uriconf then
		authType = uriconf.authType
		role     = uriconf.role
	else
		authType = nil
		role     = 10
	end
	return controller, method, params, authType, role
end

-- local controller, method, params, authType, controllerRole = this:autoRoute()
--
-- 1. 最大マッチでControllerファイル file1.lua を探し
-- 2. 次の文字列param1をメソッド評価
--   2-1. function param1があればparam1(param2, param3)
--   2-2. function param1がなければindex(param1, param2, param3)
--   2-3. indexも無ければ404
--
function SoraRouter:autoRoute()
	local util = require "libs.sora.util"
	local replacedUri = self.req:path():gsub(self.config.uri.base, "")
	local replacedUris = util.split(replacedUri, "%?")
	replacedUri = replacedUris[1]
	replacedUri = replacedUri or "/"

	-- remove & set extension(s)
	local method,extension = replacedUri:match("([^/%.]+)(%.[^/]+)/$")
	if extension then
		replacedUri = replacedUri:gsub(extension .. "/$", "/")
		self.req.format = extension
	end
	
	local parts = util.split(replacedUri, "/")
	table.remove(parts,1) -- shift

	if #parts < 1 then
		parts = { "index" }
	end

	local path   = ""
	local requirePath = nil
	local method = nil
	local params = {}
	local loopNum = #parts
	for i=1, loopNum do
		path = _G.BaseDir .. "/" ..
			   self.config.dir.controller .. "/" ..
			   table.concat(parts, "/")
		if util.fileExists(path .. ".lua") then
			--begin cache
			if self.rediskey then
				local redis = self:redisConnect()
				redis:hset(self.rediskey, "/" .. table.concat(parts, "/") .. "/", "1")
				--end cache
			else
				_G.routeCache["/" .. table.concat(parts, "/") .. "/"] = 1
			end
			requirePath = self.config.dir.controller .. "." .. table.concat(parts, ".")
			break
		end
		table.insert(params, table.remove(parts, #parts))
	end
	if not requirePath then return end

	local controllerClass = require(requirePath:lower())
	if not controllerClass then return end

	local controller = controllerClass:new(self.req)

	util.reverse(params)

	--move format
	local sepMethod,sepExtension
	if params[1] then
		sepMethod,sepExtension = params[1]:match("([^/]+)(%.[^/]+)$")
		if not sepMethod then
			sepMethod = params[1]
		end
		if sepExtension then
			self.req.format = extension
		end
	else
		sepMethod = params[1]
	end

	--find method
	if controller[sepMethod] then
		if sepExtension then self.req.format = sepExtension end
		method = sepMethod
		table.remove(params, 1)
	elseif controller["index"] then
		method = "index"
	else
		return
	end

	if controller._cannotAccess(controller, method) then return end

	--set authtype & role
	replacedUri = replacedUri .. "/"
	replacedUri = replacedUri:gsub("//", "/")
	local uriconf = self:uriHasConfig(replacedUri)
	local authType = nil
	local role     = nil
	if uriconf then
		authType = uriconf.authType
		role     = uriconf.role
	else
		authType = nil
		role     = 10
	end
	return controller, method, params, authType, role
end

function SoraRouter:route()
	local util   = require "sora.util"
	local path   = string.gsub(self.req:path(), self.config.uri.base, "")
	local paths  = util.split(path, "/", 4)
	local class  = paths[2] or "index"
	local role   = 10
	local method = paths[3] or "index"
	local param  = paths[4] or nil
	local authType = nil
	local params = {}

	if method == "new" then throw(404, "Invalid Request") end
	if method:sub(1,1) == "_" then throw(404, "Invalid Request") end
	if param then params = util.split(param, "/") end

	if self.controllers[class] then
		if self.controllers[class].role then
			role = self.controllers[class].role
		end
		authType  = self.controllers[class].auth
		class     = util.toPascalCase(self.controllers[class].name)
	else
		class = nil
	end

	return class, method, params, authType, role
end

return SoraRouter
