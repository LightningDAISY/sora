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

