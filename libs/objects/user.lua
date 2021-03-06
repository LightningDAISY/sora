local O = {}
local AimiBase = require "sora.base"
setmetatable(O, { __index = AimiBase:new() })
local Util = require "sora.util"

function O:new(userId, projectId)
	if userId and tonumber(userId) < 1 then throw("invalid userId") end
	if projectId and tonumber(projectId) < 1 then throw("invalid projectId") end
	local ins = {
		userId    = userId,
		projectId = projectId,
		errors    = {},
		cached    = {},
	}
	setmetatable(
		ins,
		{
			__index = O
		}
	)
	return ins
end

function O:getBase(userId)
	userId = userId or self.userId
	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	local baseRows = base:select({ "userId = ", userId }, nil, 1)
	return baseRows[1]
end

function O:getDetail(userId)
	userId = userId or self.userId
	local UserDetail = require 'models.userDetail'
	local detail = UserBase:new()
	local detailRows = detail:select({ "userId = ", userId }, nil, 1)
	return detailRows[1]
end

function O:getInfo(userId)
	userId = userId or self.userId
	local base = self:getBase(userId) or {}
	local detail = self:getDetail(userId) or {}
	for key,val in pairs(detail) do
		base[key] = val
	end
	return base
end

function O:_isEmpty(reqParams)
	for i,key in ipairs({ "username", "password", "projectid", "mailAddress" }) do
		if not reqParams[key] then
			table.insert(self.errors,  key .. " is not defined.")
		elseif #reqParams[key] < 1 then
			table.insert(self.errors,  key .. " is empty.")
		end
	end
	if #self.errors > 0 then return true end
end

function O:isExists(reqParams)
	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	local rows = base:select(
		{
			"userName  =", reqParams.username,
			"projectId =", reqParams.projectId,
		},
		nil,1
	)
	if #rows > 0 then
		table.insert(self.errors, "the LoginID is exists.")
		return true
	end

	if reqParams.nickname and #reqParams.nickname > 0 then
		local UserDetail = require 'models.userDetail'
		local base = UserDetail:new()
		local rows = base:select(
			{
				"nickname  =", reqParams.nickname,
				"projectId =", reqParams.projectId,
			},
			nil,1
		)
		if #rows > 0 then
			table.insert(self.errors, "the nickname is exists.")
			return true
		end
	end
end

function O:signup(reqParams)
	if #self.config.auth.passPhrase > 0 then
		if reqParams.passPhrase ~= self.config.auth.passPhrase then
			self:_errorLog("invalid passPhrase " .. reqParams.passPhrase)
			return
		end
	end
	if self:_isEmpty(reqParams)  then
		self:_errorLog("empty")
		return
	end
	if self:isExists(reqParams) then
		self:_errorLog("is exists")
		return
	end

	-- create
	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	local res  = base:add(
		{
			userName  = reqParams.username,
			projectId = reqParams.projectId,
			password  = reqParams.password,
		}
	)
	if not res then
		table.insert(self.errors, base.errorMessage)
		self:_errorLog("userBase insert error " .. base.errorMessage)
		return false
	end

	local userId = res.insert_id
	local UserDetail = require 'models.userDetail'
	local detail = UserDetail:new()
	local detailRes = detail:insert({
		userId       = userId,
		projectId    = reqParams.projectId,
		nickname     = reqParams.nickname,
		mailAddress  = reqParams.mailAddress,
		personality  = reqParams.personality,
	})
	if detailRes and detailRes.insert_id then return res end
	self:_errorLog("userDetail insert error ")

	-- rollback
	base:delete(
		{
			"userId    = ", userId,
			"projectId = ", projectId,
		}
	)
end

function O:signin(userName, projectId, password)
	if not userName or #userName < 1 then
		table.insert(self.errors, "username is empty.")
	end
	if not password or #password < 1 then
		table.insert(self.errors, "password is empty.")
	end
	if #self.errors > 0 then return end

	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	local rows = base:select(
		{
			"userName  =", userName,
			"projectId =", projectId,
		}
	)
	if rows and #rows > 0 then
		local row = rows[1]
		if row.hashAlgorithm then
			if row.hashAlgorithm:lower() == "md5" then
				password = Util.md5(password)
			end
		end
		if row.password == password then
			self.userId    = row.userId
			self.projectId = row.projectId
			self.base      = row
		else
			table.insert(self.errors, "invalid password.")
		end
	else
		table.insert(self.errors, "unknown username.")
	end
	if #self.errors > 0 then return false else return true end
end

function O:saveIcon(userId, param)
	if not userId then return end
	local imageTypes = {
		["image/jpeg"] = ".jpg",
		["image/png"]  = ".png",
		["image/gif"]  = ".gif",
	}
	if not param.type then return end
	if not imageTypes[param.type] then return end
	local saveFileName = "i" .. userId .. imageTypes[param.type]
	if not os.rename(param.temp, self.config.usericon.dir .. "/" .. saveFileName) then
		throw(500, "cannot save the file " .. saveFileName)
	end
	return saveFileName
end

function O:modify(params)
	if not params.userId or not params.projectId then throw("ids are empty.") end

	-- update userBase
	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	if not params.password or params.password:len() < 1 then params.password = nil end
	local res = base:modify({
		userId    = params.userId,
		userName  = params.userName,
		projectId = params.projectId,
		password  = params.password,
	})
	if not res then throw(500, base.errorMessage) end

	-- TODO
	--file copy /tmp to public_html/static/icon
	-- and filename to params.icon_filename
	if params.icon and params.icon.size > 0 then
		params.iconFilename = self:saveIcon(params.userId, params.icon)
	end

	-- update userDetail
	local UserDetail = require 'models.userDetail'
	local detail = UserDetail:new()
	local detailRes = detail:modify({
		userId        = params.userId,
		projectId     = params.projectId,
		nickname      = params.nickname,
		mailAddress   = params.mailAddress,
		personality   = params.personality,
		iconFilename  = params.iconFilename,
	})
	if detailRes and detailRes.affected_rows > 0 then return detailRes end
end

function O:byNickname(nickname)
	local UserDetail = require 'models.userDetail'
	local detail = UserDetail:new()
	local rows = detail:select({ "nickname = ", nickname }, nil, 1)
	if not rows or #rows < 1 then return end

	local user = rows[1]
	local UserBase = require 'models.userBase'
	local base = UserBase:new()
	local baseRows = base:select({ "userId = ", user.userId }, nil, 1)

	for name,val in pairs(baseRows[1]) do
		user[name] = user[name] or val
	end
	return user
end

return O

