::Hardened.HooksMod.hook("scripts/items/shields/shield", function(q) {
	// Vanilla Fix: Shields sometimes show up as damaged, even if they only missed a few condition points
	q.updateAppearance = @(__original) function()
	{
		__original();

		if (::MSU.isNull(this.getContainer()) || !this.isEquipped()) return;	// Similar condition as in Vanilla

		if (this.m.ShowOnCharacter)
		{
			local conditionPct = (this.m.Condition / (this.m.ConditionMax * 1.0));	// Vanilla: (this.m.Condition / this.m.ConditionMax), which almost always floors to 0
			if (conditionPct > ::Const.Combat.ShowDamagedShieldThreshold)
			{
				// We make sure to display the regular shield sprite in all the intended situations
				this.getContainer().getAppearance().Shield = this.m.Sprite;
			}
		}
	}

// Hardened Functions
	q.HD_getSilhouette = @(__original) function()
	{
		if (::Hardened.Mod.ModSettings.getSetting("ShowShieldSilhouettes").getValue())
		{
			return __original();
		}
		else
		{
			return null;
		}
	}
});

::Hardened.HooksMod.hookTree("scripts/items/shields/shield", function(q) {
	q.create = @(__original) function()
	{
		__original();

		// We hook onPaintInCompanyColors here, because it is not present on all shields and we can't do the following check during regular hooking
		if ("onPaintInCompanyColors" in this)
		{
			local oldOnPaintInCompanyColors = this.onPaintInCompanyColors;
			this.onPaintInCompanyColors = function()
			{
				oldOnPaintInCompanyColors();
				// We make sure this only happens for player as some mods might use onPaintInCompanyColors to color enemies shields
				if (this.isEquipped() && ::MSU.isKindOf(this.getContainer().getActor(), "player"))
				{
					::World.Statistics.getFlags().increment("PaintUsedOnShields");
				}
			}
		}
	}
});