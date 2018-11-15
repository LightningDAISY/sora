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
		self.user = { projectId = defaultProjectId }
	end
	self.stash.isLogin = self.isLogin
	self.stash.user = self.user
	if self.weblog then
		self.weblog:setParams(self.user.userId, self.user.projectId)
	end
	return true
end
function C:_getProject(projectId)
	local Project = require "models.projectBase"
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
	local UserBase = require "models.userBase"
	local base = UserBase:new()
	return base:getUserData(userId)
end

function C:_getUserDetail(userId)
	userId = userId or self.user.user_id
	if not userId then return end
	local UserDetail = require "models.userDetail"
	local detail = UserDetail:new()
	return detail:getUserData(userId)
end

function C:_getUserInfo(userId)
	local base = self:_getUserBase(userId)
	if not base then return end
	local detail = self:_getUserDetail(userId) or {}
	for key,val in pairs(detail) do
		base[key] = val
	end
	return base
end

--
-- user_session
--
-- @return user_session record || nil
--
function C:_getUserSession(sessionId)
	sessionId = sessionId or self:_getSessionIdByCookie(self.config.session.uname)
	if not sessionId then return end

	-- JWT BEGIN
	if self.config.session.jwtSecret then
		local ObjectJwt = require "objects.jwt"
		local jwt = ObjectJwt:new()
		return jwt:verify(sessionId, self.config.session.jwtSecret)
	-- JWT END
	else
		local UserSession = require "models.userSession"
		local session = UserSession:new()
		return session:get(sessionId)
	end
end

function C:_setUserSession(userId, projectId)
	local sessionId = nil
	if self.config.session.jwtSecret then
		local ObjectJwt = require "objects.jwt"
		local jwt = ObjectJwt:new()
		sessionId = jwt:sign(
			{
				userId = userId, 
				projectId = projectId
			},
			self.config.session.jwtSecret
		)
	else
		local UserSession = require "models.userSession"
		local session = UserSession:new()
		sessionId = session:set(userId, projectId)
	end
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
	
	if not self.config.session.jwtSecret then
		local userSession = require "models.userSession"
		local session = userSession:new()
		session:remove(sessionId)
	end

	self:_setCookies(
		{
			{ name = self.config.session.uname, value = sessionId }
		},
		self.config.session.path,
		ngx.cookie_time(0)
	)
end

return C

