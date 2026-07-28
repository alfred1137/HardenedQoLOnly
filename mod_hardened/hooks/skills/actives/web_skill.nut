::Hardened.HooksMod.hook("scripts/skills/actives/web_skill", function(q) {
	q.create = @(__original) function()
	{
		__original();

		this.m.FatigueCost = 50;	// Vanilla: 25
	}

	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		// Remove the tooltip, added by Reforged, which used to describe the cooldown no longer needed
		::Hardened.util.HD_deleteBulletPoint(ret, function(_entry) {
			return _entry.text.find("Can only be used once every") != null;
		});

		return ret;
	}

	q.onUse = @(__original) function( _user, _targetTile )
	{
		__original(_user, _targetTile);

		// Feat: We remove the vanilla cooldown
		this.m.Cooldown = 0;
	}
});
