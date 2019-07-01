local FileManager = {}
local lfs   = require "lfs"
local rex   = require "rex_pcre"
local util  = require "sora.util"

function FileManager.new(o, ext)
  o = o or {}
  o.ext = ext
  o.errorMessage = ''
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

function FileManager:isYaml(path)
  if path:lower():match("%.ya?ml$") then return true end
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

function FileManager:nameByPath(path)
  local itr = rex.split(path, "/")
  local parts = {}
  for part in itr do
    if #part > 0 then
      table.insert(parts, part)
    end
  end
  local fname = table.remove(parts,#parts)
  local dir   = "/" .. table.concat(parts, "/")
  return dir, fname
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

function FileManager:isExists(path)
  local file = io.open(path, "r")
  if not file then return end
  file:close()
  return true
end

function FileManager:fread(path)
  local file = io.open(path, "r")
  if not file then return end
  local fbody = file:read("*a")
  file:close()
  return fbody
end

function FileManager:list(path)
  local result = {}
  if path == "/" then path = "" end
  path = ngx.unescape_uri(path)
  local basePath = ngx.var.baseDir .. "/" .. self.config.dir.file .. "/" .. path
  if not util.fileExists(basePath) then return result end

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
        result[fileName].path = "/" .. path .. "/" .. fileName
      else
        result[fileName].path = "/" .. fileName
      end
      local attr = lfs.attributes(fullPath)
      local permission = attr.permissions
      local permissionInt = attr.permissions
      result[fileName].uid = attr.uid
      result[fileName].gid = attr.gid

      if path:len() > 0 then
        result[fileName].uri   = self.config.uri.filePublic  .. result[fileName].path
        result[fileName].fmuri = self.config.uri.fileManager .. result[fileName].path
      else
        result[fileName].uri   = self.config.uri.filePublic   .. result[fileName].path
        result[fileName].fmuri = self.config.uri.fileManager  .. result[fileName].path
      end
      result[fileName].permissionString = permission
      result[fileName].permission = permission2int(permission)
      result[fileName].isDirectory = 0
      result[fileName].size = 0
      if attr.mode == "directory" then
        result[fileName].isDirectory = 1
      else
        result[fileName].size = attr.size
      end
    end
  end
  return result
end

function FileManager:filePathList(fullPath, filePaths)
  fullPath = fullPath:gsub("/+$", "")
  filePaths = filePaths or {}
  local nodeNames = {}
  for nodeName in lfs.dir(fullPath) do
    table.insert(nodeNames, nodeName)
  end

  for i,nodeName in ipairs(nodeNames) do
    if nodeName ~= "." and nodeName ~= ".." then
      local nodePath = fullPath .. "/" .. nodeName
      local attr = lfs.attributes(nodePath)
      if attr then
        if attr.mode == "directory" then
          local childPaths = self:filePathList(nodePath, filePaths)
          if childPaths then
            for i,childPath in ipairs(childPaths) do
                self:_debugLog(i .. " : " .. childPath)
              table.insert(filePaths, childPath)
            end
          end
      else
      table.insert(filePaths, nodePath)
      end
      end
    end
  end
end

function FileManager:filterByExtensions(filePaths, extensions)
  local rex = require("rex_pcre")
  local startIndex,endIndex
  local result = {}
  for i,extension in ipairs(extensions) do
    for i,path in ipairs(filePaths) do
    startIndex, endIndex = rex.find(path, "\\." .. extension .. "$")
      if startIndex then
        table.insert(result, path)
      end
    end
  end
  return result
end

function FileManager:yamlDetails(filePaths)
  local yaml = require "yaml"
  for i,path in ipairs(filePaths) do
    local fp = assert(io.open(path, "r"))
    local fbody = fp:read("*all")
    fp:close()
    self:_debugLog(self:_dump(require("yaml").eval(fbody)))
  end
  return filePaths

end

function FileManager:listAllYamls(path)
  path = path:gsub("/+$", ""):gsub("^/", "")
  path = ngx.unescape_uri(path)
  local fullPath = _G.BaseDir .. "/" .. self.config.dir.file .. "/" .. path
  local filePaths = {}
  self:filePathList(fullPath, filePaths)
  filePaths = self:filterByExtensions(filePaths, { "yaml", "yml" })
  local yamls = self:yamlDetails(filePaths)
  return yamls
end

function FileManager:getParentUri(requestUri)
  if requestUri == "/" then return self.config.uri.filemanager end
  local modified = rex.gsub(
    requestUri,
    "[^/]+/*$",
    ""
  )
  if modified ~= "" then modified = "/" .. modified end
  return self.config.uri.fileManager .. modified
end

return FileManager

