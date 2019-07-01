#! /usr/bin/env resty
local cjson = require "cjson"
local rex   = require "rex_pcre"

local function getBaseDir()
  local fname = debug.getinfo(2,'S').short_src
  local itr = rex.split(fname, "/")
  local dirs = {}
  for node in itr do
    if #node > 0 then table.insert(dirs, node) end
  end
  table.remove(dirs, #dirs)
  return "/" .. table.concat(dirs, "/")
end

function throw(code,str)
	if type(code) ~= "number" then
		str = code
		code = 500
	end
	ngx.status = code
	local SoraBase = require "sora.base"
	local base = SoraBase:new()
	str = str or ""

	if type(str) == "table" then
		str.result = "NG"
		str.statusCode = code
		str.traceback = debug.traceback()
		base:_errorLog(str.traceback)
		error(str)
	end
	base:_errorLog(str .. " : " .. debug.traceback())
	traceback = debug.traceback()
	error(str)
end

local function init()
  ngx.var.baseDir = ngx.var.baseDir or getBaseDir()
  ngx.ctx.traceback = true
  ngx.ctx.config = require("sora.config"):new():parse()
  ngx.header.content_type = "text/html; charset=utf-8" -- is default
  package.path = ngx.var.baseDir .. "/libs/?.lua;" .. ngx.var.baseDir .. "/?.lua;" .. package.path
end

local function main()
  init()
  local SoraRequest = require "sora.request"
  local req = SoraRequest:new()
  local SoraRouter = require "sora.router"
  local router = SoraRouter:new(req)
  local controller, action, params = router:autoRoute()
  if not controller then
    throw(404, "the page is not found.")
  end
  controller.templateFileName = ""

  local newController = controller[action](controller,params)
  if newController and newController.overwrite then controller = newController end
  local view = require("sora.view"):new(req, controller)
  view:render()
end

local ok, err = pcall(main)

if not ok then
  if type(err) == "table" then
    ngx.status = err.statusCode
    ngx.say(cjson.encode(err))
    ngx.exit(err.status or 500)
  else
    local SoraRequest = require "sora.request"
    local req = SoraRequest:new()
    local SoraBase = require "sora.base"
    local base = SoraBase:new()
    local ErrorController = require(base.config.dir.controller .. ".errors")
    local controller = ErrorController:new(req)
    if type(traceback) ~= "string" then traceback = debug.traceback() end
	  controller:index(
        ngx.status,
        err,
        traceback
      )
      local SoraView = require "sora.view"
      local view = SoraView:new(req, controller)
      view:render()
	end
end

