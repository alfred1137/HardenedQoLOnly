::Hardened.HooksMod.hook("scripts/skills/effects/dazed_effect", function(q) {
	q.m.DamageTotalMult <- 0.75;		// Vanilla: 0.75
	q.m.InitiativeMult <- 0.75;		// Vanilla: 0.75

	// Vanilla Fix: Ensure that self-removal due to present immunity is done using removeSelf() instead of adjusting the value directly
	q.m.HD_PreventedByProperties = ["IsImmuneToDaze"];

	q.getTooltip = @(__original) function()
	{
		local ret = __original();

		foreach (entry in ret)
		{
			if (entry.id == 11)
			{
				entry.text = "Deal " + ::MSU.Text.colorizeMultWithText(this.m.DamageTotalMult) + " damage";
			}
		}

		return ret;
	}

	// Overwrite, because we disable two vanilla effects and remove the sprite that's turned on by vanilla
	q.onUpdate = @() function( _properties )
	{
		local actor = this.getContainer().getActor();
		if (actor.getCurrentProperties().IsImmuneToDaze)
		{
			this.removeSelf();
		}
		else
		{
			_properties.DamageTotalMult *= this.m.DamageTotalMult;
			_properties.InitiativeMult *= this.m.InitiativeMult;
		}
	}

// Reforged Functions
	// Overwrite, because we want to disable any sprite display originating from this skill
	q.updateSprite = @() function() {}
});