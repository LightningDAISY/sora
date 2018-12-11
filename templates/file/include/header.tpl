<!DOCTYPE html>
<html>
	<head>
		<title>File Manager</title>
		<link href="/static/filemanager/base.css" rel="stylesheet" />
		<link href="/static/filemanager/app.css" rel="stylesheet" />
		<script defer src="https://use.fontawesome.com/releases/v5.5.0/js/solid.js" integrity="sha384-Xgf/DMe1667bioB9X1UM5QX+EG6FolMT4K7G+6rqNZBSONbmPh/qZ62nBPfTx+xG" crossorigin="anonymous"></script>
		<script defer src="https://use.fontawesome.com/releases/v5.5.0/js/fontawesome.js" integrity="sha384-bNOdVeWbABef8Lh4uZ8c3lJXVlHdf8W5hh1OpJ4dGyqIEhMmcnJrosjQ36Kniaqm" crossorigin="anonymous"></script>
		<script src="/static/filemanager/base.js"></script>
		<script>
			window.onload = function() {
				showCurrent("<%= baseUri %>/list","<%= requestPath %>")
			}
		</script>
	</head>
	<body>
	<div id="topmenu">
		<nav class="nav">
			<div class="nav-left">
        		<a class="nav-item is-brand" href="/">Swagger Server</a>
			</div>
			<div class="nav-center">
				<a class="nav-item" href="/">Home</a>
				<a class="nav-item" href="/static/swagger/editor'">Editor</a>
				<a class="nav-item" href="/static/swagger/ui">UI</a>
				<a class="nav-item" href="/sora/file'">FileManager</a>
			</div>
			<div class="nav-right nav-menu">
				<span class="nav-item">
					<a class="button" href="/sora/user/mypage">
						<span>MyPage</span>
					</a>
          <a class="button is-primary" href="/sora/auth/user/login">
            <span id="topmenu-login"><? if user then ?>Logout<? else ?>Login<? end ?></span>
          </a>
        </span>
      </div>
    </nav>
