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
						<input id="login-username" tabindex="1" name="username" value="<? if username then ?><% username %><? end ?>" type="text" placeholder="User Name" />
					</p>
					<p>
						Do you already have an account?
					</p>
					<ul class="list bare-list">
						<li><label for="no"><input id="no" tabindex="4" name="issignup" value="true" type="radio" class="radio" /> No, create this account now.</li>
						<li><label for="yes"><input id="yes" tabindex="5" name="issignup" value="" type="radio" class="radio" checked="checked" /> Yes, my password is:</li>
					</ul>
					<p>
						<label for="login-password">Password</label>
						<input id="login-password" tabindex="2" name="password" value="<? if password then ?><% password %><? end ?>" type="password" placeholder="Password" />
					</p>
					<p class="is-center">
						<button type="submit" tabindex="3">sign in</button>
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
