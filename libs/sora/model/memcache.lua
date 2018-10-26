local SoraModelMemcache = {}

function SoraModelMemcache.new(o)
	o = o or {}
	o.errorMessages = {}
	o.memcacheconn = nil
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

function SoraModelMemcache:memcacheConnect(isSingleton)
	if isSingleton and self.memcacheconn then return self.memcacheconn end
	local RestyMemcache = require "resty.memcached"
	local kvs, err = RestyMemcache:new()
	kvs:set_timeout(1000)
	local ok,err,errcode,sqlstate = kvs:connect(
		self.config.memcache.hostname,
		self.config.memcache.port
	)
	if not ok then
		table.insert(self,errorMessages, err)
		return false
	end
	self.memcacheconn = kvs
	return true
end

--
-- ex. model:memcacheConnectAnother({
--	hostname = HOSTNAME,
--  port     = PORT-NUMBER,
-- })
--
function SoraModelMemcache:memcacheConnectAnother(conf,isSingleton)
	if isSingleton and self.memcacheconn then return self.memcacheconn end
	local RestyMemcache = require "resty.memcached"
	local kvs, err = RestyMemcache:new()
	kvs:set_timeout(1000)
	local ok,err,errcode,sqlstate = kvs:connect(conf.hostname, conf.port)
	if not ok then
		self:_debugLog(err)
		return false
	end
	self.memcacheconn = kvs
	return true
end

function SoraModelMemcache:memcacheDisconnect()
	if self.memcacheconn then self.memcacheconn:close() end
	self.memcacheconn = nil
	return true
end

function SoraModelMemcache:get(key)
	local res, err = self.memcacheconn:get(key)
	if err then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

function SoraModelMemcache:set(key, value)
	local ok, err = self.memcacheconn:set(key, value)
	if not ok then
		self:_debugLog(err)
		table.insert(self.errorMessages, err)
	end
	return res
end

return SoraModelMemcache
