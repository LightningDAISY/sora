<!DOCTYPE html>
<html>
	<head>
		<title>File Manager</title>
		<link href="/static/filemanager/base.css" rel="stylesheet" />
		<script src="/static/filemanager/base.js"></script>
		<script>
			window.onload = function() {
				showCurrent("<%= baseUri %>/list","<%= requestPath %>")
			}
		</script>
	</head>
	<body>
	<div id="topmenu">
		<div>
			<? if user then ?>
				<a href="/sora/auth/user/logout">logout</a>
			<? else ?>
				<a href="/sora/auth/user/login">login</a>
			<? end ?>
		</div>
		<? if user then ?>
			<div>こんにちは <% user.nickname %>さん</div>
		<? end ?>
	</div>
