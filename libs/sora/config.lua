local SoraConfig = {}
local toml = require "toml"
local util = require "sora.util"

function SoraConfig.new(o)
  o = o or {}
  return o
end

function SoraConfig:parse(filePath)
  filePath = filePath or ngx.var.baseDir .. "/etc/config.toml"
  local fileBody = util.loadFile(filePath)
  return toml.parse(fileBody)
end

return SoraConfig
