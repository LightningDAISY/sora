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
  			"userId", "bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ユーザID'",
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
  			"userId", "bigint unsigned NOT NULL COMMENT 'ユーザID'",
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
			"COMMENT", "'ユーザセッション'"
		}
	)
end

function C:createPathFreeze(table)
	return table:create(
		"pathFreeze",
		{
			"path",      "varchar(255) NOT NULL COMMENT '親URI ex./dir'",
			"fileName",  "varchar(255) NOT NULL COMMENT 'ファイル名'",
			"userId",    "int unsigned NOT NULL COMMENT 'ユーザID'",
			"expiredAt", "int unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(path, fileName)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'ファイルの凍結用。凍結者本人と、凍結者よりRoleが小さいユーザは解除可。'"
		}
	)
end

function C:createPathHistory(table)
	return table:create(
		"pathHistory",
		{
			"id", "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"path",      "varchar(255) NOT NULL COMMENT '親URI ex./dir'",
			"fileName",  "varchar(255) NOT NULL COMMENT 'ファイル名'",
			"userId",    "int unsigned NOT NULL COMMENT 'ユーザID'",
			"diff",      "text COMMENT '差分'",
			"expiredAt", "int unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(id)",
			"KEY", "byFile (path,fileName)",
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'ファイル差分'",
		}
	)
end

function C:createContact(table)
	return table:create(
		"contact",
		{
			"id", "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"name", "varchar(255) NOT NULL DEFAULT '' COMMENT '送信者名(自由入力)'",
			"email", "varchar(255) NOT NULL DEFAULT '' COMMENT 'メールアドレス(自由入力)'",
			"message", "text COMMENT '本文(自由文)'",
			"expiredAt", "int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint(20) unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint(20) unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(id)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'管理者問合せ'"
		}
	)
end

function C:createAuthoritarian(table)
	return table:create(
		"authoritarian",
		{
			"id", "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"author", "varchar(255) NOT NULL DEFAULT '' COMMENT '詠み人'",
			"title", "varchar(255) NOT NULL DEFAULT '' COMMENT '書籍名'",
			"company", "varchar(255) NOT NULL DEFAULT '' COMMENT '出版社名'",
			"message", "text COMMENT '本文'",
			"expiredAt", "int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt", "bigint(20) unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt", "bigint(20) unsigned NOT NULL COMMENT '更新日時'",
			"KEY", "(author)",
			"PRIMARY KEY", "(id)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'名言データベース'"
		}
	)
end

function C:createWikiEntry(table)
	return table:create(
		"wikiEntry",
		{
			"id",          "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"userId",      "bigint unsigned NOT NULL COMMENT '詠み人ID'",
			"categoryId",  "int unsigned NOT NULL DEFAULT 0 COMMENT 'wikiCategoryID'",
			"subject",     "varchar(255) NOT NULL DEFAULT '' COMMENT '表題'",
			"body",        "text COMMENT '本文'",
			"source",      "text COMMENT 'Wikiフォーマット本文'",
			"expiredAt",   "int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt",   "bigint(20) unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt",   "bigint(20) unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(id)",
			"UNIQUE",      "byName(categoryId, subject)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'Wikiエントリ'"
		}
	)
end

function C:createWikiHistory(table)
	return table:create(
		"wikiHistory",
		{
			"id",          "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"entryId",     "bigint NOT NULL COMMENT 'エントリID'",
			"userId",      "bigint unsigned NOT NULL COMMENT '詠み人ID'",
			"diff",        "text COMMENT '差分'",
			"sourceDiff",  "text COMMENT '原文差分'",
			"expiredAt",   "int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt",   "bigint(20) unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt",   "bigint(20) unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(id)",
			"KEY",         "byEntry(entryId)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'Wiki更新履歴'"
		}
	)
end

function C:createWikiCategory(table)
	return table:create(
		"wikiCategory",
		{
			"id",          "bigint NOT NULL AUTO_INCREMENT COMMENT 'ユニークID'",
			"name",        "varchar(255) COMMENT 'カテゴリ名'",
			"expiredAt",   "int(10) unsigned NOT NULL DEFAULT '0' COMMENT '有効期限'",
			"createdAt",   "bigint(20) unsigned NOT NULL COMMENT '作成日時'",
			"updatedAt",   "bigint(20) unsigned NOT NULL COMMENT '更新日時'",
			"PRIMARY KEY", "(id)",
			"UNIQUE",      "byName(name)"
		},
		{
			"ENGINE", "InnoDB",
			"DEFAULT CHARSET", "utf8",
			"COMMENT", "'Wikiカテゴリ'"
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

	-- path_freeze
	if mysqlSetup:isExists("pathFreeze") then
		self.stash.mysqlHasTable.pathFreeze = 1
	else
		self:createPathFreeze(mysqlSetup)
	end

	-- pathHistory
	if mysqlSetup:isExists("pathHistory") then
		self.stash.mysqlHasTable.pathHistory = 1
	else
		self:createPathHistory(mysqlSetup)
	end

	-- contact
	if mysqlSetup:isExists("contact") then
		self.stash.mysqlHasTable.contact = 1
	else
		self:createContact(mysqlSetup)
	end

    -- authoritarian
	if mysqlSetup:isExists("authoritarian") then
		self.stash.mysqlHasTable.authoritarian = 1
	else
		self:createAuthoritarian(mysqlSetup)
	end

	-- wiki_entry
	if mysqlSetup:isExists("wikiEntry") then
		self.stash.mysqlHasTable.wikiEntry = 1
	else
		self:createWikiEntry(mysqlSetup)
	end

	-- wiki_history
	if mysqlSetup:isExists("wikiHistory") then
		self.stash.mysqlHasTable.wikiHistory = 1
	else
		self:createWikiHistory(mysqlSetup)
	end

	-- wiki_category
	if mysqlSetup:isExists("wikiCategory") then
		self.stash.mysqlHasTable.wikiCategory = 1
	else
		self:createWikiCategory(mysqlSetup)
	end

end

return C
