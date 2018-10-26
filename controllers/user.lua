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
	local nickname = params[1]
	if not nickname then throw(400) end
	self:_setLogindata()
	local User = require "objects.user"
	local user = User:new()
	self.stash.userdata = user:byNickname(nickname)
	if not self.stash.userdata then throw(404) end
	self.templateFileName = "user/info.tpl"
end

function C:profile(params)
	if not self:_setLogindata() then
		return ngx.redirect(self.config.auth.userRedirectURI)
	end

	if self.req.method == "POST" then
		self.stash.reqParams = self.req:params("multipart")
		if self.stash.reqParams and self.stash.reqParams.update then
			local User = require "objects.user"
			local user = User:new()
			local res  = user:modify({
				user_id     = self.user.user_id,
				project_id  = self.user.project_id,
				nickname    = self.stash.reqParams.nickname,
				password    = self.stash.reqParams.password,
				personality = self.stash.reqParams.personality,
				icon        = self.stash.reqParams.icon,
			})
			if res then
				self.stash.primaryMessages = { "updated" }
			else
				self.stash.errorMessages = user.errors
			end
		end
	end
	self.stash.reqParams = self.stash.reqParams or {}
	self.stash.base   = self:_getUserBase()
	self.stash.detail = self:_getUserDetail()
	self.templateFileName = "mypage/profile.tpl"
end

return C
