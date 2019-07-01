local C = {}
local rex = require("rex_pcre")

function C.new(o, req)
	o = o or {}
	o.req = req
	local ParentController = require "sora.controller"
	local parent = ParentController:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:index(params)
	local methodLower = self.req.method:lower()
	if methodLower == "get" then

	else
		-- POST
		ngx.req.read_body()
		local reqBody = ngx.req.get_body_data()
		reqBody = rex.gsub(reqBody, '<div class="ace_line".+?>',"\n")
		reqBody = rex.gsub(reqBody, "<.+?>", "")
		reqBody = rex.gsub(reqBody, "&nbsp;", " ")
		ngx.say(reqBody)
	end
end

return C
