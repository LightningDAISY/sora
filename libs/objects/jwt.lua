local O = {}
local jwt = require "resty.jwt"
local AimiBase = require "sora.base"
setmetatable(O, { __index = AimiBase:new() })

function O:new()
	local ins = {}
	setmetatable(
		ins,
		{
			__index = O
		}
	)
	return ins
end

function O:sign(object, secret)
	object = object or {}
	secret = secret or self.config.session.jwtSecret
	if not secret then return end
	return jwt:sign(
		secret,
		{
			header = {
				typ = "JWT",
				alg = "HS256"
			},
			payload = object
		}
	)
end

function O:verify(token, secret)
	secret = secret or self.config.session.jwtSecret
	if not secret then return end
	local obj = jwt:verify(
		secret,
		token
	)
	if obj then return obj.payload end
end

return O
