::Hardened.HooksMod.hook("scripts/entity/world/settlement", function(q) {
	q.setOwner = @(__original) function( _o )
	{
		__original(_o);

		local newBanner = _o.getBannerSmall();
		foreach (attached in this.m.AttachedLocations)
		{
			if (!attached.m.IsShowingBanner) continue;

			attached.setBanner(newBanner);
		}
	}
});