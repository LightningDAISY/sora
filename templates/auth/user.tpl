<? include("include/header.tpl") ?>

<? if #message > 0 then ?>
<div class="uk-width-1-1">
	<div class="uk-alert uk-alert-warning">
		<span class="white-text"><% message %></span>
	</div>
</div>
<? end ?>

<div class="uk-container-center uk-panel uk-panel-box uk-panel-box-primary">
	<form action="<%= authUri %>" method="post" class="uk-form">
		<input placeholder="UserID" name="userid" value="<% userid %>" type="text">
		<input name="password" value="<% password %>" type="password">
		<select name="projectid" class="uk-width-1-1" id="project-id">
			<? for i=1,#projects,1 do ?>
				<option value="<% projects[i].project_id %>"><% projects[i].project_name %></option>
			<? end ?>
		</select>
		<button class="uk-button uk-button-primary uk-width-1-1" type="submit">Login</button>
	</form>
</div>

<? include("include/footer.tpl") ?>
