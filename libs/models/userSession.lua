local M = {}

-- table information begin
local tableName = 'userSession'
-- table information end

local Util = require 'sora.util'

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

function M:createSessionId(seed, min, max)
	if not seed then throw "seed is empty" end
	min = min or 100000000
	max = max or 999999999
	math.randomseed(os.time() .. collectgarbage('count') .. seed)
	local rand = math.random(min,max)
	--return tostring(rand)

	--2MD5
	return Util.md5(rand)
end

function M:set(userId,projectId)
	local sessionId
	local isDuplicate = 1
	while isDuplicate do
		sessionId = self:createSessionId(
			userId,
			self.config.session.minOfDigit,
			self.config.session.maxOfDigit
		)
		local res, err = self:insert({
			sessionId = sessionId,
			userId    = userId,
			projectId = projectId,
			expiredAt = self:_getTime() + self.config.session.expireSec
		})
		if not err then isDuplicate = nil end
	end
	return sessionId
end

function M:get(sessionId)
	local rows = self:select({ 'sessionId =', sessionId })
	if table.maxn(rows) < 1 then return nil end
	return rows[1]
end

function M:remove(sessionId)
	return self:delete({ sessionId = sessionId })
end

return M
