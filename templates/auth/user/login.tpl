<? include("include/header.tpl") ?>
<div class="container">
    <div class="hero is-full-screen">
		<? include("include/alert.tpl") ?>
		<div class="logo is-center is-vertical-align">
			<form action="<%= config.auth.userLoginURI %>" method="post">
				<input type="hidden" name="projectid" value="<% projectid or 1 %>" />
				<fieldset>
					<legend>Sign in</legend>
					<p>
						<label for="login-username">Name</label>
						<input id="login-username" name="username" value="<? if username then ?><% username %><? end ?>" type="text" placeholder="User Name" />
					</p>
					<p>
						Do you already have an account?
					</p>
					<ul class="list bare-list">
						<li><label for="no"><input id="no" name="issignup" value="true" type="radio" class="radio" /> No, create this account now.</li>
						<li><label for="yes"><input id="yes" name="issignup" value="" type="radio" class="radio" checked="checked" /> Yes, my password is:</li>
					</ul>
					<p>
						<label for="login-password">Password</label>
						<input id="login-password" name="password" value="<? if password then ?><% password %><? end ?>" type="password" placeholder="Password" />
					</p>
					<p class="is-center">
						<input type="submit" value="sign in" />
					</p>
				</fieldset>
			</form>
		</div>
		<nav class="tabs is-center">
			<a href="<%= config.auth.userRedirectURI %>">top</a>
		</nav>
	</div>
</div>
<? include("include/footer.tpl") ?>
