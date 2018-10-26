local SoraConfig = {}

function SoraConfig.new(o)
	o = o or {}
	return o
end

function SoraConfig:loadconfig(filename)
	local util = require("sora.util")
	return util.loadJS(filename)
end

return SoraConfig
