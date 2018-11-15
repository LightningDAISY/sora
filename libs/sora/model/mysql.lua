local SoraModelMySQL = {}

function SoraModelMySQL.new(o)
	o = o or {}
	o.mysqlconn = nil
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

function SoraModelMySQL:now(db)
	db = db or self.mysqlconn
	if not db then return end
	local rows = db:query("SELECT NOW() AS now")
	if type(rows) == "table" then
		return rows[1].now
	else
		return nil
	end
end

function SoraModelMySQL:dbh()
	if not self:now() then
		self.mysqlconn = self:mysqlConnectService()
	end
	if not self.mysqlconn then
		throw "cannot connect database."
	end
	return self.mysqlconn
end

--
-- Caution!!
--
-- ホスト名を指定して
-- "no resolver defined to resolve"
-- エラーが出る場合、nginxのconfにresolverとしてDNSの指定が必要です。
--
-- resolver 192.168.0.1 valid=5s;
--
-- ただしDNSから引けないホスト名 (localhostとか) はIPアドレスに書き換えてください。
--
function SoraModelMySQL:mysqlConnect(isSingleton, config, isSetup)
	if isSingleton and self.mysqlconn and self:now() then return self.mysqlconn end
	config = config or self.config.mysql

	local restyMysql = require "resty.mysql"
	local db, err = restyMysql:new()
	db:set_timeout(1000)
	db:set_keepalive(10000,1000)
	local ok,err,errcode,sqlstate = db:connect({
		host     = config.hostname,
		port     = config.port,
		database = config.schema,
		user     = config.username,
		password = config.password,
		max_packet_size = 1024 * 1024
	})
	if not ok then
		-- セットアップ時のみ接続不可でもエラーにしない
		if isSetup then
			return false
		else
			throw(500, "mysql connection failed")
		end
	end
	db:query("SET NAMES UTF8")
	self.mysqlconn = db
	return db
end

function SoraModelMySQL:mysqlConnectService(isSingleton, isSetup)
	return self:mysqlConnect(isSingleton, self.config.mysqlService, isSetup)
end	
--
-- ex. model:mysqlConnectAnother({
--	host     = host,
--  port     = port,
--  database = schema,
--  user     = user,
--  password = password,
-- })
--
function SoraModelMySQL:mysqlConnectAnother(isSingleton, config)
	if isSingleton and self.mysqlconn and self:now() then return self.mysqlconn end
	local restyMysql = require "resty.mysql"
	local db, err = restyMysql:new()
	db:set_timeout(1000)
	db:set_keepalive(10000,1000)
	local ok,err,errcode,sqlstate = db:connect({
		host     = config.host,
		port     = config.port,
		database = config.database,
		user     = config.user,
		password = config.password,
		max_packet_size = 1024 * 1024
	})

	if not ok then
		self:_debugLog(err)
		return false
	end

	db:query("SET NAMES UTF8")
	self.mysqlconn = db
	return true
end

function SoraModelMySQL:userdata2Empty(row)
	for key,val in pairs(row) do
		if type(val) == "userdata" then
			row[key] = ""
		end
	end
	return row
end

function SoraModelMySQL:mysqlDisconnect()
	if self.mysqlconn then self.mysqlconn:close() end
	self.mysqlconn = nil
	return true
end

--
-- res as follows
--
-- {
--   insert_id = 0,
--   server_status = 2,
--   warning_count = 1,
--   affected_rows = 32,
--   message = nil
-- } 
--
function SoraModelMySQL:query(sql,ignoreFlag)
	local res,err,errcode,sqlstate = self:dbh():query(sql)
	if err then
		if ignoreFlag then
			return res,err
		else
			throw(500, err .. " / SQL : ".. sql)
		end
	end
	return res,nil
end

function SoraModelMySQL:selectQuery(sql)
	self:_debugLog(sql)
	local res,err,errcode,sqlstate = self:dbh():query(sql)
	if err then
		self:_debugLog(err)
	end
	return res or {}
end

--
-- model:select(
--   {                         --WHERE
--     "viewer_id >", 100,
--     "updatedAt >", "2016-09-30",
--   },
--   {                         --ORDER
--		"updatedAt", "DESC"
--   }
--   100,                      --LIMIT
--   0,                        --OFFSET
--   "*"                       --COLUMNS
-- )
--
function SoraModelMySQL:select(wheres, orders, limit, offset, columns)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	columns = columns or "*"
	builder:select(columns)
	builder:from(self.tableName)

	--ORDER
	if orders then
		for i=1, #orders, 2 do
			builder:order(orders[i], orders[i+1])
		end
	end

	-- WHERE
	wheres = wheres or {}
	local hasExpired = false
	for i=1, #wheres, 2 do
		-- {
		--   "ColumnName1 = ", "EscapeColumnValue",
		--	  { "ColumnName2 = ", "plain" }, "PlainColumnValue",
		-- }
		if wheres[i]:match("expiredAt[%s=><]") then
			hasExpired = true
		end
		if type(wheres[i]) == "table" and wheres[i][2] == "plain" then
			builder:wherePlain(wheres[i][1], wheres[i+1])
		else
			builder:where(wheres[i], wheres[i+1])
		end
	end
	if not hasExpired then
		builder:wherePlain("(expiredAt = ", "0")
		builder:wherePlain("expiredAt > ", tostring(self:_getTime()) .. ")", "OR")
	end

	-- LiMiT
	if limit then
		offset = offset or 0
		builder:limit(limit, offset)
	end

	local sql = tostring(builder)
	return self:selectQuery(sql)
end

function SoraModelMySQL:lastInsertId()
	local sql = "SELECT LAST_INSERT_ID() AS last_insert_id"
	local rows = self:selectQuery(sql)
	return rows[1]["last_insert_id"]
end

function SoraModelMySQL:affectedRows()
	local sql = "SELECT FOUND_ROWS() AS affected_rows"
	local rows = self:selectQuery(sql)
	return tonumber(rows[1]["affected_rows"])
end

--
-- model:insert(
--   {
--      viewer_id = 100,
--      campaign_id = 10,
--   }
-- )
--
function SoraModelMySQL:insert(record, isIgnoreErrors)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	if not record.expiredAt then
		-- record.expiredAt = self:_datetime()
		record.expiredAt = "0"
	end

	if not record.createdAt then
		-- record.createdAt = self:_datetime()
		record.createdAt = tostring(self:_getTime())
	end

	if not record.updatedAt then
		-- record.updatedAt = self:_datetime()
		record.updatedAt = tostring(self:_getTime())
	end

	builder:insert(
		self.tableName,
		record
	)
	local sql = tostring(builder)
	self:_debugLog(sql)
	return self:query(sql, isIgnoreErrors)
end

--[[
 bool = ins:create(
   "exampleTable",
   {
     ["pk1"] = "VARCHAR(255),",
     ["PK2"] = "VARCHAR(255),",
     ["PRIMARY KEY"] = "(pk1,pk2)"
   },
   {
     ["ENGINE"] = "InnoDB",
     ["DEFAULT CHARSET"] = "utf8"
   }
 )
]]--
function SoraModelMySQL:create(tableName, columns, options)
	local sql = "CREATE TABLE `" .. tableName .. "` ("
	local sqlColumns = {}
	for i=1,#columns,2 do
		table.insert(sqlColumns, columns[i] .. " " .. columns[i+1])
	end
	sql = sql .. table.concat(sqlColumns, ",") .. ")"

	local sqlOptions = {}
	for i=1, #options, 2 do
		table.insert(sqlOptions, options[i] .. "=" .. options[i+1])
	end
	sql = sql .. " " .. table.concat(sqlOptions, " ")

	self:_debugLog(sql)
	return self:query(sql)
end

--
-- model:update(
--   {
--     "viewer_id >", 100,
--     "updatedAt >", "2016-09-30",
--   },
--   {
--      viewer_id = 100,
--      campaign_id = 10,
--   }
-- )
--
function SoraModelMySQL:update(wheres, record)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	-- WHERE
	if wheres then
		for i=1, #wheres, 2 do
			builder:where(wheres[i], wheres[i+1])
		end
	end

	-- SET
	if not record.updatedAt then
		-- record.updatedAt = self:datetime()
		record.updatedAt = tostring(self:_getTime())
	end

	builder:update(
		self.tableName,
		record
	)
	local sql = tostring(builder)
	self:_debugLog(sql)
	return self:query(sql)
end

--
-- mode:delete(
--   {
--     "viewer_id =", 10
--     "updatedAt <", self:_getTime()
--   }
-- )
--
function SoraModelMySQL:delete(wheres)
	local SQLBuilder = require "sora.sqlbuilder"
	local builder = SQLBuilder.new()

	-- WHERE
	if wheres then
		for i=1, #wheres, 2 do
			builder:where(wheres[i], wheres[i+1])
		end
	end

	builder:from(self.tableName)
	builder:delete()
	local sql = tostring(builder)
	self:_debugLog(sql)
	return self:query(sql)
end

function SoraModelMySQL:showStatus()
	local res = self:selectQuery("SHOW STATUS")
	local result = {}
	for i=1, #res, 1 do
		for key,val in pairs(res[i]) do
			table.insert(result,val)
		end
	end
	return result
end

function SoraModelMySQL:showGlobalStatus()
	local res = self:selectQuery("SHOW GLOBAL STATUS")
	local result = {}
	for i=1, #res, 1 do
		for key,val in pairs(res[i]) do
			table.insert(result,val)
		end
	end
	return result
end

--
-- 要PROCESS権限
--
function SoraModelMySQL:showInnodbStatus()
	local res = self:selectQuery("SHOW STATUS LIKE 'Innodb%'")
	local result = {}
	for i=1, #res, 1 do
		for key,val in pairs(res[i]) do
			table.insert(result,val)
		end
	end
	return result
end

function SoraModelMySQL:flushStatus()
	return self:query("FLUSH STATUS")
end

function SoraModelMySQL:showTables()
	local res = self:selectQuery("SHOW TABLES")
--	local cjson = require "cjson"
--	ngx.say("result: ", cjson.encode(res))
	local result = {}
	for i=1, #res, 1 do
		for key,val in pairs(res[i]) do
			table.insert(result,val)
		end
	end
	return result
end

function SoraModelMySQL:describe(tableName)
	local res = self:selectQuery("DESC " .. tableName)
	return res
end

function SoraModelMySQL:transactionBegin()
	self:query("SET AUTOCOMMIT=0")
	self:query("START TRANSACTION")
end

function SoraModelMySQL:transactionRollback()
	self:query("ROLLBACK")
	self:query("SET AUTOCOMMIT=1")
end

function SoraModelMySQL:transactionEnd()
	self:query("COMMIT")
	self:query("SET AUTOCOMMIT=1")
end

return SoraModelMySQL
