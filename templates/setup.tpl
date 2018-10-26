<? include("include/header.tpl") ?>
<div class="container">
    <div class="hero is-full-screen">
		<div class="logo is-center is-vertical-align">
			<h1><%= config.site.title %></h1>
			<p><%= config.site.subtitle %></p>
		</div>
	</div>

	<div>
		<h2>MySQL</h2>
		<h3>connection</h3>
		<p>
			<? if mysqlConnection then ?>
				connected
			<? else ?>
				<? if config.mysqlService then ?>
					cannot connect the mysql [<%= config.mysqlService.hostname %>:<%= config.mysqlService.port %>]
				<? else ?>
					cannot connect the mysql [config.mysqlService is empty]
				<? end ?>
			<? end ?>
		</p>

		<h3>exists tables</h3>
		<? if mysqlHasTable then ?>
			<? for name,value in pairs(mysqlHasTable) do ?>
				<? if value then ?>
					<p><%= name %> is exists</p>
				<? else ?>
					<p><%= name %> is created</p>
				<? end ?>
			<? end ?>
		<? else ?>
			<p>do setup</p>
		<? end ?>
	</div>

</div>
<? include("include/footer.tpl") ?>
