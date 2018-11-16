<? include("include/header.tpl") ?>
	<div id="topmenu">
		<div>
			<? if user then ?>
				<a href="/sora/auth/user/logout">logout</a>
			<? else ?>
				<a href="/sora/auth/user/login">login</a>
			<? end ?>
		</div>
		<? if user then ?>
			<div>こんにちは <% user.nickname %>さん</div>
		<? end ?>
	</div>
	<div class="container">
		<form action="<% config.uri.base %>/user/modify" method="post">
			<table>
				<tr>
					<th><label for="nickname">nickname</label></th>
					<td><input type="text" name="nickname" id="nickname" value="<% user.nickname %>" /></td>
				</tr>
				<tr>
					<th><label for="loginid">loginId</label></th>
					<td><input type="text" name="userName" id="loginid" value="<% user.userName %>" /></td>
				</tr>
				<tr>
					<th><label for="password">password</label></th>
					<td><input type="text" name="password" id="password" value="" /></td>
				</tr>
				<tr>
					<th><label for="mailAddress">mail address</label></th>
					<td><input type="text" name="mailAddress" id="mailAddress" value="<% user.mailAddress %>" /></td>
				</tr>
				<tr>
					<th><label for="personality">personality</label></th>
					<td><textarea name="personality" id="personality"><% user.personality %></textarea></td>
				</tr>
				<tr>
					<td colspan="2"><button type="submit">modify</button></td>
				</tr>
			</table>
		</form>
	</div>
</div>
<? include("include/footer.tpl") ?>
