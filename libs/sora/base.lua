local SoraBase = {}

function SoraBase.new(o, req)
	o = o or {}
	if req then o.req = req end
	local SoraConfig = require "sora.config"
	local config = SoraConfig:new()
	o.config = config:loadconfig()
	o.time = 0
	return o
end

function SoraBase:_getTime()
	if self.time <= 0 then
		-- local handle = io.popen("date +%s")
		-- local result = handle:read("*a")
		-- handle:close()
		-- now = result:match "^%s*(.-)%s*$"
		-- self.time = tonumber(now)
		self.time = os.time()
		-- time emulation begin
		-- time emulation end
	end
	return self.time
end

function SoraBase:_datetime(time)
	time = time or self:_getTime()
	return os.date("%Y-%m-%d %H:%M:%S", time)
end

function SoraBase:_fileAppend(fname,row)
	local fp = assert(io.open (fname, "a"))
	fp:write(row)
	fp:close()
end

function SoraBase:_fileCreate(fname,row)
	local fp = assert(io.open (fname, "w"))
	fp:write(row)
	fp:close()
end

function SoraBase:_dump(obj)
	if type(obj) == "table" then
		local cjson = require "cjson"
		return cjson.encode(obj)
	elseif not obj then
		return "(nil)"
	else
		return obj
	end
end

function SoraBase:_loadProjectConfig(projectName)
	local confName = _G.BaseDir .. "/" .. self.config.api.json
	local util = require "sora.util"
	local confStruct = util.loadJSON(confName)[projectName]
	if not confStruct then throw("config." .. projectName .. " is not found") end
	return confStruct
end

function SoraBase:_randomInt(min,max,seed)
	min  = min or 100000000
	max  = max or 999999999
	seed = seed or 123
	math.randomseed(os.time() .. collectgarbage("count") .. seed)
	local rand = math.random(min,max)
	return tostring(rand)
end

--
-- columnType : int,char,datetime or date
-- columnSize : 最大値 または 文字数
--
function SoraBase:_randomValue(columnType, columnSize)
	local min  = 1
	local max  = 100
	local rand = 0
	local seed = os.time() .. collectgarbage("count")
	local str  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-!$&-=~^|_<>;+*{}[],.?" --74chars
	if columnType == "int" then
		max = columnSize
		math.randomseed(seed)
		return tostring(math.random(min,max))
	elseif columnType == "char" then
		rand = ""
		for i=1,columnSize,1 do
			math.randomseed(os.time() .. collectgarbage("count") .. i)
			local idx = tostring(math.random(1, 74))
			rand = rand .. str:sub(idx,idx)
		end
		return rand
	elseif columnType == "date" then
		max = columnSize
		math.randomseed(seed)
		local year  = tostring(math.random(1970,2015))
		local month = tostring(math.random(1,12))
		local day   = tostring(math.random(1,28))
		return year .. "-" .. month .. "-" .. day
	elseif columnType == "datetime" then
		max = columnSize
		math.randomseed(seed)
		local year   = tostring(math.random(1970,2015))
		local month  = tostring(math.random(1,12))
		local day    = tostring(math.random(1,28))
		local hour   = tostring(math.random(0,23))
		local minute = tostring(math.random(0,59))
		return year .. "-" .. month .. "-" .. day .. "T" .. hour .. ":" .. min .. ":00"
	end
end

function SoraBase:_tablesave(dir, tbl)
	local fname = self:_randomInt() .. ".sql"
	local path = dir .. "/" .. fname
	self:_fileCreate(path, table.concat(tbl, "\n"))
	return fname
end

function SoraBase:_debugLog(str)
	local path = _G.BaseDir .. "/" .. self.config.dir.log .. "/" .. self.config.file.log.debug
	local datetime = "[" .. self:_datetime() .. "]\n"
	self:_fileAppend(path, datetime .. str .. "\n")
end

function SoraBase:_errorLog(str)
	local path = _G.BaseDir .. "/" .. self.config.dir.log .. "/" .. self.config.file.log.error
	local datetime = "[" .. self:_datetime() .. "] "
	self:_fileAppend(path, datetime .. str .. "\n")
end

function SoraBase:modExpireAt(datetime)
    local year = datetime:match("-(%d+) ")
    if not year then return datetime end
    if tonumber(year) >= 2000 then return datetime end
    local updated = datetime:gsub(
        "-(%d+) ",
        function (arg)
            return "-" .. (arg + 2000) .. " "
        end
    )
    return updated
end

function SoraBase:_setCookies(values, path, expireAt)
	local cookieArray = {}
	for i,cookie in ipairs(values) do
		local str = cookie.name .. "=" .. cookie.value
		if expireAt then str = str .. "; expires=" .. self:modExpireAt(expireAt) end
		if path then str = str .. "; path=" .. path end
		table.insert(cookieArray, str)
	end
	ngx.header["Set-Cookie"] = cookieArray
end

function SoraBase:_getCookies()
	local cookie = ngx.req.get_headers()["Cookie"]
	if not cookie then return {} end
	local util = require "sora.util"
	local rows = util.split(cookie, "%s*;%s*")
	local result = {}
	for i,row in ipairs(rows) do
		local arr = util.split(row, "%s*=%s*", 2)
		result[arr[1]] = arr[2]
	end
	return result
end

return SoraBase

--
-- 使用上の注意
--
-- 1. 現在日時が必要な場合はself:_getTime()で取得してください。（戻り値は数値型）
--
-- 実装上の注意
--
-- 1. 最終的に全インスタンスが継承します
-- 2. 即ちself:_getTime()でどこからでも時刻が取れなければならない
-- 3. 使用頻度の低いメソッドはsora/util.luaに記述します
--
