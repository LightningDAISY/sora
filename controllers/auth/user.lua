local C = {}

local Util = require "sora.util"
local jwt  = require "resty.jwt"

function C.new(o, req)
	o = o or {}
	o.req = req
	local User = require "objects.user"
	o.user = User:new()
	o.ControllerMethods = ControllerMethods
	local ControllerAuth = require "controllers.user.base"
	local parent = ControllerAuth:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:isNotEnough(params)
	if	not params.username or
		not params.projectid or
		not params.password or
		not params.nickname or
		not params.mailAddress then
		return true
	end
end

function C:setReqParams(reqParams)
	self.stash.title        = "sign up"
	self.stash.username     = reqParams.username
	self.stash.password     = reqParams.password
	self.stash.projectid    = reqParams.projectid
	self.stash.nickname     = reqParams.nickname
	self.stash.mailAddress  = reqParams.mailAddress
	if self.req.format == ".json" then
		self.stash.result = "NG"
		ngx.say(cjson.encode(self.stash))
	else
		self.templateFileName   = "auth/user/signup.tpl"
	end
end

function C:_signup()

	local reqParams = self.req:params()
	if self:isNotEnough(reqParams) then return self:setReqParams(reqParams) end
	local isSuccess = self.user:signup(reqParams)
	if isSuccess then
		self.stash.primaryMessages = { "created" }
	else
		self.stash.errorMessages = self.user.errors
		return self:setReqParams(reqParams)
	end
	self.stash.title       = "sign in"
	self.stash.username    = reqParams.username
	self.stash.password    = reqParams.password
	self.stash.projectid   = reqParams.projectid
	self.stash.mailAddress = reqParams.mailAddress
	if self.req.format == ".json" then
		self.stash.result = "OK"
		ngx.say(cjson.encode(self.stash))
	else
		self.templateFileName  = "auth/user/login.tpl"
	end
end

function C:_login(reqParams)
	local isSuccess = self.user:signin(
		reqParams.username,
		reqParams.projectid,
		reqParams.password
	)
	if isSuccess then
		self:_setUserSession(
			self.user.base.userId,
			self.user.base.projectId
		)
		return ngx.redirect(
			self.config.auth.userRedirectURI
		)
	end
	self.stash.errorMessages = self.user.errors
	self.stash.username  = reqParams.username
	self.stash.password  = reqParams.password
	self.stash.projectid = reqParams.projectid
end

function C:login(params)
	self:_deleteUserSession()
	if self.req.method == "POST" then
		local reqParams = self.req:params()
		if reqParams.issignup and #reqParams.issignup > 0 then
			return self:_signup()
		else
			self:_login(reqParams)
		end
	end
	self.stash.title = "sign in"
	if self.req.format == ".json" then
		ngx.say(cjson.encode(self.stash))
	else
		self.templateFileName = "auth/user/login.tpl"
	end
end

function C:logout()
	self:_deleteUserSession()
	ngx.redirect(self.config.auth.userLoginURI)
end

function C:forbidden(params)
	self.stash = {
		message  = "権限不足です",
	}
	self.templateFileName = "auth/user/forbidden.tpl"
end

return C
