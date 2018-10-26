SoraModel = {}
require "sora.base"

function SoraModel.new(o)
	o = o or {}
	base = SoraBase:new()
	setmetatable(
		o,
		{
			__index = base
		}
	)
	return o
end

function SoraModel:mysqlConnect()
	local luasql = require("luasql.mysql")
	self.mysqlenv  = assert(luasql.mysql())
	self.mysqlconn = assert(self.mysqlenv:connect(
		self.config.mysql.schema,
		self.config.mysql.username,
		self.config.mysql.password,
		self.config.mysql.hostname,
		self.config.mysql.port
	))
	return self.mysqlconn
end

function SoraModel:query(sql)
	return self.mysqlconn:execute(sql)
end

function SoraModel:selectQuery(sql)
	local result = {}
	local cur = self.mysqlconn:execute(sql)
	local row = cur:fetch({}, "a")
	while row do
		table.insert(result, row)
		row = cur:fetch({}, "a")
	end
	cur:close()
	return result
end

--
-- model:select(
--   {                         --WHERE
--     "viewer_id >", 100,
--     "updated_at >", "2016-09-30",
--   },
--   {                         --ORDER
--		"updated_at", "DESC"
--   }
--   100,                      --LIMIT
--   0,                        --OFFSET
--   "*"                       --COLUMNS
-- )
--
function SoraModel:select(wheres, orders, limit, offset, columns)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	columns = columns or "*"
	builder:select(columns)
	builder:from(self.tableName)

	--ORDER
	if orders then
		for i=1, table.maxn(orders), 2 do
			builder:order(orders[i], orders[i+1])
		end
	end

	-- WHERE
	if wheres then
		for i=1, table.maxn(wheres), 2 do
			builder:where(wheres[i], wheres[i+1])
		end
	end

	-- LiMiT
	if limit then
		offset = offset or 0
		builder:limit(limit, offset)
	end

	local sql = tostring(builder)
	self:debugLog(sql)
	return self:selectQuery(sql)
end

--
-- model:insert(
--   {
--      viewer_id = 100,
--      campaign_id = 10,
--   }
-- )
--
function SoraModel:insert(record)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()
	if not record.created_at then
		record.created_at = self:_datetime()
	end
	if not record.updated_at then
		record.updated_at = self:_datetime()
	end

	builder:insert(
		self.tableName,
		record
	)
	local sql = tostring(builder)
	self:debugLog(sql)
	return self:query(sql)
end

--
-- model:update(
--   {
--     "viewer_id >", 100,
--     "updated_at >", "2016-09-30",
--   },
--   {
--      viewer_id = 100,
--      campaign_id = 10,
--   }
-- )
--
function SoraModel:update(wheres, record)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	-- WHERE
	if wheres then
		for i=1, table.maxn(wheres), 2 do
			builder:where(wheres[i], wheres[i+1])
		end
	end

	-- SET
	if not record.updated_at then
		record.updated_at = self:_datetime()
	end

	builder:update(
		self.tableName,
		record
	)
	local sql = tostring(builder)
	self:debugLog(sql)
	return self:query(sql)
end

--
-- mode:delete(
--   {
--     "viewer_id =", 10
--     "updated_at <", "2016-09-28 00:00:00"
--   }
-- )
--
function SoraModel:delete(wheres)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	-- WHERE
	if wheres then
		for i=1, table.maxn(wheres), 2 do
			builder:where(wheres[i], wheres[i+1])
		end
	end

	builder:from(self.tableName)
	builder:delete()
	local sql = tostring(builder)
	self:debugLog(sql)
	return self:query(sql)

end

function SoraModel:transactionBegin()
	self.mysqlconn:setautocommit(false)
	self:query("START TRANSACTION")
end

function SoraModel:transactionRollback()
	self:query("ROLLBACK")
	self.mysqlconn:setautocommit(true)
end

function SoraModel:transactionEnd()
	self:query("COMMIT")
	self.mysqlconn:setautocommit(true)
end


--
-- luasqlで適当に実装したサンプルです。（べつに使えます）
-- 現状使っていませんが、そのうちバッチ処理用に使うかも。
--
