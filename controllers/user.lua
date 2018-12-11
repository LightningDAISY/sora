local C = {}
local cjson = require "cjson"
local Util = require "sora.util"

function C.new(o, req)
	o = o or {}
	o.req = req
	local Controller = require "controllers.user.base"
	local parent = Controller:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:info(params)
	if self.req.format then self:_errorLog("FORMAT " .. self.req.format) end
	ngx.header["Content-Type"] = "application/json"
	if self.user then
		local user = {}
		for key,val in pairs(self.user) do
			user[key] = val
		end
		user.password = nil
		user.result = "OK"
		ngx.say(cjson.encode(user))
	else
		throw(403, { result = "NG" })
	end
end

function C:mypage(params)
	if self.req.format == ".json" then
		ngx.header["Content-Type"] = "application/json"
		if not self.user then
			throw(403, { result = "NG" })
		end
		local user = {}
		for key,val in pairs(self.user) do
			user[key] = val
		end
		user.password = nil
		user.result = "OK"
		ngx.say(cjson.encode(user))
	else
		if not self.user then
			return ngx.redirect(self.config.auth.userLoginURI)
		end
		self.stash.user = self.user
		self.templateFileName = "user/mypage.tpl"
	end
end

function C:modify(params)
	if self.req.format == ".json" then
		ngx.header["Content-Type"] = "application/json"
		if not self.user then
			throw(403, { result = "NG" })
		end
	else
		if not self.user then
			return ngx.redirect(self.config.auth.userLoginURI)
		end
	end

	if self.req.method == "POST" then
		local User = require "objects.user"
		local user = User:new()
		local params = self.req:params()
		local newdata = {
			userId      = self.user.userId,
			projectId   = self.user.projectId,
			userName    = params.userName,
			nickname    = params.nickname,
			loginId     = params.loginId,
			password    = params.password,
			mailAddress = params.mailAddress,
			personality = params.personality,
		}
		user:modify(newdata)
		if self.req.format == ".json" then
			ngx.say(cjson.encode({ result = "OK"}))
			return
		else
			self.stash.user = newdata
		end
	else
		self.stash.user = self.user
	end
	self.templateFileName = "user/modify.tpl"
end

return C
