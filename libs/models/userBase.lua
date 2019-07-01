local M = {}
-- table information begin
local tableName = 'userBase'
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

function M:add(userData)
	if not userData.userName or userData.userName == "" then
		self.errorMessage = "userName is required."
		return false
	end

	local insertData = {
		userName = userData.userName,
		password = userData.password,
	}
	if userData.projectId then insertData.projectId = userData.projectId end

	if self.config.auth.pass2hash and self.config.auth.hashAlgorithm then
		if self.config.auth.hashAlgorithm:lower() == "md5" then
			insertData.password = Util.md5(userData.password)
			insertData.hashAlgorithm = self.config.auth.hashAlgorithm:lower()
		end
	end

	local res,err = self:insert(insertData, true)
	if res then return res end
	self.errorMessage = err
	return false
end

function M:modify(userData)
	if not userData.userId then
		self.errorMessage = "userId is required."
		return false
	end

	if userData.password and self.config.auth.pass2hash and self.config.auth.hashAlgorithm then
		if self.config.auth.hashAlgorithm:lower() == "md5" then
			userData.password = Util.md5(userData.password)
			userData.hashAlgorithm = self.config.auth.hashAlgorithm:lower()
		end
	end

	return self:update(
		{ "userId =", userData.userId },
		userData
	)
end

function M:remove(userData)
	if not userData.userId then
		self.errorMessage = "userId is required."
		return false
	end
	return self:delete(
		{ "userId =", userData.userId }
	)

end

function M:auth(userId, password)
	local record = self:select(
		{
			userId = userId,
			password = password,
		}
	)
	if record then return true else return false end
end

function M:getUserData(userId)
	local rows = self:select(
		{
			'userId = ', userId
		}
	)
	if not rows then return nil end
	return rows[1]
end

return M
