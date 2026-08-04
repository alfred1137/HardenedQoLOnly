::Hardened.HooksMod.hook("scripts/skills/actives/exesword_decapitate", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.Name = "Behead";		// Vanilla: Decapitate
		this.m.Description = "A practiced executioner\'s stroke aimed at the neck.";
		this.m.FatigueCost = 25;		// Vanilla: 20
	}

	// Overwrite, because we completely rework this skill
	q.getTooltip = @() function()
	{
		local ret = this.getDefaultTooltip();

		ret.extend([
			{
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Has a " + ::MSU.Text.colorPositive("100%") + ::Reforged.Mod.Tooltips.parseString(" [chance to hit the head|Concept.ChanceToHitHead]"),
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Will always decapitate on a kill",
			}
		]);

		return ret;
	}

	// Overwrite, because we completely rework this skill
	q.onAnySkillUsed = @() function( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.HitChance[::Const.BodyPart.Head] += 100.0;
		}
	}
});
