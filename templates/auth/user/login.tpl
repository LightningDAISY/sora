<? include("include/header.tpl") ?>
<div class="container">
	<div class="card is-fullwidth">
		<footer class="card-footer">
			<a class="card-footer-item" href="/">top</a>
		</footer>
	</div>
    <div class="helo">
		<? include("include/alert.tpl") ?>
		<form action="<%= config.auth.userLoginURI %>" method="post">
			<input type="hidden" name="projectid" value="<% projectid or 1 %>" />
			<fieldset style="padding:20px; margin:10px;">
				<legend>Sign in</legend>
				<div>
					<label class="label">
						Name
						<input class="input" tabindex="1" name="username" value="<? if username then ?><% username %><? end ?>" type="text" placeholder="User Name" />
					</label>
				</div>
				<div style="margin-top: 10px;">
					<p>
						Do you already have an account?
					</p>
					<div style="margin-top: 10px;">
						<label class="radio">
							<input tabindex="4" name="issignup" value="true" type="radio" class="radio" />
							No, create this account now.
						</label>
					</div>
					<div style="margin-top: 5px;">
						<label class="radio">
							<input tabindex="5" name="issignup" value="" type="radio" class="radio" checked="checked" />
							Yes, my password is:
						</label>
					</div>
				</div>
				<div style="margin-top: 10px;">
					<p>
						<label class="label">
							Password
							<input tabindex="2" class="input" name="password" value="<? if password then ?><% password %><? end ?>" type="password" placeholder="Password" />
						</label>
					</p>
				</div>
				<div style="margin-top: 10px;">
					<button type="submit" class="button is-info" tabindex="3">sign in</button>
				</div>
			</fieldset>
		</form>
	</div>
	<div class="card is-fullwidth">
		<footer class="card-footer">
			<a class="card-footer-item" href="/">top</a>
		</footer>
	</div>
</div>
<? include("include/footer.tpl") ?>
