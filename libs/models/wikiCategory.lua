local M = {}

--
-- カテゴリ区切りは:x1
--

-- table information begin
local tableName = 'wikiCategory'
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

function M:set(data)
	local res,err = self:insert(data, true)
	local rows = self:select({ "name =", data.name})
	return rows[1]
end

function M:list(name)
	local like = "%"
	if name and name:len() > 0 then like = name .. ":%" end
	local rows = self:select(
		{ "name LIKE",  like },
		{ "name", "ASC" }
	)
	local result = {}
	for i,row in ipairs(rows) do
		table.insert(result, row.name)
	end
	return result
end

function M:struct(name)
	local like = "%"
	if name and name:len() > 0 then like = name .. ":%" end
	local rows = self:select(
		{ "name LIKE",  like },
		{ "name", "ASC" }
	)
	local struct = {}
	for i,row in ipairs(rows) do
		struct[row.id] = row.name
	end
	return struct
end

function M:get(name)
	local rows = self:select(
		{ "name =",  name }
	)
	if rows and #rows > 0 then
		return rows[1]
	end
end

function M:byId(id)
	local rows = self:select(
		{ "id =",  id }
	)
	if rows and #rows > 0 then
		return rows[1]
	end
end

return M
