::Hardened.HooksMod.hook("scripts/skills/traits/impatient_trait", function(q) {
	q.m.HD_InitiativeModifier <- 15;
	q.m.HD_MeleeDefenseModifier <- -5;
	q.m.HD_RangedDefenseModifier <- -5;

	// Overwrite, because we grant a completely different effect
	q.getTooltip = @() { function getTooltip()
	{
		local ret = this.skill.getTooltip();

		if (this.m.HD_InitiativeModifier != 0)
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/initiative.png",
				text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizeValue(this.m.HD_InitiativeModifier, {AddSign = true}) + " [$ $|Concept.Initiative]"),
			});
		}

		if (this.m.HD_MeleeDefenseModifier != 0)
		{
			ret.push({
				id = 11,
				type = "text",
				icon = "ui/icons/melee_defense.png",
				text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizeValue(this.m.HD_MeleeDefenseModifier, {AddSign = true}) + " [$ $|Concept.MeleeDefense]"),
			});
		}

		if (this.m.HD_RangedDefenseModifier != 0)
		{
			ret.push({
				id = 12,
				type = "text",
				icon = "ui/icons/ranged_defense.png",
				text = ::Reforged.Mod.Tooltips.parseString(::MSU.Text.colorizeValue(this.m.HD_RangedDefenseModifier, {AddSign = true}) + " [$ $|Concept.RangeDefense]"),
			});
		}

		return ret;
	}}.getTooltip;

	// Overwrite, because we want to disable both the Vanilla and Reforged effects
	q.onUpdate = @() function( _properties )
	{
		_properties.Initiative += this.m.HD_InitiativeModifier;
		_properties.MeleeDefense += this.m.HD_MeleeDefenseModifier;
		_properties.RangedDefense += this.m.HD_RangedDefenseModifier;
	}
});
