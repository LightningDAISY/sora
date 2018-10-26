local SoraController = {}

function SoraController.new(o, req)
	o = o or {}
	o.stash = {}
	o.templateFileName = ""
	o.ControllerMethods = nil
	local AdminLog = require "objects.log"
	o.adminLog = AdminLog:new()
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

--
-- 1. new除外
-- 2. _始まり除外
-- 3. ControllerMethodsがあればその他を除外
--
function SoraController:_cannotAccess(method)
	if method:sub(1,1) == "_" then return true end
	if method == "new" then return true end
	if not self.ControllerMethods then return false end
	if not self.ControllerMethods[method] then return true end
	return false
end

function SoraController:_getSessionIdByCookie(cookieName)
	local cookie = self:_getCookies()
	return cookie[cookieName]
end

return SoraController
