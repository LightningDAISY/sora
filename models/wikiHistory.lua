local M = {}
-- table information begin
local tableName = 'wikiHistory'
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

function M:add(data)
	local res,err = self:insert(data, true)
	if res then return res end
	self.errorMessage = err
	return false
end

function M:list(entryId, limit)
	limit = limit or 10
	return self:select(
		{ "entryId =", entryId },
		{ "createdAt", "DESC" },
		limit
	)
end

return M
