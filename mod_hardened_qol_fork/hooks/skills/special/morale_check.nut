::Hardened.HooksMod.hook("scripts/skills/special/morale_check", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Icon = "skills/status_effect_02_a.png";		// Vanilla: "skills/status_effect_02.png", but that default icon does not exist and sometimes causes log errors under Hardened
	}

	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		// Vanilla only defines tooltips for Fleeing, Breaking, Wavering and Confident. A state like Steady or some completely new state have no tooltips
		// We assume that ret == null means, that the tooltip for Steady was fetched
		// That should not normally happen in Vanilla, because then the morale check effect is hidden
		if (ret == null)
		{
			ret = [
				{
					id = 1,
					type = "title",
					text = this.getName(),
				},
				{
					id = 2,
					type = "description",
					text = "Focused and composed. This character is holding his ground with a steady mind.",
				},
			];
		}

		if (this.getContainer().getActor().getMoraleState() == ::Const.MoraleState.Fleeing)
		{
			ret.push({
				id = 20,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = ::Reforged.Mod.Tooltips.parseString("Try to [Rally|Concept.Rally] at the start of your [turn|Concept.Turn], if you are not [Engaged in Melee|Concept.ZoneOfControl]"),
			});
		}

		return ret;
	}
});