local C = {}

local ControllerMethods = {
	index = true,
	init  = true,
}

function C.new(o, req)
	o = o or {}
	o.req = req
	o.ControllerMethods = ControllerMethods
	local ControllerAuth = require "controllers.admin.base"
	local parent = ControllerAuth:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:init()
	local AdminBase = require "models.admin_base"
	local base = AdminBase:new()
	self.stash.message = ""
	self.templateFileName = "auth/init.tpl"

	if not base:hasNoRecord() then
		ngx.redirect(self.config.base.uri .. self.config.auth.uri .. "/admin")
		return
	end

	local reqParams = self.req:params()
	if self.req.method == "POST" then
		-- CREATE root-account if not exists
		local Admin = require "objects.admin"
		local admin = Admin:new(1,1) -- dummy (is not used
		local adminId,errorMessage = admin:init(reqParams.userid, reqParams.password)
		if not adminId then
			self.stash.message = admin.errorMessage or "unknown error"
		end

		-- CREATE sandbox if not exists
		local Project = require "objects.project"
		local project = Project:new(1)
		if not project:init(adminId) then
			self.stash.message = project.errorMessage
		end

		if #self.stash.message < 1 then
			ngx.redirect(self.config.base.uri .. self.config.auth.uri .. "/admin")
		end
	end
end

function C:index(params)
	if params[1] == "logout" then
		self:_deleteAdminSession()
		ngx.redirect(self.config.auth.adminRedirectURI)
		return
	end

	local AdminBase = require "models.admin_base"
	local base = AdminBase:new()
	if base:hasNoRecord() then return self:init() end

	local reqParams = self.req:params()
	local errorMessage = ""

	if reqParams.userid and reqParams.password then
		local rows = base:select(
			{
				"admin_name =", reqParams.userid,
				"password =",   reqParams.password,
			}
		)
		-- admin_base is found.
		if #rows > 0 then
			adminId = rows[1].admin_id
			local adminProject = require "models.admin_project"
			project = adminProject:new()
			if reqParams.projectid then
				local rows = project:select(
					{
						"admin_id = ",   adminId,
						"project_id = ", reqParams.projectid,
					}
				)
				if #rows > 0 then
					self:_setAdminSession(adminId, reqParams.projectid)
					return ngx.redirect(self.config.auth.adminRedirectURI)
				end
			end
		end
		errorMessage = self.config.message.authError
	end
	local project = require "models.project_base"
	local ins = project:new()
	local projects = ins:get()

	self.stash = {
		title    = "Admin > auth",
		authUri  = self.config.base.uri .. self.config.auth.uri .. "/admin",
		userid   = reqParams.userid,
		password = reqParams.password,
		message  = errorMessage,
		projects = projects,
	}
	self.templateFileName = "auth/admin.tpl"
	return self
end

function C:forbidden(params)
	self.stash = {
		message  = "権限不足です",
	}
	self.templateFileName = "auth/forbidden.tpl"
end

return C
