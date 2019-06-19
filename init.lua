_G.BaseDir = "/var/www/sora"
package.path =  _G.BaseDir .. "/libs/?.lua;" .. package.path

local auth = require("resty.auth")

local ok, msg = auth.setup {
    scheme    = "basic",
    shm       = "nonce",
    user_file = "/etc/basic_auth/.htpasswd",
    expires   = 10,
    replays   = 5,
    timeout   = 30,
}

if not ok then error(msg) end
local ok, msg = auth.setup {
    scheme= "basic",
    user_file= "htpasswd"
}
if not ok then print(msg) end

