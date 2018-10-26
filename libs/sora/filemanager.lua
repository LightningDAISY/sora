local FileManager = {}
local lfs = require "lfs"
local rex = require "rex_pcre"

function FileManager.new(o, ext)
	o = o or {}
	o.ext = ext
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
	local newPath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. newName
	if self.ext then oldPath = oldPath .. self.ext end

	return os.rename(oldPath, newPath)
end

function FileManager:remove(filePath)
	local path = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. filePath
	if self.ext then path = path .. self.ext end
	return os.remove(path)
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

function FileManager:upload(path, reqParams)
	if not reqParams or not reqParams.newFile or not reqParams.newFile.name then
		throw "newFile is empty"
	end

	local filePath = _G.BaseDir .. "/" .. self.config.dir.file
	if path:len() > 0 then
		filePath = filePath .. "/" .. path
	end
	filePath = filePath .. "/" .. reqParams.newFile.name
	local file = io.open(filePath, "w")
	if not file then throw("cannot write " .. filePath) end
	file:write(reqParams.newFile.body)
	return file:close()
end

function FileManager:list(path)
	local result = {}
	if path == "/" then path = "" end
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
				result[fileName].path = path .. "/" .. fileName
			else
				result[fileName].path = fileName
			end
			local attr = lfs.attributes(fullPath)
			local permission = attr.permissions
			local permissionInt = attr.permissions
			result[fileName].uid = attr.uid
			result[fileName].gid = attr.gid

			result[fileName].fmuri = self.config.uri.file.manager
			result[fileName].uri   = self.config.uri.file.public
			if path:len() > 0 then
				result[fileName].uri   = result[fileName].uri   .. "/" .. path
				result[fileName].fmuri = result[fileName].fmuri .. "/" .. path
			end
			result[fileName].uri   = result[fileName].uri   .. "/" .. fileName
			result[fileName].fmuri = result[fileName].fmuri .. "/" .. fileName
			result[fileName].permissionString = permission
			result[fileName].permission = permission2int(permission)
			result[fileName].isDirectory = 0
			result[fileName].size = 0
			if(attr.mode == "directory") then
				result[fileName].isDirectory = 1
			else
				result[fileName].size = attr.size
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

