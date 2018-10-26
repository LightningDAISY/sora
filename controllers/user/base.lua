local C = {}

function C.new(o, req)
	o = o or {}
	o.stash = {}
	o.templateFileName = ""
	o.errorMessages = {}
	local Controller = require "sora.controller"
	local parent = Controller:new(req)
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:_setLogindata()
	local defaultProjectId = 1
	if not self.isLogin then
		self.user = { project_id = defaultProjectId }
	end
	self.stash.isLogin = self.isLogin
	self.stash.user = self.user
	if self.weblog then
		self.weblog:setParams(self.user.user_id, self.user.project_id)
	end
	return true
end
function C:_getProject(projectId)
	local Project = require "models.project_base"
	local model = Project:new()
	return model:lookup(projectId)
end

function C:_getProjectId()
	local projectId = self.projectId
	if projectId < 1 then
		local inputId = self.req:params().projectId
		if inputId and tonumber(inputId) > 0 then
			projectId = inputId
		end
	end
	return projectId
end

function C:_userAuth(conf, params)
	local sessionRecord = self[conf.session.method](self)
	self.isLogin = true
	if not sessionRecord then
		self.isLogin = false
		if conf.auth.fallback then
			ngx.redirect(self.config.base.uri .. conf.auth.fallback)
		end
	end
	return sessionRecord
end

function C:_getUserBase(userId)
	userId = userId or self.user.user_id
	if not userId then return end
	local UserBase = require "models.user_base"
	local base = UserBase:new()
	return base:getUserData(userId)
end

function C:_getUserDetail(userId)
	userId = userId or self.user.user_id
	if not userId then return end
	local UserDetail = require "models.user_detail"
	local detail = UserDetail:new()
	return detail:getUserData(userId)
end

--
-- user_session
--
-- @return user_session record || nil
--
function C:_getUserSession(sessionId)
	sessionId = sessionId or self:_getSessionIdByCookie(self.config.session.uname)
	if not sessionId then return end
	local UserSession = require "models.user_session"
	local session = UserSession:new()
	return session:get(sessionId)
end

function C:_setUserSession(userId, projectId)
	local UserSession = require "models.user_session"
	local session = UserSession:new()
	local sessionId = session:set(userId, projectId)
	self:_setCookies(
		{
			{ name = self.config.session.uname, value = sessionId }
		},
		self.config.session.path,
		ngx.cookie_time(self:_getTime() + self.config.session.expireSec)
	)
	return sessionId
end

function C:_deleteUserSession(sessionId)
	sessionId = sessionId or self:_getSessionIdByCookie(self.config.session.uname)
	if not sessionId then return end
	local userSession = require "models.user_session"
	local session = userSession:new()
	session:remove(sessionId)

	self:_setCookies(
		{
			{ name = self.config.session.uname, value = sessionId }
		},
		self.config.session.path,
		ngx.cookie_time(0)
	)
end

return C

