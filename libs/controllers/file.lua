local C = {}
local Util = require "sora.util"
local FileManager =  require "sora.filemanager"
local cjson = require "cjson"
local rex = require "rex_pcre"
local lfs = require "lfs"

function C.new(o, req)
	o = o or {}
	o.req = req
	o.fileManager = FileManager:new(req.format)
	--local ParentController = require "sora.controller"
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

function C:_nameHasSpaces(name)
	if not name then return end
	if rex.match(name, "\\s") then
		throw(405, { message = "invalid filename " .. name })
	end
end

function C:histories(params)
	ngx.header["Content-Type"] = "application/json"
	local histories = self.fileManager:getPreviews(
		ngx.unescape_uri('/' .. table.concat(params, '/'))
	)
	if histories then
		if #histories < 1 then
			ngx.say(cjson.encode({ result = "OK", histories = cjson.empty_array}))
		else
			self.fileManager:userId2nickname(histories)
			ngx.say(cjson.encode({ result = "OK", histories = histories }))
		end
	else
		ngx.say(cjson.encode({ result = "NG", histories = cjson.empty_array }))
	end
end

function C:rollbackTo(params)
	ngx.header["Content-Type"] = "application/json"
	if not self.user then
		ngx.say(cjson.encode({ result = "NG", message = "retry after login" }))
		return
	end
	self.fileManager.user = self.user
	local minHistoryId = params[1]
	local code = self.fileManager:rollbackTo(minHistoryId)
	if code then
		ngx.say(cjson.encode({ result = "OK" }))
	else
		ngx.say(cjson.encode({ result = "NG", message = self.fileManager.errorMessage }))
	end
end

function C:index(params)
	self.stash.requestPath = "/" .. table.concat(params, "/")
	self.stash.baseUri = self.config.uri.file.manager
	self.stash.user = self.user
	self.fileManager.user = self.user
	local methodUpper = self.req.method:upper()

	if "GET" == methodUpper then
		self.templateFileName = "file/index.tpl"
    -- POST /file/dir1/dir2
	-- directoryName=dir3
	-- fileName=file1
	elseif "POST" == methodUpper then
		local reqParams = self.req:params()
		ngx.header["Content-Type"] = "application/json"
		local isSuccess = false
        -- for old javascript begin
--		if reqParams["fileName"] then
--			local fileName = reqParams["fileName"]
--			if not fileName then throw("file name is empty.") end
--			local filePath = table.concat(params, "/") .. "/" .. fileName
--			isSuccess = self.fileManager:newFile(filePath, reqParams["fileBody"])
--		elseif reqParams["directoryName"] then
        -- for old javascript end
		if reqParams["directoryName"] then
			local directoryName = reqParams["directoryName"]
			if not directoryName then throw("directory name is empty.") end
			local dirPath = table.concat(params, "/") .. "/" .. directoryName
			isSuccess = self.fileManager:newDirectory(dirPath)
		end

		if isSuccess then
			ngx.say(cjson.encode({ result = "OK" }))
		else
			ngx.say(cjson.encode({ result = "NG", message = self.fileManager.errorMessage }))
		end
	elseif "PUT" == methodUpper then
		local oldName = table.concat(params, "/")
		local reqParams = self.req:params()
		local newName = reqParams["newName"]
		local newFile = reqParams["newFile"]

		if newName then
			oldName = ngx.unescape_uri(oldName)
			self.fileManager:rename(oldName, newName)
			ngx.header["Content-Type"] = "application/json"
			ngx.say(cjson.encode({ result = "OK" }))
		elseif newFile then
			self.fileManager:upload(oldName, reqParams)
			ngx.header["Content-Type"] = "application/json"
			ngx.say(cjson.encode({ result = "OK" }))
		else
			throw("invalid request")
		end
	elseif "DELETE" == methodUpper then
		local reqParams = self.req:params()
		local name = table.concat(params, "/")
		name = ngx.unescape_uri(name)
		self.fileManager:remove(name)
		ngx.header["Content-Type"] = "application/json"
		ngx.say(cjson.encode({ result = "OK" }))
	elseif "OPTIONS" == methodUpper then
		if not self.user then
			ngx.header["Content-Type"] = "application/json"
			ngx.say(cjson.encode({ result = "NG" }))
			return
		end
		local reqParams = self.req:params()
		local name = table.concat(params, "/")
		name = ngx.unescape_uri(name)
		self.fileManager:freeze(self.user.userId, name)
		ngx.header["Content-Type"] = "application/json"
		ngx.say(cjson.encode({ result = "OK" }))
	end
end

function C:list(params)
	local requestPath = table.concat(params, "/")
	local list = self.fileManager:list(requestPath)
	ngx.header["X-Parent-Path"] = self.fileManager:getParentUri(requestPath)
	ngx.header["Content-Type"] = "application/json"
	ngx.say(cjson.encode(list))
end

--
-- curl -X PUT http://macbookpro:8000/api/file/zip -F branch=master -F file="@./result/files.zip"
--
function C:zip(params)
  local reqParams = self.req:params()
  local file = reqParams["file"]
  local branchName = reqParams["branch"]
  ngx.header["Content-Type"] = "application/json"

  local dir = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. branchName
  os.remove(dir)
  lfs.mkdir(dir)

  local zipPath = dir .. "/" .. file.name
  local zipfile = io.open(zipPath, "w")
  if not zipfile then throw("cannot write " .. zipPath) end
  zipfile:write(file.body)
  zipfile:close()

  local cmd = ngx.ERR, "/usr/bin/unzip -u " .. zipPath .. " -d " .. dir .. " -q"  
  io.popen(cmd)
  ngx.log(cmd)

  ngx.say(cjson.encode(
    {
      result = "OK",
      branch = branchName,
    }
  ))
end


return C

