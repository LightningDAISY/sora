local SoraModelRedis = {}

function SoraModelRedis.new(o)
	o = o or {}
	o.errorMessages = {}
	o.redisconn = nil
	local base = require "sora.base"
	local parent = base:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

--
-- ex. model:redisConnectAnother({
--	host     = host,
--  port     = port,
-- })
--
function SoraModelRedis:redisConnectAnother(conf,isSingleton)
	if isSingleton and self.redisconn then return self.redisconn end
	-- luarocks install luarestyredis すると
	-- resty_redis.luaが入りますが、他と合わせるためresty/redis.luaに移動しています。
	-- TODO 要Documentに追記
	-- local RestyRedis = require "resty_redis"
	local RestyRedis = require "resty.redis"
	local kvs, err = RestyRedis:new()
	kvs:set_timeout(1000)
	local ok,err,errcode,sqlstate = kvs:connect(conf.host, conf.port)
	if not ok then
		self:_debugLog(err)
		return false
	end
	self.redisconn = kvs
	return true
end

function SoraModelRedis:redisDisconnect()
	if self.redisconn then self.redisconn:close() end
	self.redisconn = nil
	return true
end

function SoraModelRedis:get(key)
	local res, err = self.redisconn:get(key)
	if err then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

function SoraModelRedis:set(key, value)
	local ok, err = self.redisconn:set(key, value)
	if not ok then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

function SoraModelRedis:info()
	local res, err = self.redisconn:info()
	local result = {}
	if err then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
		result = nil
	else
		local util = require "sora.util"
		local lines = util.split(res, "\r?\n")
		for i=1, #lines do
			local columns = util.split(lines[i], ":")
			if columns[2] then result[columns[1]] = columns[2] end
		end
	end
	return result
end

function SoraModelRedis:scan(prefix, cursor, count)
	cursor = cursor or 0
	count  = count  or 100
	local res, err = self.redisconn:scan(cursor, "match", prefix, "count", count)
	if err then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

function SoraModelRedis:hset(key, field, value)
	local ok, err = self.redisconn:hset(key, field, value)
	if not ok then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return ok
end

function SoraModelRedis:hdel(key, field)
	local ok, err = self.redisconn:hdel(key, field)
	if not ok then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return ok
end

--
-- HSCAN LuaRouter 0 MATCH /1/2/3/*
--
function SoraModelRedis:hscan(key, prefix, cursor, count)
	cursor = cursor or 0
	count  = count  or 100
	local res, err = self.redisconn:hscan(key, cursor, "match", prefix, "count", count)
	if err then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

function SoraModelRedis:loadScript(codeString, key)
	-- is enabled when lua-code-cache on
	if redisScriptHash[key] then
		if not self.redisconn:script("EXISTS", redisScriptHash[key]) then
			redisScriptHash[key] = self.redisconn:script("load", codeString)
		end
	else
		redisScriptHash[key] = self.redisconn:script("load", codeString)
	end
	return redisScriptHash[key]
end

function SoraModelRedis:evalsha(key, paramv)
	local result = self.redisconn:evalsha(
		redisScriptHash[key],
		1,
		"res",
		table.unpack(paramv)
	)
	return result
end

return SoraModelRedis
