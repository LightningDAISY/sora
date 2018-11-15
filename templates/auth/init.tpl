<? include("admin/include/header.tpl") ?>

<? if message and #message > 0 then ?>
<div class="uk-width-1-1">
	<div class="uk-alert uk-alert-warning">
		<span class="white-text"><% message %></span>
	</div>
</div>
<? end ?>

<div class="uk-container-center uk-panel uk-panel-box uk-panel-box-primary">
	<form action="<%= config.base.uri %><%= config.auth.uri %><%= config.auth.initURI %>" method="post" class="uk-form">
		<fieldset>
			<legend>Create root account</legend>
			<div class="uk-form-row uk-form-icon">
				<i class="uk-icon-user"></i>
				<input placeholder="Admin UserID" name="userid" value="<% userid %>" type="text">
			</div>
			<div class="uk-form-row uk-form-icon">
				<i class="uk-icon-key"></i>
				<input name="password" value="<% password %>" type="password">
			</div>
			<div class="uk-form-row">
				<button class="uk-button uk-button-primary uk-width-1-1" type="submit">create</button>
			</div>
		</fieldset>
	</form>
</div>

<? include("admin/include/footer.tpl") ?>
