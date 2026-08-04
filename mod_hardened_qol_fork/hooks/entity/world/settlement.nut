::Hardened.HooksMod.hook("scripts/entity/world/settlement", function(q) {
	q.getUIInformation = @(__original) function()
	{
		local ret = __original();

		// We reset all situation UI information and recalculate them
		// This fixes the vanilla issue where they purposefully hide duplicate situation
		// But this information is very important in order to understand certain weird town prices or states
		ret.Situations = [];
		foreach (situation in this.getSituations())
		{
			ret.Situations.push({
				ID = situation.getID(),
				Icon = situation.getIcon(),
			});
		}

		return ret;
	}

	q.updatePlayerRelation = @(__original) function()
	{
		__original();

		// We now also update the nameplates of all attached locations of this settlement
		if (this.isPlayerControlled()) return;
		if (!this.hasLabel("name")) return;

		foreach (attachedLocation in this.m.AttachedLocations)
		{
			attachedLocation.updatePlayerRelation();
		}
	}
});