local M = {}
-- table information begin
local tableName = "userDetail"
-- table information end

local Util = require "sora.util"

function M.new(o,isSingleton)
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
	ins:mysqlConnectService(isSingleton)
	return ins
end

function M:getUserData(userId)
	local rows = self:select(
		{
			"userId = ", userId
		}
	)
	if not rows then return nil end
	return self:userdata2Empty(rows[1])
end

function M:modify(params)
	local updateSet = {}
	local has = false
	for i,key in ipairs({ "nickname", "mailAddress", "personality", "iconFilename" }) do
		if params[key] and #params[key] > 0 then
			updateSet[key] = params[key]
			has = true
		end
	end
	if not has then return end

	return self:update(
		{
			"userId    = ", params.userId,
			"projectId = ", params.projectId,
		},
		updateSet
	)
end

return M

