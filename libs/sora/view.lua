SoraView = {
	extensions = {
		-- extension = require-module-name
		html     = "renderResty",
		mustache = "renderLustache",
		lustache = "renderLustache",
		liluat   = "renderLiluat",
		tpl      = "renderTemplate",
	}
}

function SoraView.new(o, req, ctr)
	o = o or {}
	o.controller = ctr
	local base = require "sora.base"
	local parent = base:new(req)
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function SoraView:renderSelf()
	-- templateFileName未定義ならtemplate使わない
	if self.controller.templateFileName:len() <= 0 then return end

	local util = require "sora.util"
	ngx.var.template_location = _G.BaseDir .. "/" .. self.config.dir.template
	local fname = self.config.dir.template .. "/" .. self.controller.templateFileName
	local fbody = util.loadFile(fname)
	if nil == fbody then throw(500, fname .. " is not found.") end
	local restyTemplate = require "resty.template"
	local template = restyTemplate.new(fbody)
	restyTemplate.caching(true)
	template.render(self.controller.stash)
end

local function getHashLength(hash)
	local len = table.getn(hash)
	if len < 1 then len = nil end
	return len
end

function SoraView:setStashDefault()

	-- req headers for mustache template
	ngx.req.headerPairs = {}
	for key,val in pairs(ngx.req.get_headers()) do
		table.insert(ngx.req.headerPairs, { name = key, value = val })
	end
	ngx.req.headerPairsLength = getHashLength(ngx.req.headerPairs)

	-- res headers for mustache template
	ngx.resp.headerPairs = {}
	for key, val in pairs(ngx.resp.get_headers()) do
		table.insert(ngx.resp.headerPairs, { name = key, value = val })
	end
	ngx.resp.headerPairsLength = getHashLength(ngx.resp.headerPairs)

	ngx.req.read_body()

	-- req post-body for mustache template
	ngx.req.postParamPairs = {}
	local args, err = ngx.req.get_post_args()
	if err then throw(err) end
	for key,val in pairs(args) do
		table.insert(ngx.req.postParamPairs, { name = key, value = val })
	end
	ngx.req.postParamPairsLength = getHashLength(ngx.req.postParamPairs)


	-- req get-params for mustache template
	ngx.req.getParamPairs = {}
	local args, err = ngx.req.get_uri_args()
	if err then throw(err) end
	for key, val in pairs(args) do
		table.insert(ngx.req.getParamPairs, { name = key, value = val })
	end
	ngx.req.getParamPairsLength = getHashLength(ngx.req.getParamPairs)

	self.controller.stash.ngx = ngx
	self.controller.stash.config = self.config
	self.controller.stash.responseTime = ngx.now() - ngx.req.start_time()
end

function SoraView:renderResty()
	ngx.var.template_location = _G.BaseDir .. "/" .. self.config.dir.template
	local restyTemplate = require "resty.template"
	local template = restyTemplate.new(self.controller.templateFileName)
	local templateCache = true
	if self.config.template.cache == "off" then
		templateCache = false
	end
	restyTemplate.caching(templateCache)

	self.controller.stash.config = self.config
	template.render(self.controller.stash)
end

function SoraView:renderLustache()
	local fname = _G.BaseDir .. "/" ..
				  self.config.dir.template .. "/" ..
				  self.controller.templateFileName
	local util = require "sora.util"
	local fbody = util.loadFile(fname)
	if nil == fbody then throw(500, fname .. " is not found.") end

	local template = require "lustache"
	self:setStashDefault()
	ngx.say(template:render(fbody, self.controller.stash))
end

function SoraView:renderLiluat()
	local fname = _G.BaseDir .. "/" ..
				  self.config.dir.template .. "/" ..
				  self.controller.templateFileName
	local util = require "sora.util"
	local fbody = util.loadFile(fname)
	if nil == fbody then throw(500, fname .. " is not found.") end
	local liluat = require("liluat")
	local compiled_template = liluat.compile(fbody)
	local rendered_template = liluat.render(compiled_template, self.controller.stash)
	ngx.say(rendered_template)
end

function SoraView:setIncludeMethod()
    self.controller.stash.include = function(path)
        local fname = _G.BaseDir .. "/" ..
                      self.config.dir.template .. "/" ..
                      path
        local fbody = self.controller.stash.util.loadFile(fname)
        if nil == fbody then throw(500, fname .. " is not found.") end
        local template = require "template"
        local compiled = template.compile(fbody)
        template.print(compiled, self.controller.stash, ngx.print)
    end
end

function SoraView:renderTemplate()
	local fname = _G.BaseDir .. "/" ..
				  self.config.dir.template .. "/" ..
				  self.controller.templateFileName
	local util = require "sora.util"
	local fbody = util.loadFile(fname)
	if nil == fbody then throw(500, fname .. " is not found.") end

	self:setStashDefault()
	self.controller.stash.util = util
	self:setIncludeMethod()
	local template = require "template"
	local compiled = template.compile(fbody)
	template.print(compiled, self.controller.stash, ngx.print)
end

function SoraView:render()
	-- templateFileName未定義ならtemplate使わない
	if self.controller.templateFileName:len() <= 0 then return end
	-- template-type by extensions
	local ext = self.controller.templateFileName:match("[^%.]+$")
	if ext then
		if self.extensions[ext] then
			methodName = self.extensions[ext]
			self[methodName](self)
		end
	end
end

return SoraView
