local C = {}
local cjson = require "cjson"

function C.new(o, req)
	o = o or {}
	o.req = req
	local ParentController = require "sora.controller"
	local parent = ParentController:new()
	setmetatable(
		o,
		{
			__index = parent
		}
	)
	return o
end

function C:createUserBase(table)
	return table:create(
		"userBase",
		{
  			"userId", "int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ユーザID'",
			"userName", "varchar(255) NOT NULL COMMENT 'ログインユーザ名'",
			"password", "varchar(255) NOT NULL COMMENT 'ログインパスワード'",
			"hashAlgorithm", "varchar(255) NOT NULL DEFAULT '' COMMENT 'passwordの暗号化アルゴリズム'",
			"projectId", "tinyint unsigned NOT NULL DEFAULT '1' COMMENT 'プロジェクトID'",
			"role", "tinyint unsigned NOT NULL DEFAULT '9' COMMENT '9:最小 0:管理者'",
			"expiredAt", "bigint unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(`userId`)",
			"UNIQUE KEY", "byNameAndProject (`userName`,`projectId`)",
			"KEY", "by_auth (`userName`,`projectId`)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'ユーザ基本情報'"
		}
	)
end

function C:createUserDetail(table)
	return table:create(
		"userDetail",
		{
  			"userId", "int unsigned NOT NULL AUTO_INCREMENT COMMENT 'ユーザID'",
			"projectId", "tinyint unsigned NOT NULL DEFAULT '1' COMMENT 'プロジェクトID'",
			"nickname", "varchar(255) NOT NULL COMMENT 'ニックネーム'",
			"mailAddress", "varchar(254) DEFAULT NULL COMMENT '連絡先メールアドレス'",
			"personality", "text COMMENT '自己紹介'",
			"iconFilename", "varchar(255) DEFAULT NULL COMMENT 'nullならデフォルト画像'",
			"expiredAt", "bigint unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint unsigned NOT NULL COMMENT '更新日時'",
  			"PRIMARY KEY", "(userId)",
  			"UNIQUE KEY", "nameAndProject (nickname, projectId)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'ユーザ詳細'"
		}
	)
end

function C:createUserSession(table)
	return table:create(
		"userSession",
		{
			"sessionId", "varchar(255) NOT NULL COMMENT 'セッションID'",
			"userId", "int unsigned NOT NULL COMMENT 'ユーザID'",
			"projectId", "tinyint unsigned NOT NULL DEFAULT '1'",
			"expiredAt", "int unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(sessionId)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'管理者セッション'"
		}
	)
end

function C:index(params)
	self.templateFileName = "setup.tpl"
	local mysqlSetup = require "models.setup"
	self.stash.mysqlHasTable = {}
	local returnCode = mysqlSetup:new(true,true)
	if returnCode then
		self.stash.mysqlConnection = 1
	else
		return
	end

	-- user_base
	if mysqlSetup:isExists("userBase") then
		self.stash.mysqlHasTable.userBase = 1
	else
		self:createUserBase(mysqlSetup)
	end

	-- user_detail
	if mysqlSetup:isExists("userDetail") then
		self.stash.mysqlHasTable.userDetail = 1
	else
		self:createUserDetail(mysqlSetup)
	end

	-- user_session
	if mysqlSetup:isExists("userSession") then
		self.stash.mysqlHasTable.userSession = 1
	else
		self:createUserSession(mysqlSetup)
	end

end

return C
