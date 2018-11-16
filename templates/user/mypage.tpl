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
		<table>
			<tr>
				<th>nickname</th>
				<td><% user.nickname %></td>
			</tr>
			<tr>
				<th>loginId</th>
				<td><% user.userName %></td>
			</tr>
			<tr>
				<th>role</th>
				<td><% user.role %>/10</td>
			</tr>
			<tr>
				<th>mail address</th>
				<td><% user.mailAddress %></td>
			</tr>
			<tr>
				<th>personality</th>
				<td><% user.personality %></td>
			</tr>
		</table>
	<div>
		<a href="<% config.uri.base %>/user/modify"><button>modify</button></a>
	</div>
</div>
<? include("include/footer.tpl") ?>
