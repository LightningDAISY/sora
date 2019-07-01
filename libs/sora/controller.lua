local SoraController = {}

function SoraController.new(o, req)
	o = o or {}
	o.stash = {}
	o.templateFileName = ""
	o.ControllerActions = nil
	local parent = require("sora.base"):new(req)
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
-- 3. ControllerActionssがあればその他を除外
--
function SoraController:_cannotAccess(action)
	if action:sub(1,1) == "_" then return true end
	if action == "new" then return true end
	if not self.ControllerActions then return false end
	if not self.ControllerActions[action] then return true end
	return false
end

function SoraController:_getSessionIdByCookie(cookieName)
	local cookie = self:_getCookies()
	return cookie[cookieName]
end

return SoraController
