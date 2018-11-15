		<? if errorMessages and #errorMessages > 0 then ?>
			<div class="card is-error is-center">
				<h2>errors</h2>
				<ul>
					<? for i,message in ipairs(errorMessages) do ?>
						<li><% message %></li>
					<? end ?>
				</ul>
			</div>
		<? end ?>
		<? if primaryMessages and #primaryMessages > 0 then ?>
			<div class="card is-primary is-center">
				<ul>
					<? for i,message in ipairs(primaryMessages) do ?>
						<li><% message %></li>
					<? end ?>
				</ul>
			</div>
		<? end ?>

