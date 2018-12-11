local C = {}
local Util = require "sora.util"
local FileManager =  require "sora.filemanager"
local cjson = require "cjson"

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

function C:index(params)
	self.stash.requestPath = "/" .. table.concat(params, "/")
	self.stash.baseUri = self.config.uri.file.manager
	self.stash.user = self.user
	local methodUpper = self.req.method:upper()

	if "GET" == methodUpper then
		self.templateFileName = "file/index.tpl"
	elseif "POST" == methodUpper then
		local reqParams = self.req:params()
		local directoryName = reqParams["directoryName"]
		if not directoryName then throw("directory name is empty.") end
		ngx.header["Content-Type"] = "application/json"
		local dirPath = table.concat(params, "/") .. "/" .. directoryName
		if self.fileManager:newDirectory(dirPath) then
			ngx.say(cjson.encode({ result = "OK" }))
		else
			ngx.say(cjson.encode({ result = "NG" }))
		end
	elseif "PUT" == methodUpper then
		local oldName = table.concat(params, "/")
		local reqParams = self.req:params()
		local newName = reqParams["newName"]
		local newFile = reqParams["newFile"]
		if newName then
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

return C

