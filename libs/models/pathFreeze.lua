local M = {}

-- table information begin
local tableName = "pathFreeze"
-- table information end

local Util = require "sora.util"

function M.new(o,isSingleton)
	local ins
	local SoraModelMysql = require 'sora.model.mysql'
	if isSingleton then
		setmetatable(M, { __index = SoraModelMysql:new() })
		ins = { tableName = tableName }
		setmetatable(
			ins,
			{
				__index = M
			}
		)
	else
		ins = o or {}
		ins.tableName = tableName
		setmetatable(
			ins,
			{
				__index = SoraModelMysql:new()
			}
		)

	end
	ins:mysqlConnectService(isSingleton)
	return ins
end

return M
