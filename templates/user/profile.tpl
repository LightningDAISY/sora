<? include("include/header.tpl") ?>
<nav class="tabs is-full top-margin-large">
	<a href="<%= config.base.uri %>">Top</a>
	<a href="<%= config.base.uri .. config.mypage.uri %>">Profile</a>
	<a href="<%= config.base.uri .. config.mypage.uri %>/profile/" class="active">Modify</a>
</nav>
<div class="container">
	<? include("include/alert.tpl") ?>
	<form action="<%= config.base.uri .. config.mypage.uri %>/profile/" method="post" enctype="multipart/form-data">
		<fieldset class="top-margin-large">
			<legend>Your Profile</legend>
			<label for="nickname">Nickname</label>
			<input id="nickname" type="text" name="nickname" value="<% reqParams.nickname or detail.nickname %>" />
			<label for="mail-address">Mail Address <small>[ optional ]</small></label>
			<input id="mail-address" type="text" name="mail_address" value="<% reqParams.mail_address or detail.mail_address %>" />
			<label for="password">New Login Password</label>
			<input id="password" type="password" name="password" value="<% reqParams.password or "" %>" />
			<label for="personality">Personality <small>[ optional free text ]</small></label>
			<textarea id="personality" name="personality" rows="8" cols="40" placeholder="set your message, profile or introduction"><% reqParams.personality or detail.personality %></textarea>
			<label for="icon">image<small>[ optional ]</small></label>
			<? if detail.icon_filename then ?>
				<div><img src="<%= config.usericon.uri %>/<%= detail.icon_filename %>" width="100px" alt="current image" /></div>
			<? end ?>
			<input id="icon" type="file" name="icon" />
			<input type="submit" name="update" value="update" />
			<input type="reset" value="reset" />
		</fieldset>
	</form>

</div>
<? include("include/footer.tpl") ?>
