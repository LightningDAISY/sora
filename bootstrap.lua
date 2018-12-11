#! /usr/bin/lua

-- ControllerConfigにURIと認証情報を記述します。
-- キーがURIの先頭確定部分、値のauthTypeに使用する認証機構(AuthTypesで定義)、roleに10までのroleを設定します。
-- roleは参照に必要な権限で、1が最高、10が最低です。
-- 完全な公開ページなら、何も書かない({})か、roleのみ10に設定します。
--
--     ["/public/"] = { role = 10 },
--
-- ControllerConfigに未記述のpath（コントローラ）はNOT FOUNDになります。
--
-- また、各コントローラ（controllers/?.lua）内にControllerMethodsを宣言できます。
--
--     local ControllerMethods = {
--         index = true,
--         tomd5 = true,
--     }
--
-- この場合、routerからはindexとtomd5以外へのリクエストがnot foundになります。
-- ControllerMethodsを書かないか、{}を渡した場合、アンダースコアで始まっていないメソッドは
-- 全てリクエストURIとして有効になります。
--
local ControllerConfig = {
	["/"]       = { role = 10, authType = "user" },
	["/admin/"] = { role = 10, authType = "admin" },
	["/user/"]  = { role = 10, authType = "user" },
	["/docs/"]  = { role = 10 },
	["/setup/"] = { role = 10 },
	["/file/"]  = { role = 10, authType = "user" },
}

_G.BaseDir = "/var/www/sora"
traceback = true

--package.path = package.path .. ";./libs/?.lua;"
package.path =	_G.BaseDir .. "/libs/?.lua;" ..
		_G.BaseDir .. "/?.lua;" ..
		--"/usr/local/openresty/lualib/?.lua;" .. -- <-about "resty/upload.lua" is not found
		package.path 

require "sora.init"
local cjson = require "cjson"

local AuthTypes = {
	admin = {
		session  = {
			method         = "_getAdminSession",
			idColumnName   = "adminId",
			roleColumnName = "role",
		},
		auth = {
			method   = "_adminAuth",
			fallback = "/auth/admin",
		},
		status = {
			method   = "_getAdminBase"
		},
	},
	user = {
		session  = {
			method         = "_getUserSession",
			idColumnName   = "userId",
			roleColumnName = "role",
		},
		auth = {
			method   = "_userAuth",
			-- fallback = "/auth/user",

			--fallback無指定なら未ログインでも処理続行。
			--(ログインしなくても参照は可能な状態)
			--self.isLoginがtrueならログイン済
			--self.userにテーブルuserBaseの各フィールド。
		},
		status = {
			method   = "_getUserInfo"
		},
	},
}

--
-- どこからでも以下のコードでエラー画面に遷移できます。
-- throw(500, "cannot connect to the database.")
--
-- 
--
-- throw(500, { message = "cannot connect to the database." })
--
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
		str.statusCode = code
		str.traceback = debug.traceback()
		base:_errorLog(str.traceback)
		error(str)
	end
	base:_errorLog(str .. " : " .. debug.traceback())
	traceback = debug.traceback()
	error("Exception: " .. str)
end

local function main()
	ngx.header.content_type = "text/html; charset=utf-8"

	local SoraRequest = require "sora.request"
	local req = SoraRequest:new()
	local SoraRouter = require "sora.router"
	local router = SoraRouter:new(req, ControllerConfig)
	local controller, method, params, authType, controllerRole = router:autoRouteCache()
	if not controller then
		controller, method, params, authType, controllerRole = router:autoRoute()
		if not controller then throw(404, req:path() .. " is not found.") end
	end
	controller.templateFileName = ""

	-- auth begin
	local userId = nil
	if authType then
		if not AuthTypes[authType] then
			throw(
				404,
				"Auth-Type " .. authType .. " is not defined."
			)
		end
		local methodName = AuthTypes[authType].auth.method
		if not controller[methodName] then
			throw("auth method is not found - authTypeを指定する場合、controller.user.baseをコントローラのparentにしてください")
		end
		local sessionRecord = controller[methodName](controller,AuthTypes[authType],params)

		-- 未認証時リダイレクト済(なので何もせず帰る)
		-- (fallback未登録ならリダイレクトも無し)
		-- (controller.isLoginをnilにするだけ)
		if not sessionRecord and AuthTypes[authType].auth.fallback then
			return
		end
		--認証済ならself.userを設定。未認証なら何も設定しない。
		--(未認証時ここまで来るのはfallback未設定時のみ)
		-- set userID
		if sessionRecord then
			userId = sessionRecord[AuthTypes[authType].session.idColumnName]
			if userId then
				methodName = AuthTypes[authType].status.method
				controller.user = controller[methodName](controller, userId)
			end
			-- set projectID
			if sessionRecord.projectId then
				controller.projectId = sessionRecord.projectId
				if userId then
					controller.user.projectId = controller.projectId
				end
			end
		end
	end
	-- auth end

	local newController = controller[method](controller,params)
	if authType == "user" then
		if controller.user and controller.user.userId and controller.user.projectId then
			controller:_setUserSession(
				controller.user.userId,
				controller.user.projectId
			)
		end
	end

	if newController and newController.overwrite then controller = newController end
	local SoraView = require "sora.view"
	if userId and not controller.stash.userId then controller.stash.userId = userId end
	local view = SoraView:new(req, controller)
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

