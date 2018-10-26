module("SoraUtil", package.seeall)

function split(str,pattern,limiter)
	limiter = limiter or nil
	pattern = "(.-)" .. "(" .. pattern .. ")"
	local result = {}
	local offset = 0;
	local counter = 1
	if limiter == 1 then
		table.insert(result, str)
		return result
	end
	for part,sep in string.gmatch(str, pattern) do
		counter = counter + 1
		offset = offset + string.len(part) + string.len(sep)
		table.insert(result, part)
		if limiter and limiter <= counter then
			break
		end
	end
	if(string.len(str) > offset) then
		table.insert(result, string.sub(str,offset + 1))
	end
	return result
end

function trim(str)
	if type(str) ~= "string" then
		throw("cannot trim " .. type(str))
	end
	return str:gsub("^%s+", ""):gsub("%s+$", "")
end

--
-- local str = Util.dumper({ a = "A", b = "B"})
-- print(str)
--
function dumper(struct, deep, result)
	if not struct then return "nil" end

	result = result or ""
    deep = deep or 0
    deep = deep + 1

    local indent = ""
    for i=deep, 0, -1 do indent = indent .. "  " end
    result = result .. indent .. "{" .. "\n"

    if type(struct) ~= "table" then return struct .. "\n" end
    for key,val in pairs(struct) do
        indent = ""
        if type(val) == "table" then
            for i=deep+1, 0, -1 do indent = indent .. "  " end
            result = result .. indent .. key .. "\n"
            result = dumper(val, deep, result)
        else
            local indent = ""
            for i=deep+1, 0, -1 do indent = indent .. "  " end
            if type(val) == "boolean" then
                local trueOrFalse = "(false)"
                if val then trueOrFalse = "(true)" end
                result = result .. indent .. key .. " : " .. trueOrFalse .. "\n"
            elseif type(val) == "function" then
                result = result .. indent .. key .. " : (function)\n"
            elseif type(val) == "userdata" then
                result = result .. indent .. key .. " : (userdata)\n"
			elseif type(val) == "number" then
				result = result .. indent .. key .. " : " .. tostring(val) .. "\n"
			else
                result = result .. indent .. key .. " : " .. val .. "\n"
            end
        end
    end

    indent = ""
    for i=deep, 0, -1 do indent = indent .. "  " end
    result = result .. indent .. "}" .. "\n"
    deep = deep - 1
    return result .. "\n"
end

function datetime_full(time)
	time = time or os.time()
	local wd = os.date("%w", time)
	local wn = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
	return os.date("%Y-%m-%d[", time) .. wn[tonumber(wd)] .. os.date("] %H:%M:%S %Z", time)
end

function datetime_int(time)
	time = time or os.time()
	return os.date("%Y%m%d%H%M%S", time)
end

function fileExists(fname)
   local fp = io.open(fname,"r")
   if fp then io.close(fp) return true else return false end
end

function reverse(tbl)
	for i=1, math.floor(#tbl / 2) do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end
end

function loadFile(filename)
	local file = io.open(filename, "r")
	if not file then return end
	local fBody = ""
	for line in file:lines() do
		fBody = fBody .. line .. "\n"
	end
	return fBody
end

function loadJSON(filename)
	local fbody = loadFile(filename)
	local cjson = require("cjson")
	return cjson.decode(fbody)
end

function removeSingleComment(str)
	local rex = require("rex_pcre")
	str = rex.gsub(
		str,
		"\\s*//(.*)",
		""
	)
	return str
end

function removeMultiComment(str)
	local rex = require("rex_pcre")
	str = rex.gsub(
		str,
		"/\\*.+?\\*/",
		"",
		nil,
		"s"
	)
	return str
end

function loadJS(fileName)
	local fbody = loadFile(fileName)
	fbody = removeSingleComment(fbody)
	fbody = removeMultiComment(fbody)
	local cjson = require("cjson")
	return cjson.decode(fbody)
end

function toLines(str)
	local lines = {}
	for val in str:gmatch("(.-)\r?\n") do
		table.insert(lines, val)
	end
	return lines
end

function parseIni(lines)
	local lpeg = require "lpeg"
	local sp = lpeg.P(" ") ^ 0 --0文字以上の空白
	local bb = lpeg.P("[")		-- [
	local eb = lpeg.P("]")		-- ]
	local eq = lpeg.P("=")		-- =
	local cr = lpeg.P("\r")		-- <CR>
	local lf = lpeg.P("\n")		-- <LF>
	local sc = lpeg.P(";")		-- ;
	local key   = (lpeg.P(1) - lpeg.P(" ") - eq) ^1
	local value = lpeg.P(1) ^0

	local ptComment = sp * sc
	local ptSubject = sp * bb * lpeg.C((lpeg.P(1) - eb) ^1) * eb
	local ptBody    = sp * lpeg.C(key) * sp * eq * sp * lpeg.C(value)

	local struct = {}
	local parentName = nil
	if not type(lines) == "table" then 
		lines = toLines(lines)
	end
	local matched
	for i,line in ipairs(lines) do
		if not lpeg.match(ptComment, line) then
			matched = lpeg.match(ptSubject, line)
			if matched then
				parentName = matched
				if not struct[parentName] then struct[parentName] = {} end
			else
				ckey,val = lpeg.match(ptBody, line)
				if ckey then
					if parentName then
						struct[parentName][ckey] = val
					else
						struct[ckey] = val
					end
				end
			end
		end
	end
	return struct
end

function loadIni(filename)
	local file = io.open(filename, "r")
	if not file then return {} end
	local fbody = {}
	for line in file:lines() do
	    table.insert(fbody, line)
	end
	local hash = parseIni(fbody)
	file:close()
	return hash
end

function tohex(str)
    local hexstr = "0123456789abcdef"
    local s = ""
	local num = tonumber(str)
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == "" then s = "0" end
    return s
end

--
-- 先頭のアンダースコアだけ無視して
-- _abc_def を _abcDefに変換。
-- _abc_defはabc_defと同じ意味と見なす。
--
function snake2camel(str)
	local us = str:sub(1,1)
	if us == "_" then str = str:sub(2) end

	local result = str:lower():gsub(
		"(_%w)",
		function(matched) return matched:sub(2):upper() end
	)
	if us == "_" then result = us .. result end
	return result
end

function toPascalCase(str)
	str = str:lower()
	local letterFirst = str:sub(1,1)
	letterFirst = letterFirst:upper()
	return letterFirst .. str:sub(2,str:len())
end

function array2Hash(rows, key)
	if type(rows) ~= "table" then throw(500, "invalid argument.") end
	local hash = {}
	for i,row in ipairs(rows) do
		hash[row[key]] = row
	end
	return hash
end

function md5(str)
	if not str then
		str = ""
	elseif type(str) == "number" then
		str = tostring(str)
	elseif type(str) == "table" then
		str = dumper(str)
	end
	return ngx.md5(str)
end

return SoraUtil

-----------------------------------------------------------
-- いちいちrequireして使います。
-- （一度requireされたファイルはLua内でキャッシュされます）
-- 以下の要領で.（ドット）でcallする点だけ注意しましょう。
--
-- local util = require "sora.util"
-- local md5String = util.md5("xyz")
-----------------------------------------------------------
