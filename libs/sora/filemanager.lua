local FileManager = {}
local lfs = require "lfs"
local rex = require "rex_pcre"
local cjson = require "cjson"
local DMP   = require 'diff_match_patch'

function FileManager.new(o, ext)
	o = o or {}
	o.ext = ext
	o.errorMessage = ''
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

function FileManager:rename(oldName, newName)
	if rex.match(oldName, "\\.\\.") then throw("invalid filename") end
	if rex.match(newName, "\\.\\.") then throw("invalid filename") end
	local oldPath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. oldName
	local newPath = _G.BaseDir .. "/" .. self.config.dir.file .. newName
	if self:isFreezed(oldPath) then return end
	self:moveFreezed("/" .. oldName, newName)
	self:moveHistory(oldName,newName)
	return os.rename(oldPath, newPath)
end

function FileManager:isYaml(path)
	if path:lower():match("%.ya?ml$") then return true end
end

function FileManager:getUserNickname(userId)
	if not userId then return "" end
	local UserDetail = require "models.userDetail"
	local user = UserDetail:new()
	local users = user:select({ "userId = ", userId })
	if not users or #users < 1 then return "" end
	return users[1].nickname
end

function FileManager:userId2nickname(rows)
	local nicknames = {}
	for i,row in ipairs(rows) do
		if not nicknames["id" .. row.userId] then
			nicknames["id" .. row.userId] = self:getUserNickname(row.userId)
		end
		row.nickname = nicknames["id" .. row.userId]
	end
end

function FileManager:getHistories(path)
	if not self:isYaml(path) then return {} end
	local dirname,fname = self:nameByPath(path)
	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()
	local records = history:select(
		{ "path = ", dirname, "fileName = ", fname },
		{ "id", "DESC" }
	)
	return records
end

function FileManager:pathByHistoryId(historyId)
	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()
	local historyRecords = history:select({ "id = ", historyId })
	if #historyRecords > 0 then
		return historyRecords[1].path, historyRecords[1].fileName
	else
		return false, false
	end
end

function FileManager:_diff2text(text, diff)
	local patch = DMP.patch_make(diff)
	local oldText = DMP.patch_apply(patch, text)
	return oldText
end

function FileManager:rollbackTo(minHistoryId)

	if not self.user or not self.user.userId then
		self.errorMessage = "retry after login"
		return
	end

	local path,fileName = self:pathByHistoryId(minHistoryId)
	if not path or not fileName then
		self.errorMessage = "invalid History-ID " .. minHistoryId
		return
	end

	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()
	local historyRecords = history:select(
		{
			"path = ", path,
			"fileName = ", fileName,
			"id >= ", minHistoryId,
		},
		{
			"id", "DESC"
		}
	)
	local filePath = _G.BaseDir .. "/" .. 
	                 self.config.dir.file .. "/" .. 
					 path .. "/" .. fileName
	local currentBody = self:fread(filePath)
	local body = currentBody
	if not body then
		self.errorMessage = "file " .. fileName .. " is not found."
		return
	end

	-- rollback begin
	for i,historyRecord in ipairs(historyRecords) do
		body = self:_diff2text(
			body,
			cjson.decode(
				historyRecord.diff
			)
		)
	end
	--rollback end

	-- add a new history begin
	local diff =  DMP.diff_main(body, currentBody)
	if #diff > 1 then
		history:add({
			path       = path,
			fileName   = fileName,
			diff       = cjson.encode(diff),
			userId     = self.user.userId,
		})
	end
	-- add a new history end

	local file = io.open(filePath, "w")
	if not file then throw("cannot write " .. filePath) end
	file:write(body)
	file:close()
	return true
end

function FileManager:getPreviews(path)
	local histories = self:getHistories(path)
	if not histories then return end
	local filePath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. path
	local previews = {}
	for i,history in ipairs(histories) do
		--local diffStruct = cjson.decode(history.diff)
		--local patch = DMP.patch_make(diffStruct)
		--local text = DMP.patch_toText(patch)
		--local text = DMP.diff_prettyHtml(diffStruct)
        local text = DMP.diff_prettyHtml(cjson.decode(history.diff))
		text = rex.gsub(
			text,
			"\n",
			"<br />"
		)

		table.insert(previews, {
			id     = history.id,
			body   = text:gsub("&para;", ""),
			userId = history.userId,
			time   = history.updatedAt,
		})
	end
	return previews
end

function FileManager:deleteHistory(path)
	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()
	local dir, file = self:nameByPath(path)
	self:_errorLog(dir .. " : " .. file)
	return history:delete({ "path = ", dir, "fileName = ", file })
end

function FileManager:remove(path)
	local filePath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. path
	if self:isFreezed(filePath) then return end
	self:deleteHistory(path)
	return os.remove(filePath)
end

function FileManager:newDirectory(directoryPath)
	if rex.match(directoryPath, "\\.\\.") then throw("invalid directory name") end
	return lfs.mkdir(
		_G.BaseDir .. "/" .. self.config.dir.file .. "/" .. directoryPath
	)
end

function FileManager:isDirectory(path)
	path = _G.BaseDir .. "/" .. self.config.dir.file .. path
	local attr = lfs.attributes(path)
	if(attr.mode == "directory") then
		return true
	else
		return false
	end
end

function FileManager:nameByPath(path)
	local itr = rex.split(path, "/")
	local parts = {}
	for part in itr do
		if #part > 0 then
			table.insert(parts, part)
		end
	end
	local fname = table.remove(parts,#parts)
	local dir   = "/" .. table.concat(parts, "/")
	return dir, fname
end

function FileManager:freeze(userId, path)
	if not userId then throw("userId is empty") end
	local dir,fname = self:nameByPath(path)
	local PathFreeze = require "models.pathFreeze"
	local freeze = PathFreeze:new()

	local records = freeze:select(
		{
			"path = ",     dir,
			"fileName = ", fname,
		}
	)
	if records and #records > 0 then
		freeze:delete(
			{
				"path = ",     dir,
				"fileName = ", fname,
				"userId = ",   userId,
			}
		)
	else
		freeze:insert(
			{
				path     = dir,
				fileName = fname,
				userId   = userId,
			},
			true
		)
	end
end

function FileManager:moveFreezed(oldPath,newPath)
	local PathFreeze = require "models.pathFreeze"
	local freeze = PathFreeze:new()
	return freeze:update(
		{ "path = ", oldPath },
		{ path = newPath }
	)
end

function FileManager:moveHistory(oldPath,newPath)
	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()
	local oldDir, oldFile = self:nameByPath(oldPath)
	local newDir, newFile = self:nameByPath(newPath)
	return history:update(
		{ "path = ", oldDir, "fileName = ", oldFile },
		{ path  =    newDir,  fileName =   newFile }
	)
end

function FileManager:freezeList(path)
	path = ngx.unescape_uri(path)
	local PathFreeze = require "models.pathFreeze"
	local freeze = PathFreeze:new()
	local records = freeze:select({ "path = ", path })
	local userNicknames = {}
	local result = {}
	for i,record in ipairs(records) do
		local userId = record.userId
		if not userNicknames["ID" .. userId] then
			userNicknames["ID" .. userId] = self:getUserNickname(userId)
		end
		record.userNickname = userNicknames["ID" .. userId]
		self:_errorLog(self:_dump(record))
		result[record.fileName] = record
	end
	return result
end

function FileManager:isFreezed(path)
	local dir,fname = self:nameByPath(path)
	local PathFreeze = require "models.pathFreeze"
	local freeze = PathFreeze:new()
	local records = freeze:select({ "path = ", dir, "fileName = ", fname })
	if not records or #records < 1 then
		return
	else
		return 1
	end
end

--
-- rwxr-xr-x -> 755
--
local function permission2int(str)
	local char = ""
	local weight = 4
	local result = 0
	for i=1, 9 do
		char = str:sub(i,i)
		if char ~= "-" then
			result = tonumber(result) + weight
		end
		if weight <= 1 then
			weight = 4
			result = result .. "0"
		else
			weight = weight / 2
		end
	end
	return result:sub(1,3)
end

function FileManager:newFile(filePath, fileBody)
	filePath = ngx.unescape_uri(filePath)
	if not self.user then
		throw(403, "retry after login")
	end
	filePath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. filePath
	if self:isFreezed(filePath) then
		throw(403, "is locked")
	end
	local fh = io.open(filePath, "w")
	if not fh then throw("cannot write " .. filePath) end
	fh:write(fileBody)
	return fh:close()
end

function FileManager:isExists(path)
	local file = io.open(path, "r")
	if not file then return end
	file:close()
	return true
end

function FileManager:fread(path)
	local file = io.open(path, "r")
	if not file then return end
	local fbody = file:read("*a")
	file:close()
	return fbody
end

function FileManager:setHistory(path, oldBody, newBody)
	local diff = DMP.diff_main(newBody, oldBody)
	if #diff < 2 then return end -- not modified
	local PathHistory = require "models.pathHistory"
	local history = PathHistory:new()

	local dir,fname = self:nameByPath(path)
	history:insert({
		path      = dir,
		fileName  = fname,
		userId    = self.user.userId,
		diff      = cjson.encode(diff),
	})
	return true
end

function FileManager:upload(path, reqParams)
	if not reqParams or not reqParams.newFile or not reqParams.newFile.name then
		throw "newFile is empty"
	end
	path = ngx.unescape_uri(path)

	if self:isFreezed(path) then
		throw(403, "is locked")
	end

	local filePath = _G.BaseDir .. "/" .. self.config.dir.file
	if path:len() > 0 then
		filePath = filePath .. "/" .. path
	end
	filePath = filePath .. "/" .. reqParams.newFile.name

	-- History begin
	if self:isYaml(filePath) then
		reqParams.newFile.body = reqParams.newFile.body:gsub('\r\n', '\n'):gsub('\r', '\n')
		if self:isExists(filePath) then
			self:setHistory(
				path .. '/' .. reqParams.newFile.name,
				self:fread(filePath),
				reqParams.newFile.body
			)
		end
	end
	-- History end

	local file = io.open(filePath, "w")
	if not file then throw("cannot write " .. filePath) end
	file:write(reqParams.newFile.body)
	return file:close()
end

function FileManager:list(path)
	local result = {}
	local freezeTable = self:freezeList("/" .. path)
	if path == "/" then path = "" end
	path = ngx.unescape_uri(path)
	local basePath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. path
	local fileNames = {}
	for fileName in lfs.dir(basePath) do
		table.insert(fileNames, fileName)
	end
	table.sort(fileNames)
	for i,fileName in ipairs(fileNames) do
		if fileName ~= "." and fileName ~= ".." then
			local fullPath = basePath .. "/" .. fileName
			result[fileName] = { name = fileName }
			if path:len() > 0 then
				result[fileName].path = "/" .. path .. "/" .. fileName
			else
				result[fileName].path = "/" .. fileName
			end
			local attr = lfs.attributes(fullPath)
			local permission = attr.permissions
			local permissionInt = attr.permissions
			result[fileName].uid = attr.uid
			result[fileName].gid = attr.gid

			--result[fileName].uri   = self.config.uri.file.public
			--result[fileName].fmuri = self.config.uri.file.manager

			if path:len() > 0 then
				result[fileName].uri   = self.config.uri.file.public  .. result[fileName].path
				result[fileName].fmuri = self.config.uri.file.manager .. result[fileName].path
			else
				result[fileName].uri   = self.config.uri.file.public   .. result[fileName].path
				result[fileName].fmuri = self.config.uri.file.manager  .. result[fileName].path
			end
			result[fileName].permissionString = permission
			result[fileName].permission = permission2int(permission)
			result[fileName].isDirectory = 0
			result[fileName].size = 0
			if(attr.mode == "directory") then
				result[fileName].isDirectory = 1
			else
				result[fileName].size = attr.size
			end
			if freezeTable[fileName] then
				result[fileName].lockedBy = freezeTable[fileName].userId
				result[fileName].userNickname = freezeTable[fileName].userNickname
			end
		end
	end
	return result
end

function FileManager:getParentUri(requestUri)
	if requestUri == "/" then return self.config.uri.file.manager end
	local modified = rex.gsub(
		requestUri,
		"[^/]+/*$",
		""
	)
	if modified ~= "" then modified = "/" .. modified end
	return self.config.uri.file.manager .. modified
end

return FileManager

