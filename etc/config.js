/*
    config
*/
{
    /******************
	 * ストレージ設定 *
	 ******************/
	// MySQL (管理側)
    "MySQL" : {
		"hostname" : "127.0.0.1",
		"port"     : 3306,
        "username" : "sorauser",
        "password" : "password",
        "schema"   : "soraAdmin"
    },
   	// MySQL (サービス側)
	"mysqlService" : {
		"hostname" : "127.0.0.1",
		"port"     : 3306,
		"username" : "sorauser",
		"password" : "password",
		"schema"   : "sora"
	},
	// Redis
	"redis" : {
		"hostname" : "127.0.0.1",
		"port" : 6379
	},

	/********************
	 * ディレクトリ設定 *
	 ********************/
    "dir" : {
		// ログファイルの位置
        "log"     : "logs",
		// 公開ファイルの位置
        "public"  : "public_html",
		// 静的ファイルを示す識別子(/static/の下なら静的ファイル)
        "static"  : "static",
		// ファイルマネージャのルート
		"file"    : "public_html/static/files",
		// テンポラリ
		"temp"    : "temp",

		"controller": "controllers",
        "model"   : "models",
        "template": "templates"
    },
    // ファイル設定
    "file" : {
        "log" : {
            "access": "app.access.log",
        	"error" : "app.error.log",
			"debug" : "app.debug.log"
        }
    },

	// URI
	"uri" : {
		"base" : "/sora",
		"file" : {
			"manager" : "/sora/file",
			"public"  : "/static/files"
		}
	},

	/******************
	 * ユーザ認証周り *
	 ******************/
	"auth" : {
		// ログインフォームURI
		"userLoginURI" : "/sora/auth/user/login",
		// 対象外URI
		"userExcludeURI" : "/auth/",
		// ユーザログイン後の遷移先(トップページ)
		"userRedirectURI" : "/sora/file",
		// ユーザ権限エラーの遷移先
		"userForbiddenURI" : "/sora/auth/user/forbidden",
		// ユーザパスワードをハッシュ化する (true/false)
		"pass2hash" : "true",
		"hashAlgorithm" : "md5"
	},
	// セッションcookie
	"session" : {
		// 管理セッションCookieの名前
		"aname" : "sid",
		// ユーザセッションCookieの名前
		"uname" : "usid",
		// セッションID乱数の最小値
		"minOfDigit" : 1000000000,
		// セッションID乱数の最大値
		"maxOfDigit" : 9999999999,
		// セッションCookieのpath
		"path" : "/sora/",
		// セッションの有効期限(秒)
		"expireSec" : 36000,
		// JWTトークンの秘密鍵
		"jwtSecret" : "xxxxxx"
	},
	"template" : {
		// resty-templateのキャッシュ設定
		"cache" : "off"
	},

	/**********
	 * router *
	 **********/
	"router" : {
		// 何か設定するとルートキャッシュにredisを使います。
		// falseにするとグローバル変数を使います。
		// コントローラが100も200も無ければグローバル変数が高速安定です。
		// "rediskey" : "LuaRouter"
		"rediskey" : false
	},

	/**************
	 * サイト情報 *
	 **************/
	"site" : {
		"title" : "sora",
		"subtitle" : "luajit framework"
	},
    "environment" : {
        "name" : "devel"
    }
}

