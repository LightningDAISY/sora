local M = {}
-- table information begin
local tableName = 'wikiEntry'
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

function M:get(data)
	local wheres = {}
	if data.id then
		wheres = {
			"id =",  data.id
		}
	elseif data.subject and data.categoryId then
		wheres = {
			"subject = ",    data.subject,
			"categoryId = ", data.categoryId,
		}
	else
		throw(405, "subject is empty")
	end
	local rows = self:select(wheres)
	return rows[1]
end

function M:list(categoryId, limit, offset)
	limit  = limit or 100
	offset = offset or 0
	local whereset = { "categoryId =",  categoryId }
	local orderset = { "updatedAt", "DESC" }
	if not categoryId or #categoryId < 1 then
		whereset = { "categoryId > ", 0 }
		orderset = { "updatedAt", "DESC" }
	end
	return self:select(
		whereset,
		orderset,
		limit,
		offset
	)
end

function M:count(categoryId)
	local whereset = {}
	if categoryId then whereset = { "categoryId = ", categoryId } end
	local records = self:select(
		whereset,
		nil,
		nil,
		nil,
		"COUNT(*) AS num"
	)
	return records[1].num
end

function M:set(data)
	local record = self:get(data)
	if record then
		self:update(
			{ "id = ", record.id },
			{
				userId     = data.userId,
				categoryId = data.categoryId,
				subject    = data.subject,
				body       = data.body,
				source     = data.source,
			}
		)
		record.isExists = true
	else
		self:insert(data, true)
		record = self:get(data)
	end
	return record
end

return M
