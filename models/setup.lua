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
	local desc = self:describe(tableName)
	self:_errorLog(self:_dump(desc))
	if desc[1] then return true else return false end
end

return M
