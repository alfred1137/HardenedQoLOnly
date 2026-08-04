::Hardened.HooksMod.hook("scripts/skills/effects/charmed_effect", function (q) {
	q.getName = @(__original) function()
	{
		return __original() + " (x" + this.m.TurnsLeft + ")";
	}

	q.onAdded = @(__original) function()
	{
		__original();

		local actor = this.getContainer().getActor();
		if (!actor.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " is charmed for " + ::MSU.Text.colorPositive(this.m.TurnsLeft) + " turns");
		}
	}
});
