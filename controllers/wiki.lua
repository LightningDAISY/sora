local C = {}
local cjson    = require "cjson"
local DMP      = require 'diff_match_patch'
local Entry    = require 'models.wikiEntry'
local Category = require 'models.wikiCategory'
local History  = require 'models.wikiHistory'

function C.new(o, req)
	o = o or {}
	o.req = req
	local ParentController = require "controllers.user.base"
	local parent = ParentController:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:categoryStruct(categoryName)
	local category = Category:new()
	local categories = category:struct(categoryName)

	local name2id = {}
	local id2name = {}
	for id,name in pairs(categories) do
		id2name["id" .. id] = name
		name2id[name] = id
	end
	return {
		id2name = id2name,
		name2id = name2id,
	}
end

function C:subjects(params)
	local categoryName = ngx.unescape_uri(params[1])
	local limit      = params[2]
	local offset     = params[3]

	local categories = self:categoryStruct()
	local categoryId = categories.name2id[categoryName]

	local subjects = {}
	local entry = Entry:new()
	local records = entry:list(categoryId,limit,offset)
	if #records < 1 then
		subjects = cjson.empty_array
	else
		for i,record in pairs(records) do
			table.insert(
				subjects, {
					id           = record.id,
					subject      = record.subject,
					categoryId   = record.categoryId,
					categoryName = categories.id2name["id" .. record.categoryId]
				}
			)
		end
	end
	ngx.say(cjson.encode({
		result   = "OK",
		subjects = subjects,
		count    = entry:count(categoryId)
	}))
end

--GET /wiki/entries/PARENT:CHILD
function C:entries(params)
	ngx.header["Content-Type"] = "application/json"

	--Get categoryId
	local categoryName = params[1]
	local categoryId = nil
	if categoryName and #categoryName > 0 then
		local category = Category:new()
		local record = category:get(categoryName)
		if not record then
			ngx.say(cjson.encode({
			  result = "OK",
			  entries = cjson.empty_array,
			}))
			return
		end
		categoryId = record.id
	end

	--Get entry
	local entry = Entry:new()
	local records = entry:list(categoryId)
	ngx.say(cjson.encode({
		result = "OK",
		entries = records,
	}))
end

--POST /api/wiki/rollback/ENTRYID/HISTORYID
function C:rollback(params)
	ngx.header["Content-Type"] = "application/json"
	if not self.user then
		ngx.say(cjson.encode({
			result = "NG",
			message = "retry after login",
		}))
		return
	end
	local entryId = params[1]
	local minHistoryId = params[2]
	local methodUpper = self.req.method:upper()
	local entry = Entry:new()
	local history = History:new()
	local entryRecord = entry:get({id = entryId})
	if not entryRecord then
		ngx.say(cjson.encode({
			result = "NG",
			message = "entry not found",
		}))
		return
	end
	local body = entryRecord.body
	local source = entryRecord.source
	local historyRecords = history:select(
		{
			"entryId = ", entryId,
			"id >= ",     minHistoryId,
		},
		{
			"id", "DESC"
		}
	)
	-- rollback begin
	for i,historyRecord in ipairs(historyRecords) do
		body = self:_diff2text(
			body,
			cjson.decode(
				historyRecord.diff
			)
		)
		source = self:_diff2text(
			source,
			cjson.decode(
				historyRecord.sourceDiff
			)
		)
	end
	entry:set({
		id     = entryId,
		userId = self.user.userId,
		body   = body,
		source = source,
	})
	--rollback end

	-- set History
	local diff =  DMP.diff_main(body, entryRecord.body)
	local sourceDiff =  DMP.diff_main(source, entryRecord.source)
	if #diff > 1 then
		history:add({
			entryId    = entryId,
			diff       = cjson.encode(diff),
			sourceDiff = cjson.encode(sourceDiff),
			userId     = self.user.userId,
		})
	end
	
	--remove trash
	--history:delete({
	--	'entryId = ', entryId,
	--	'id >= ',     minHistoryId
	--})

	ngx.say(cjson.encode({
		result = "OK",
		entries = records,
	}))
end

function C:set(params)
	ngx.header["Content-Type"] = "application/json"
    if not self.user then
		ngx.say(cjson.encode({
			result = "NG",
			message = "retry after login",
		}))
		return
	end

	local methodUpper = self.req.method:upper()
	local reqParams = self.req:params()
	local category = Category:new()
	local entry = Entry:new()
	local history = History:new()

	if "POST" == methodUpper then
		--set category
		local res = category:set({
			name = reqParams.category,
		})

		if not res then throw(500, "cannot set the category " + reqParams.category) end

		for key,value in pairs(reqParams) do
			reqParams[key] = reqParams[key]:gsub('\r\n', '\n')
			reqParams[key] = reqParams[key]:gsub('\r', '\n')
		end

		-- set entry
		res = entry:set({
			id         = reqParams.id, -- not set when id is empty.
			subject    = reqParams.subject,
			body       = reqParams.body,
			userId     = self.user.userId,
			source     = reqParams.source,
			categoryId = res.id,
		})
		if not res then throw(500, "cannot set the entry") end
		if res.isExists then
			local diff = DMP.diff_main(reqParams.body, res.body)
			local sourceDiff = DMP.diff_main(reqParams.source, res.source)
			if #diff > 1 then
				-- set History
				res = history:add({
					entryId = res.id,
					diff    = cjson.encode(diff),
					sourceDiff = cjson.encode(sourceDiff),
					userId  = self.user.userId,
				})
			end
		end
		ngx.say(cjson.encode({ result = "OK" }))
		return

	-- DELETE /api/wiki/set/2/18
	elseif "DELETE" == methodUpper then
		--delete entry
		entry:delete({ "id = ", params[1] })

		--delete history
		history:delete({ "entryId = ", params[1] })

		ngx.say(cjson.encode({ result = "OK" }))
		return
	end
	ngx.say(cjson.encode({ result = "NG" }))
end

function C:categories(params)
	ngx.header["Content-Type"] = "application/json"
	local name = params[1] or ''
	local reqParams = self.req:params()
	local category = Category:new()
	local categories = category:list(name)
	if #categories < 1 then
		ngx.say(cjson.encode({ result = "OK", categories = cjson.empty_array }))
	else
		ngx.say(cjson.encode({ result = "OK", categories = categories }))
	end
end

--/api/wiki/entry/ENTRYID
function C:entry(params)
	ngx.header["Content-Type"] = "application/json"
	local id = params[1]
	if not id then
		ngx.say(cjson.encode({ result = "NG", message = "is empty" }))
		return
	end
	local entry = Entry:new()
	local entryRecord = entry:get({id = id})
	if not entryRecord then
		ngx.say(cjson.encode({ result = "NG", message = "is not found" }))
		return
	end

	local category = Category:new()
	local categoryRecord = category:byId(entryRecord.categoryId)
	if categoryRecord then
		entryRecord.categoryName = categoryRecord.name
	end
	ngx.say(cjson.encode({ result = "OK", entry = entryRecord }))
end

--/api/wiki/exists/CATEGORY/SUBJECT/
function C:exists(params)
	ngx.header["Content-Type"] = "application/json"
	local categoryName = ngx.unescape_uri(params[1]) or ''
	local entrySubject = ngx.unescape_uri(params[2]) or ''
	if #categoryName < 1 or #entrySubject < 1 then
		ngx.say(cjson.encode({ result = "OK" }))
		return
	end

	local category = Category:new()
	local categoryRecord = category:get(categoryName)
	if not categoryRecord then
		ngx.say(cjson.encode({ result = "OK" }))
		return
	end

	local entry = Entry:new()
	local entryRecord = entry:get({
		subject    = entrySubject,
		categoryId = categoryRecord.id
	})
	if entryRecord then
		ngx.say(cjson.encode({ result = "NG", record = entryRecord }))
		return
	end
	ngx.say(cjson.encode({ result = "OK" }))
end

function C:_diff2text(text, diff)
	local patch = DMP.patch_make(diff)
	local oldText = DMP.patch_apply(patch, text)
	return oldText
end

--/api/wiki/histories/ENTRYID
function C:histories(params)
	ngx.header["Content-Type"] = "application/json"
	local entryId = params[1]
	if not entryId then
		ngx.say(cjson.encode({ result = "NG" }))
	end

	local entry = Entry:new()
	local entryRecord = entry:get({id = entryId})
	if not entryRecord then
		ngx.say(cjson.encode({ result = "NG", message = "the entry is not found" }))
		return
	end

	local history = History:new()
	local historyRecords = history:list(entryId, 10)
	for i = 1, #historyRecords do
		entryRecord.body = self:_diff2text(entryRecord.body, cjson.decode(historyRecords[i].diff))
		historyRecords[i].preview = entryRecord.body
	end
	if #historyRecords < 1 then
		ngx.say(cjson.encode({ result = "OK", histories = cjson.empty_array }))
	else
		ngx.say(cjson.encode({ result = "OK", histories = historyRecords }))
	end
end

return C

--[[
local dmp = require 'diff_match_patch'

diff = dmp.diff_main('Hello World.', 'Goodbye World.')
-- Result: [(-1, "Hell"), (1, "G"), (0, "o"), (1, "odbye"), (0, " World.")]
dmp.diff_cleanupSemantic(diff)
-- Result: [(-1, "Hello"), (1, "Goodbye"), (0, " World.")]
for i,tuple in ipairs(diff) do
  print('(' .. tuple[1] .. ', ' .. tuple[2] .. ')')
end
--]]

