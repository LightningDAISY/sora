<? include("include/header.tpl") ?>
<div class="container">
	<div class="card is-fullwidth">
		<footer class="card-footer">
			<a class="card-footer-item" href="/">top</a>
		</footer>
	</div>
    <div class="hero">
		<? include("include/alert.tpl") ?>
		<form action="<%= config.auth.userLoginURI %>" method="post">
			<input type="hidden" name="projectid" value="<% projectid or 1 %>" />
			<input type="hidden" name="issignup" value="1" />
			<fieldset style="padding:20px; margin:10px;">
				<legend>Sign up</legend>
				<div>
					<label class="label">
						Login Name
						<input class="input" name="username" value="<? if username then ?><% username %><? end ?>" type="text" placeholder="User Name" />
					</label>
				</div>
				<div style="margin-top:10px">
					<label class="label">
						Password
						<input class="input" name="password" value="<? if password then ?><% password %><? end ?>" type="password" placeholder="Password" />
					</label>
				</div>
				<div style="margin-top:10px">
					<label class="label">
						Nickname <small>Public Name</small>
						<input class="input" name="nickname" value="<? if nickname then ?><% nickname %><? end ?>" type="text" placeholder="Nickname" />
					</label>
				</div>
				<div style="margin-top:10px">
					<label class="label">
						Mail Address
						<input class="input" name="mailAddress" value="<? if mailAddress then ?><% mailAddress %><? end ?>" type="text" placeholder="Mail Address" />
					</label>
				</div>
				<div style="margin-top:10px">
					<button type="submit" class="button is-primary">sign up</button>
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
