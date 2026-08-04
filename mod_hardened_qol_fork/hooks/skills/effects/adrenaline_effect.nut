::Hardened.HooksMod.hook("scripts/skills/effects/adrenaline_effect", function(q) {
	q.create = @(__original) function()
	{
		__original();

		this.m.Name = "Adrenaline Rush";		// Vanilla: Adrenaline
	}
});
