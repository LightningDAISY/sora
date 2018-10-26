local O = {}
local idAndNames = {}

function O.new(o)
	o = o or {}
	return o
end

function O:setModel()
	if not self.adminLogModel then
		local AdminLog = require "models.admin_log"
		self.adminLogModel = AdminLog:new()
	end
end

function O:adminNameById(adminId)
	if adminId == 0 then return adminId end
	if not idAndNames[adminId] then
		local AdminBase = require "models.admin_base"
		local model = AdminBase:new()
		local adminData = model:getAdminData(adminId)
		if adminData then
			idAndNames[adminId] = adminData.admin_name
		else
			idAndNames[adminId] = "(ID " .. adminId .. " removed)"
		end
	end
	return idAndNames[adminId]
end

function O:write(adminId, projectId, name, value)
	self:setModel()
	adminId   = adminId or 0
	projectId = projectId or 0
	return self.adminLogModel:insert({
		admin_id     = adminId,
		project_id   = projectId,
		column_name  = name,
		column_value = value
	})
end

function O:read(adminId, projectId, limit, offset)
	self:setModel()

	local whereSet = {}
	if adminId then
		table.insert(whereSet, "admin_id = ")
		table.insert(whereSet, adminId)
	end
	if projectId then
		table.insert(whereSet, "project_id IN ")
		table.insert(whereSet, {0,projectId})
	end

	local rows = self.adminLogModel:select(
		whereSet,
		{ "id", "desc" },
		limit,
		offset
	)
	for i=1, table.getn(rows) do
		rows[i].admin_name = self:adminNameById(rows[i].admin_id)
	end

	return rows
end

return O

--[[

Write Log
	self.adminLog:write(adminId, "role", "updated 2 to 1")

Read Log
	self.adminLog:read(adminId)

--]]

