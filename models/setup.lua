local M = {}
local tableName = ""
local Util = require "sora.util"

function M.new(o,isSingleton,isSetup)
	local ins
	local SoraModelMysql = require "sora.model.mysql"
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
	local returnCode = ins:mysqlConnectService(isSingleton, isSetup)
	if returnCode then return ins else return false end
end

function M:isExists(tableName)
	return self:describe(tableName)
end

return M
