<!DOCTYPE html>
<html>
	<head>
		<title><% statusCode %> <% statusString %></title>
	</head>
	<body>
		<div class="uk-container uk-container-center">
			<h2 style="margin-top:30px;"><% statusCode %> <% statusString %></h2>

			<div class="uk-grid">
				<div class="uk-width-1-3">
					<div class="uk-panel uk-panel-box uk-panel-box-primary">
						<h3>Request Path</h3>
						<p><% ngx.req.get_method() %> <% ngx.var.uri %></p>
						<p><% ngx.now() - ngx.req.start_time() %> sec</p>
						<h3>Request Header</h3>
						<code><pre><% ngx.req.raw_header() %></pre></code>
					</div>
				</div>
				<div class="uk-width-2-3">
					<div class="uk-panel uk-panel-box uk-panel-box-primary">
						<h3>Message</h3>
						<div><% err %></div>
						<h3>Trace</h3>
						<code><pre><% trace %></pre></code>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>

