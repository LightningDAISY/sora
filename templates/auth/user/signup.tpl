<? include("include/header.tpl") ?>
<div class="container">
    <div class="hero is-full-screen">
		<? include("include/alert.tpl") ?>
		<div class="logo is-center is-vertical-align">
			<form action="<%= config.auth.userLoginURI %>" method="post">
				<input type="hidden" name="projectid" value="<% projectid or 1 %>" />
				<input type="hidden" name="issignup" value="1" />
				<fieldset>
					<legend>Sign up</legend>
					<p>
						<label for="login-username">Name <small>is Private</small></label>
						<input id="login-username" name="username" value="<? if username then ?><% username %><? end ?>" type="text" placeholder="User Name" />
					</p>
					<p>
						<label for="login-password">Password</label>
						<input id="login-password" name="password" value="<? if password then ?><% password %><? end ?>" type="password" placeholder="Password" />
					</p>
					<p>
						<label for="nickname">Nickname <small>Your Public Name</small></label>
						<input id="nickname" name="nickname" value="<? if nickname then ?><% nickname %><? end ?>" type="text" placeholder="Nickname" />
					</p>
					<p>
						<label for="mail-address">Mail Address</label>
						<input id="mail-address" name="mailAddress" value="<? if mailAddress then ?><% mailAddress %><? end ?>" type="text" placeholder="Mail Address" />
					</p>
					<p class="is-center">
						<input type="submit" value="sign up" />
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
