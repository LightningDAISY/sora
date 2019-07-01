local C = {}
local cjson = require "cjson"
local Contact = require 'models.contact'

function C.new(o, req)
	o = o or {}
	o.req = req
	local ParentController = require "controllers.user.base"
	local parent = ParentController:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:isValid(param)
	local messages = {}
	local code = true
	if not param.name or #param.name < 1 then
		table.insert(messages, "name is requied.")
		code = false
	end
	if not param.message or #param.message < 1 then
		table.insert(messages, "message is requied")
		code = false
	end
	return code, messages
end

function C:index(params)
	ngx.header["Content-Type"] = "application/json"
	local methodUpper = self.req.method:upper()

	if "POST" == methodUpper then
		local reqParams = self.req:params()
		local code, messages = self:isValid(reqParams)
		if not code then
			ngx.say(cjson.encode({ result = "NG", message = messages[1] }))
			return
		end
		local contact = Contact:new()
		local res = contact:add({
			name    = reqParams.name,
			email   = reqParams.email,
			message = reqParams.message,
		})
		if res then
			self:_errorLog(self:_dump(res))
			ngx.say(cjson.encode({ result = "OK" }))
			return
		end
	end
	ngx.say(cjson.encode({ result = "NG" }))
end

return C
