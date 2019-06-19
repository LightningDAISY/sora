local C = {}
local cjson = require "cjson"
local Phrase = require 'models.authoritarian'

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
	if not param.message or #param.message < 1 then
		table.insert(messages, "message is requied")
		code = false
	end
	return code, messages
end

function C:random()
	ngx.header["Content-Type"] = "application/json"
	local phrase = Phrase:new()
	local res = phrase:selectQuery("SELECT * FROM authoritarian ORDER BY RAND() LIMIT 1")
	if res and res[1] and res[1].message then
		res[1].result = "OK"
		ngx.say(cjson.encode(res[1]))
	else
		ngx.say(cjson.encode({ result = "NG" }))
	end
end

function C:index(params)
	ngx.header["Content-Type"] = "application/json"
	local methodUpper = self.req.method:upper()

	if "POST" == methodUpper then
		local reqParams = self.req:params()
		local code, messages = self:isValid(reqParams)
		if not code then
			ngx.say(cjson.encode({ result = "NG", message = "本文は必須です。" }))
			return
		end
		local phrase = Phrase:new()
		local res = phrase:add({
			author  = reqParams.author,
			title   = reqParams.title,
			company = reqParams.company,
			message = reqParams.message
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
