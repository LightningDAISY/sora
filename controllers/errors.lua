local C = {}

function C.new(o, req)
	o = o or {}
	o.req = req
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

function C:index(statusCode, err, trace)
	local Constant = require "sora.constant"
	local statusString = Constant.httpStatusStringByCode(statusCode) or "Unknown error"

	if self.config.environment.name == "devel" then
		self.templateFileName = "errors.devel.tpl"
	else
		self.templateFileName = "errors.tpl"
	end
	self.stash = {
		statusCode   = statusCode,
		statusString = statusString,
		err          = err,
		trace        = trace,
	}
end

return C
