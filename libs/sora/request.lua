SoraRequest = {}
local Util = require "sora.util"
local rex = require("rex_pcre")

function SoraRequest.new(o)
	o = o or {}
	local base = require "sora.base"
	local parent = base:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	o.method = ngx.req.get_method() -- "GET", "POST", "DELETE" ....
	return o
end

function SoraRequest:headers()
	local util = require "sora.util"
	local hash = {}
	local rawHeader = ngx.req.raw_header()
	local headers = util.split(rawHeader, "\r?\n")
	for i, header in ipairs(headers) do
		if i ~= 1 then
			local keyValue = util.split(header, ":%s+", 2)
			if keyValue[1] then
				if not keyValue[1]:find("[^%w-]") then
					hash[keyValue[1]] = keyValue[2]
				end
			end
		end
	end
	return hash
end

function SoraRequest:path()
	local util = require "sora.util"
	local uriArgs = util.split(ngx.var.request_uri, "%?")
	return uriArgs[1]
end

function SoraRequest:rawArgs()
	local util = require "sora.util"
	local uriArgs = util.split(ngx.var.request_uri, "%?")
	if #uriArgs <= 1 then return "" end
	return uriArgs[2]
end

-- files = {
--	icon {
--		temp : /tmp/lua_1nqfD6
--		size : 238494 
--		name : icon 
--		type : image/jpeg 
--		file : bg.jpg
--	}
--}
function SoraRequest:setArgs(name, args)
	if not args then return end
	if type(args) == "string" then throw(500, args) end
	self[name] = self[name] or {}
	for key,val in pairs(args) do
		self[name][key] = val
	end
end

-- need uri unescape
-- ex. ngx.unescape_uri(req.rawBody())
function SoraRequest:rawBody()
	ngx.req.read_body()
	return ngx.req.get_body_data()
end

function SoraRequest:rawBodyFile()
	ngx.req.read_body()
	return ngx.req.get_body_file()
end

function SoraRequest:getUpperHeaders()
	local headers = self:headers()
	local upperHeaders = {}
	for key,value in pairs(headers) do
		upperHeaders[key:upper()] = value
	end
	return upperHeaders
end

function SoraRequest:getContentType()
	local headers = self:getUpperHeaders()
	return headers["CONTENT-TYPE"]
end


function SoraRequest:getBoundary()
	local contentType = self:getContentType()
	local itr = rex.split(contentType, ";\\s*")
	itr()
	local itr2 = itr()
	itr = rex.split(itr2, "=")
	itr()
	return "--" .. itr()
end

function SoraRequest:trim(str)
	str = rex.gsub(str, "^\\s+", "")
	str = rex.gsub(str, "\\s+$", "")
	return str
end

--[[
example)

------WebKitFormBoundaryWpURyBTIXXflBa3Q
Content-Disposition: form-data; name="newName"

value1
------WebKitFormBoundaryWpURyBTIXXflBa3Q--
--]]
function SoraRequest:getMultipartParams()
	local boundary = self:getBoundary()
	if not boundary then throw("cannot get boundary") end
	local rawBody = self:rawBody()
	local itr = rex.split(rawBody, boundary)
	local body,name,fileName,startIndex,endIndex,capture
	local result = {}
	while true do
		--body = self:trim(itr())
		body = itr()
		if not body then break end
		--body = rex.gsub(body, "\\s\\s\\z", "")
		body = rex.gsub(body, "\\r\\n\\z", "")
		if body ~= "" then
		    if body == "--" then break end
			startIndex, endIndex = rex.find(body, "\r\n\r\n")
            if startIndex and endIndex then
				local nameBlock = body:sub(1, startIndex - 1)
				name     = rex.match(nameBlock, 'name="(.+?)"')
				fileName = rex.match(nameBlock, 'filename="(.+?)"')
				if fileName then
					result[name] = {
						name = fileName,
						body = body:sub(endIndex + 1, body:len())
					}
				else
					local value = body:sub(endIndex + 1, body:len())
					result[name] = value
				end
			end
		end
	end
	return result
end

function SoraRequest:isMultipart()
	local contentType = self:getContentType()
	if contentType then
		if contentType:find("multipart%/form%-data") then
			return true
		end
	end
	return false
end

function SoraRequest:params(isMultipart)
	isMultipart = isMultipart or self:isMultipart()

	if isMultipart then
		return self:getMultipartParams()
	end

	-- GET
	local result = {}
	for key,val in pairs(ngx.req.get_uri_args()) do
    	result[key] = val
	end

	-- POST
	ngx.req.read_body()
	local args = ngx.req.get_post_args()
	for key, val in pairs(args) do
		if result[key] then
			result[key] = { result[key], val }
		else
			result[key] = val
		end
	end
	return result
end

return SoraRequest
